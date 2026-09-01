@component function streaming(; n::Integer)
    @div {class = "streamed"} begin
        @ul begin
            for id = 1:n
                @li {id} "This is item $id."
            end
        end
    end
end
@deftag macro streaming end

@testset "Streaming" begin
    func(io = Vector{UInt8}) = @render io @streaming {n = 10000}
    output = UInt8[]
    for bytes in StreamingRender(func)
        @assert !isempty(bytes)
        append!(output, bytes)
    end
    @test length(output) > 1
    @test output == func()

    # `StreamingRender` hands the writer to the caller's function, so
    # writing to it directly has to work. A `write(::MicroBatchWriter,
    # ::AbstractString)` method used to make these ambiguous against
    # `Base`, turning every one of them into a `MethodError`.
    @test isempty(Test.detect_ambiguities(HypertextTemplates; recursive = true))
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

    # Flushing a batch must not cost the buffer its capacity. `take!` hands
    # the internal array to the channel and installs a fresh empty one, so
    # the buffer would regrow from nothing on every cycle -- several
    # reallocations per flush, and a flush happens every few hundred bytes.
    sink = Channel{Vector{UInt8}}(64)
    batcher = HypertextTemplates.MicroBatchWriter(sink)
    # Each piece has to stay under `immediate_threshold`, or it bypasses
    # the buffer entirely and there is nothing to keep.
    piece = repeat("x", 40)
    for _ = 1:5
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
        for _ = 1:n
            write(writer, "a short batch of text")
            flush(writer)
            take!(channel)
        end
    end
    cycles(batcher, sink, 5)
    @test (@allocated cycles(batcher, sink, 100)) < 100 * 150

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
    arrivals = Tuple{Float64,String}[]
    for chunk in StreamingRender(stalling)
        push!(arrivals, (Base.time() - started, String(copy(chunk))))
    end
    @test join(last.(arrivals)) == sprint(stalling)
    # The producer runs for about half a second. Anything under a tenth of
    # that means the timer flushed while it was asleep rather than the
    # bytes waiting for it to return.
    @test first(first(arrivals)) < 0.05
end
