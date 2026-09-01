# StreamingRender Implementation
#
# 1. Producer thread (@spawn) writes to MicroBatchWriter
# 2. MicroBatchWriter decides whether to send immediately or batch
# 3. Consumer thread (iterator) reads chunks from the Channel
# 4. A background Timer ensures batched data doesn't sit too long
#
# The Channel provides proper synchronization across thread pools, while
# micro-batching prevents the overhead of sending every single byte.

"""
    MicroBatchWriter <: IO

Internal writer that implements the micro-batching strategy. It acts as an
intelligent buffer between the rendering code and the Channel, making decisions
about when to send data based on size and time thresholds.

The writer follows these rules:
- Large writes (≥ immediate_threshold) bypass buffering entirely
- Small writes accumulate in a buffer until a threshold is reached
- A timer ensures buffered data is flushed within max_buffer_time
"""
mutable struct MicroBatchWriter <: IO
    channel::Channel{Vector{UInt8}}
    buffer::IOBuffer
    max_buffer_size::Int      # Maximum bytes before forced flush
    max_buffer_time::Float64  # Maximum seconds before flush
    last_flush_time::Float64
    write_count::Int
    immediate_threshold::Int  # Bytes above which to send immediately

    function MicroBatchWriter(
        channel::Channel{Vector{UInt8}};
        max_buffer_size::Int = 256,
        max_buffer_time::Float64 = 0.001,  # 1ms
        immediate_threshold::Int = 64,
    )
        new(
            channel,
            IOBuffer(),
            max_buffer_size,
            max_buffer_time,
            time(),
            0,
            immediate_threshold,
        )
    end
end

# Determine if the buffer should be flushed. Both rules are reads of fields the
# writer already keeps, which matters: this runs on every single write, and a
# document is thousands of writes long.
#
# There used to be a third rule here, "the previous write was more than
# `max_buffer_time` ago", which meant calling `time()` on every write. At about
# 36 ns a call and six thousand writes for a forty kilobyte document that came
# to roughly 215 us -- more than everything else in the stream put together --
# and it bought nothing. Data cannot sit in the buffer for longer than 64
# writes because of the rule below, and a producer that goes quiet for longer
# than that has to have yielded to do it, which is precisely when the flush
# timer gets to run. Latency is the timer's job; these two rules only have to
# stop the buffer growing.
function should_flush_micro_batch(mbw::MicroBatchWriter)
    position(mbw.buffer) >= mbw.max_buffer_size ||  # Buffer is full
        mbw.write_count >= 64  # Many small writes (prevents pathological cases)
end

function Base.write(mbw::MicroBatchWriter, byte::UInt8)
    # Single bytes always go to buffer
    write(mbw.buffer, byte)
    mbw.write_count += 1

    if should_flush_micro_batch(mbw)
        flush(mbw)
    end

    return 1
end

# Without this method `Base`'s generic fallback would push every byte through
# `write(::MicroBatchWriter, ::UInt8)` one at a time, which both defeats the
# micro-batching heuristics and makes escaped text far more expensive to
# stream than it needs to be.
function Base.unsafe_write(mbw::MicroBatchWriter, p::Ptr{UInt8}, n::UInt)
    n == 0 && return 0
    if n >= mbw.immediate_threshold
        # Large chunks bypass buffering for low latency.
        if position(mbw.buffer) > 0
            flush(mbw)  # Ensure ordering - buffered data goes first
        end
        data = Vector{UInt8}(undef, n)
        GC.@preserve data unsafe_copyto!(pointer(data), p, n)
        put!(mbw.channel, data)
    else
        unsafe_write(mbw.buffer, p, n)
        mbw.write_count += 1

        if should_flush_micro_batch(mbw)
            flush(mbw)
        end
    end

    return Int(n)
end

# There is deliberately no `write(::MicroBatchWriter, ::AbstractString)` method
# here. One used to exist, and it was ambiguous against four of `Base`'s own
# `write` methods, so `write(writer, "text")` and `print(writer, "text")` both
# raised a `MethodError` -- which the streaming function hands the writer to a
# caller, so reaching it took nothing more than writing a string to it.
#
# `unsafe_write` above carries the same micro-batching logic and is what every
# one of those `Base` methods funnels into, so implementing it and
# `write(::UInt8)` covers strings, byte vectors and code units alike, with no
# ambiguity to resolve.

function Base.flush(mbw::MicroBatchWriter)
    pos = position(mbw.buffer)
    if pos > 0
        # `take!` hands the buffer's internal array to the channel and installs
        # a fresh empty one in its place, so the buffer regrows from nothing on
        # every cycle -- about five reallocations per flush, and a flush
        # happens every few hundred bytes. Copying the batch out and truncating
        # keeps the capacity for the next one.
        bytes = Vector{UInt8}(undef, pos)
        seekstart(mbw.buffer)
        readbytes!(mbw.buffer, bytes, pos)
        truncate(mbw.buffer, 0)
        put!(mbw.channel, bytes)
        mbw.write_count = 0
        mbw.last_flush_time = time()
    end
    nothing
end

function Base.close(mbw::MicroBatchWriter)
    flush(mbw)
    # Channel is closed by StreamingRender
end

