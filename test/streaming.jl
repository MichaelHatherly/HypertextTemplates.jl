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
end
