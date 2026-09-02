@testitem "streaming render" tags = [:streaming] setup = [Templates] begin
    using HypertextTemplates.Elements

    @component function streaming(; n::Integer)
        @div {class = "streamed"} begin
            @ul begin
                for id in 1:n
                    @li {id} "This is item $id."
                end
            end
        end
    end
    @deftag macro streaming end

    func(io = Vector{UInt8}) = @render io @streaming {n = 10000}
    output = UInt8[]
    for bytes in StreamingRender(func)
        @assert !isempty(bytes)
        append!(output, bytes)
    end
    @test length(output) > 1
    @test output == func()
end

@testitem "streaming writer accepts every write" tags = [:streaming] setup = [Templates] begin
    # `StreamingRender` hands the writer to the caller's function, so
    # writing to it directly has to work. A `write(::MicroBatchWriter,
    # ::AbstractString)` method used to make these ambiguous against
    # `Base`, turning every one of them into a `MethodError`.
    channel = Channel{Vector{UInt8}}(64)
    writer = HypertextTemplates.MicroBatchWriter(channel)
    @test write(writer, "hello") == 5
    @test write(writer, SubString("hello world", 1, 5)) == 5
    @test write(writer, UInt8[1, 2, 3]) == 3
    @test write(writer, codeunits("abc")) == 3
    @test write(writer, 0x41) == 1
    @test print(writer, "text", 42, 'x') === nothing
    # Above `immediate_threshold`, so it bypasses the buffer.
    @test print(writer, repeat("x", 100)) === nothing

    # Everything written to the writer must come back out in order.
    function raw(io)
        write(io, "<p>")
        print(io, "a", 1, 'b')
        write(io, SubString("--tail--", 3, 6))
        print(io, repeat("z", 200))
        write(io, "</p>")
    end
    collected = UInt8[]
    for bytes in StreamingRender(raw)
        append!(collected, bytes)
    end
    @test String(collected) == "<p>a1btail" * repeat("z", 200) * "</p>"
end

@testitem "streaming writer keeps its buffer" tags = [:streaming, :perf] setup = [Templates] begin
    # Flushing a batch must not cost the buffer its capacity. `take!` hands
    # the internal array to the channel and installs a fresh empty one, so
    # the buffer would regrow from nothing on every cycle -- several
    # reallocations per flush, and a flush happens every few hundred bytes.
    sink = Channel{Vector{UInt8}}(64)
    batcher = HypertextTemplates.MicroBatchWriter(sink)
    # Each piece has to stay under `immediate_threshold`, or it bypasses
    # the buffer entirely and there is nothing to keep.
    piece = repeat("x", 40)
    for _ in 1:5
        write(batcher, piece)
    end
    flush(batcher)
    @test String(take!(sink)) == repeat(piece, 5)
    grown = length(batcher.buffer.data)
    @test grown >= 200
    write(batcher, "y")
    flush(batcher)
    @test String(take!(sink)) == "y"
    @test length(batcher.buffer.data) >= grown

    # Which is to say repeated flushes stay flat rather than paying to
    # regrow each time.
    function cycles(writer, channel, n)
        for _ in 1:n
            write(writer, "a short batch of text")
            flush(writer)
            take!(channel)
        end
    end
    cycles(batcher, sink, 5)
    @test allocations(cycles, batcher, sink, 100) < 100 * 150
end

@testitem "streaming flushes while the producer stalls" tags = [:streaming] setup = [Templates] begin
    using HypertextTemplates.Elements

    # The write path no longer reads the clock, which leaves the flush
    # timer as the only thing bounding latency. So check it directly: a
    # producer that emits a little and then stalls must have that little
    # delivered while it is still stalled, not once it finishes.
    function stalling(io)
        @render io @div begin
            @span "a"
            sleep(0.25)
            @span "b"
            sleep(0.25)
            @span "c"
        end
    end
    function quick(io)
        @render io @div begin
            @span "a"
            @span "b"
            @span "c"
        end
    end
    # Warm up first: compiling the render, the iterator and this loop body
    # would otherwise be charged to the first chunk's arrival.
    collect(StreamingRender(quick))
    collect(StreamingRender(stalling))
    started = Base.time()
    arrivals = Tuple{Float64, String}[]
    for chunk in StreamingRender(stalling)
        push!(arrivals, (Base.time() - started, String(copy(chunk))))
    end
    @test join(last.(arrivals)) == sprint(stalling)
    # The producer runs for about half a second. Anything under a tenth of
    # that means the timer flushed while it was asleep rather than the
    # bytes waiting for it to return.
    @test first(first(arrivals)) < 0.05
end

