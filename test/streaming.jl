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
end