"""
    create_flush_timer(writer::MicroBatchWriter)

Create a Timer that periodically flushes the writer's buffer if data is present
and enough time has passed since the last flush.

The timer is crucial for bounded latency - without it, small writes that don't
trigger size-based flushing could sit in the buffer indefinitely. This ensures
that even a single character written will appear within max_buffer_time. It is
the only thing that bounds latency: the write path deliberately never reads the
clock, since doing so once per write cost more than the rest of the stream.
"""
function create_flush_timer(writer::MicroBatchWriter)
    # spawn=true on Julia 1.12+ prevents the timer from pinning the task to a thread,
    # which is important for the same thread migration issues we're solving
    timer_kwargs = if VERSION >= v"1.12"
        (interval = writer.max_buffer_time, spawn = true)
    else
        (interval = writer.max_buffer_time,)
    end

    Timer(writer.max_buffer_time; timer_kwargs...) do timer
        # The timer runs independently of writes, so we need to check if a flush
        # is actually needed to avoid empty chunks and unnecessary channel operations
        if position(writer.buffer) > 0 &&
           time() - writer.last_flush_time >= writer.max_buffer_time
            try
                flush(writer)
            catch e
                # Channel closure is normal during shutdown - just stop the timer
                if e isa InvalidStateException
                    close(timer)
                else
                    rethrow(e)
                end
            end
        end
    end
end

"""
    StreamingRender(func; kwargs...)
    StreamingRender(; kwargs...) do io
        # render content
    end

Create an iterator for streaming template rendering.

`StreamingRender` enables efficient rendering of large templates by yielding
chunks of output as they become available. This is particularly useful for:
- HTTP streaming responses
- Large documents that would consume too much memory if rendered at once
- Progressive rendering where content appears as it's generated

The function uses intelligent micro-batching: large writes (≥64 bytes) are sent
immediately for low latency, while smaller writes are batched for efficiency.

# Arguments
- `func`: Function that takes an `io` argument to pass to `@render`

# Keywords
- `buffer_size::Int=32`: Number of chunks the channel can buffer before blocking
- `chunk_size::Int=4096`: Legacy parameter (kept for compatibility, no longer used)
- `immediate_threshold::Int=64`: Bytes above which writes bypass buffering for low latency

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> # Collect all chunks (for demonstration)
       chunks = String[];

julia> for chunk in StreamingRender() do io
           @render io @div begin
               @h1 "Header"
               @p "Content"
           end
       end
           push!(chunks, String(chunk))
       end

julia> join(chunks)
"<div><h1>Header</h1><p>Content</p></div>"
```

# HTTP streaming example
```julia
using HTTP
using HypertextTemplates, HypertextTemplates.Elements

function handle_request(req)
    HTTP.Response(200, ["Content-Type" => "text/html"]) do io
        for chunk in StreamingRender() do render_io
            @render render_io @html begin
                @head @title "Streaming Page"
                @body begin
                    @h1 "Live Data"
                    for i in 1:1000
                        @div "Item \$i"
                    end
                end
            end
        end
            write(io, chunk)
        end
    end
end
```

# Progressive rendering
```julia
# Stream data as it becomes available
for chunk in StreamingRender() do io
    @render io @div begin
        @h1 "Results"
        for result in fetch_results_lazily()
            @article begin
                @h2 result.title
                @p result.content
            end
        end
    end
end
    # Send chunk to client immediately
    write(client_connection, chunk)
    flush(client_connection)
end
```

See also: [`@render`](@ref), [`MicroBatchWriter`](@ref)
"""
struct StreamingRender
    channel::Channel{Vector{UInt8}}
    task::Task

    function StreamingRender(
        f::Function;
        buffer_size::Int = 32,
        chunk_size::Int = 4096,
        immediate_threshold::Int = 64,
    )
        # The Channel is the synchronization point between producer and consumer.
        # buffer_size controls backpressure - when full, the producer blocks.
        channel = Channel{Vector{UInt8}}(buffer_size)

        # Producer task runs the user's rendering function in a separate thread.
        # Using @spawn allows true parallelism between rendering and consumption.
        task = Threads.@spawn begin
            # MicroBatchWriter wraps the channel with intelligent buffering.
            # chunk_size is capped at 256 to prevent excessive memory usage
            # while maintaining compatibility with the old API.
            writer = MicroBatchWriter(
                channel;
                max_buffer_size = min(chunk_size, 256),
                max_buffer_time = 0.001,
                immediate_threshold = immediate_threshold,
            )

            # The timer ensures bounded latency even for small writes.
            # It runs independently and flushes the buffer periodically.
            timer = create_flush_timer(writer)

            try
                # User's rendering function writes to our MicroBatchWriter,
                # which handles the complexity of when to send chunks.
                f(writer)
            catch e
                @error "Error in streaming render" exception = (e, catch_backtrace())
                rethrow(e)
            finally
                # Cleanup order matters: timer first (stop flushing),
                # then writer (flush remaining), then channel (signal EOF)
                close(timer)
                close(writer)
                close(channel)
            end
        end

        return new(channel, task)
    end
end

# Iterator interface makes StreamingRender work in for loops.
# This is the consumer side - it pulls chunks from the channel as they become available.
# With channels take!() blocks until data is available, providing natural flow
# control between producer and consumer.
function Base.iterate(s::StreamingRender, state = nothing)
    try
        # This blocks until a chunk is available or the channel is closed
        chunk = take!(s.channel)
        return (chunk, nothing)
    catch e
        # Channel closure is used to signal end of stream
        if e isa InvalidStateException && !isopen(s.channel)
            return nothing
        else
            rethrow(e)
        end
    end
end
Base.eltype(::Type{StreamingRender}) = Vector{UInt8}
Base.IteratorSize(::Type{StreamingRender}) = Base.SizeUnknown()