@testitem "streaming survives timer flushes" tags = [:streaming] setup = [Templates] begin
    # Flushing from the batch timer must not corrupt the stream. Writes
    # small enough to stay buffered, spaced so the 1 ms timer fires between
    # them repeatedly. Needs threads to mean anything; corrupted most
    # renders on four threads before the writer took a lock.
    function dribbling(io)
        for i in 1:40
            write(io, "<p>")
            write(io, lpad(string(i), 4, '0'))
            write(io, "</p>")
            i % 4 == 0 && sleep(0.001)
        end
    end
    function corrupted_runs(reference, n)
        corrupted = 0
        for _ in 1:n
            collected = UInt8[]
            for chunk in StreamingRender(dribbling)
                append!(collected, chunk)
            end
            collected == reference || (corrupted += 1)
        end
        return corrupted
    end
    @test corrupted_runs(codeunits(sprint(dribbling)), 25) == 0
end

@testitem "streaming rethrows the producer's exception" tags = [:streaming] setup = [Templates] begin
    using HypertextTemplates.Elements
    import Logging

    # A producer that throws used to close the channel cleanly, so the
    # consumer saw an ordinary end of stream and was handed a truncated
    # document with no indication that anything had gone wrong.
    function failing(io)
        @render io @div begin
            @span "before the failure"
            error("render failed")
        end
    end

    # Drained in a loop because that is how the chunks reach an HTTP
    # response.
    function drain(f)
        collected = UInt8[]
        try
            for chunk in StreamingRender(f)
                append!(collected, chunk)
            end
        catch exception
            return collected, exception
        end
        return collected, nothing
    end

    # Nothing may be logged either: the exception is the report.
    rendered, caught = @test_logs min_level = Logging.Error drain(failing)
    @test caught isa ErrorException
    @test caught.msg == "render failed"
    # The exception comes after what the render managed, which is small enough
    # to still be sitting in the writer's batch when the throw happens.
    @test contains(String(rendered), "before the failure")

    # `collect` goes through the same iterator and must throw too.
    @test_throws ErrorException collect(StreamingRender(failing))
end

@testitem "streaming stops when the consumer walks away" tags = [:streaming] setup = [Templates] begin
    using HypertextTemplates.Elements
    import Logging

    # Abandoning the loop used to leave the producer parked in `put!` holding
    # the writer's lock, the channel open, and the flush timer firing every
    # millisecond into a callback that could never take that lock.
    function long(io)
        @render io @ul begin
            for id in 1:100_000
                @li {id} "This is item $id."
            end
        end
    end

    # A task takes its logger from wherever it is constructed, so the producer
    # has to start inside the block below for what it logs to reach the
    # collector rather than the global logger.
    function abandon()
        stream = StreamingRender(long)
        for _ in stream
            break
        end
        close(stream)
        # The producer unwinds after `close` returns, so anything it says on
        # the way out lands outside the block unless it is waited for here.
        timedwait(() -> istaskdone(stream.task), 10.0)
        return stream
    end

    # Nothing is logged: walking away is not a failed render.
    stream = @test_logs min_level = Logging.Error abandon()
    @test !isopen(stream.channel)
    @test !isopen(stream.timer)
    @test timedwait(() -> istaskdone(stream.task), 10.0) === :ok
    @test !istaskfailed(stream.task)
end

@testitem "streaming closes itself when the render finishes" tags = [:streaming] setup = [Templates] begin
    using HypertextTemplates.Elements

    # A completed render must not leave its flush timer behind either, so the
    # iterator closes the stream when the producer signals the end.
    function quick(io)
        @render io @div begin
            @span "a"
            @span "b"
            @span "c"
        end
    end

    stream = StreamingRender(quick)
    @test !isempty(collect(stream))
    @test !isopen(stream.timer)
    @test !isopen(stream.channel)
    @test timedwait(() -> istaskdone(stream.task), 10.0) === :ok
end

@testitem "streaming chunk size bounds a batch" tags = [:streaming] setup = [Templates] begin
    # `chunk_size` is documented as the size a batch may reach before it is
    # flushed, so a byte-sized one has to send each small write on its own
    # while the default gathers them into a single chunk.
    function dribble(io)
        for _ in 1:5
            write(io, "ab")
        end
    end
    @test length(collect(StreamingRender(dribble; chunk_size = 1))) == 5
    @test length(collect(StreamingRender(dribble))) < 5
end

@testitem "streaming with a nonsensical chunk size" tags = [:streaming] setup = [Templates] begin
    using HypertextTemplates.Elements

    # A nonsensical `chunk_size` used to throw inside the producer task
    # before the channel was closed, hanging the consumer in `take!`.
    function quick(io)
        @render io @div begin
            @span "a"
            @span "b"
            @span "c"
        end
    end
    for size in (-1, 0, 1)
        output = UInt8[]
        task = @async for chunk in StreamingRender(quick; chunk_size = size)
            append!(output, chunk)
        end
        @test timedwait(() -> istaskdone(task), 10.0) === :ok
        @test String(output) == sprint(quick)
    end
end
