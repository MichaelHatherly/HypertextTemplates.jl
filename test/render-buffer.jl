@testitem "render buffer writes" tags = [:core] setup = [Templates] begin
    # The sink `@render` builds for itself. It replaces `IOBuffer`, so it
    # has to behave like one for everything a render does to it.
    RenderBuffer = HypertextTemplates.RenderBuffer

    buffer = RenderBuffer()
    @test position(buffer) == 0
    @test take!(buffer) == UInt8[]

    # Writes of every shape, and the growth boundary crossed repeatedly.
    function check_growth(total)
        reference = IOBuffer()
        buffer = RenderBuffer()
        written = 0
        piece = 1
        while written < total
            count = min(piece, total - written)
            chunk = repeat("ab", count)[1:count]
            print(reference, chunk)
            print(buffer, chunk)
            written += count
            piece = piece == 17 ? 1 : piece + 1
        end
        @test position(buffer) == total
        @test take!(buffer) == take!(reference)
    end
    for total in (0, 1, 63, 64, 65, 127, 128, 1000, 100_000)
        check_growth(total)
    end

    # Single bytes, mixed with block writes.
    function check_mixed_widths()
        reference = IOBuffer()
        buffer = RenderBuffer()
        for index in 1:300
            if iseven(index)
                write(reference, UInt8(index % 256))
                write(buffer, UInt8(index % 256))
            else
                print(reference, "chunk-$index/")
                print(buffer, "chunk-$index/")
            end
        end
        @test take!(buffer) == take!(reference)
    end
    check_mixed_widths()

    # `take!` hands the bytes over and leaves an empty buffer behind.
    buffer = RenderBuffer()
    print(buffer, "first")
    @test String(take!(buffer)) == "first"
    @test position(buffer) == 0
    print(buffer, "second")
    @test String(take!(buffer)) == "second"

    # A size hint is a hint, not a limit.
    buffer = RenderBuffer(4)
    print(buffer, repeat("x", 500))
    @test String(take!(buffer)) == repeat("x", 500)

    # Non-ASCII goes through unchanged: the sink deals in bytes.
    buffer = RenderBuffer()
    print(buffer, "héllo — ☃")
    @test String(take!(buffer)) == "héllo — ☃"
end

@testitem "render buffer is the render sink" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    RenderBuffer = HypertextTemplates.RenderBuffer

    @test HypertextTemplates._render_dst(String) isa RenderBuffer
    @test HypertextTemplates._render_dst(Vector{UInt8}) isa RenderBuffer
    supplied = IOBuffer()
    @test HypertextTemplates._render_dst(supplied) === supplied

    # Renders that grow past the initial capacity must still be exact.
    big = @render @ul begin
        for index in 1:2000
            @li {class = "row", "data-index" := index} "item $index & more"
        end
    end
    @test length(big) > 100_000
    @test count("<li ", big) == 2000
    @test occursin("&amp; more", big)
    @test endswith(big, "</ul>")
    # The `Vector{UInt8}` destination uses the same sink. Its source
    # location differs from the render above, so it is checked on its own
    # rather than compared byte for byte.
    bytes = @render Vector{UInt8} @ul begin
        for index in 1:2000
            @li {class = "row", "data-index" := index} "item $index & more"
        end
    end
    @test bytes isa Vector{UInt8}
    @test count("<li ", String(bytes)) == 2000
end
