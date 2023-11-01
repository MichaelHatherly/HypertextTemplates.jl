using HypertextTemplates
using Test
using ReferenceTests
using Revise

module Templates

include("templates.jl")

end

# Helper function to render a template to a string. Perhaps fold this into
# HypertextTemplates itself?
function render(f, args...; kws...)
    buffer = IOBuffer()
    f(buffer, args...; kws...)
    return String(take!(buffer))
end

@testset "HypertextTemplates" begin
    HypertextTemplates._DATA_FILENAME_ATTR[] = false

    templates = joinpath(@__DIR__, "templates")

    @testset "basic" begin
        basic = joinpath(templates, "basic")

        @test_reference joinpath(basic, "julia.1.txt") render(
            Templates.var"julia-example";
            value = "HypertextTemplates! 🎉 <3",
        )
        @test_reference joinpath(basic, "julia.2.txt") render(
            Templates.var"julia-example";
            value = "",
        )
        @test_reference joinpath(basic, "julia.3.txt") render(
            Templates.var"julia-example";
            value = nothing,
        )
        @test_reference joinpath(basic, "julia.4.txt") render(
            Templates.var"julia-example";
            value = collect(1:5),
        )

        @test_reference joinpath(basic, "for.1.txt") render(
            Templates.var"for-example";
            iter = 1:5,
        )
        @test_reference joinpath(basic, "for.2.txt") render(
            Templates.var"for-example";
            iter = [1, 3, 5],
        )
        @test_reference joinpath(basic, "for.3.txt") render(
            Templates.var"for-example";
            iter = split("1 3 5"),
        )
        @test_reference joinpath(basic, "for-indexed.1.txt") render(
            Templates.var"for-example-indexed";
            iter = split("a b c"),
        )

        @test_reference joinpath(basic, "show.1.txt") render(
            Templates.var"show-example";
            value = 1,
        )
        @test_reference joinpath(basic, "show.2.txt") render(
            Templates.var"show-example";
            value = 2,
        )

        @test_reference joinpath(basic, "match.1.txt") render(
            Templates.var"match-example";
            value = 1,
        )
        @test_reference joinpath(basic, "match.2.txt") render(
            Templates.var"match-example";
            value = "foo",
        )
        @test_reference joinpath(basic, "match.3.txt") render(
            Templates.var"match-example";
            value = nothing,
        )

        @test_reference joinpath(basic, "slot.1.txt") render(
            Templates.var"slot-consumer";
            value = 1,
        )

        @test_reference joinpath(basic, "named-slot.1.txt") render(
            Templates.var"named-slot-consumer";
            value = 1,
        )

        @test_reference joinpath(basic, "complete.1.txt") render(
            Templates.var"complete";
            title = "Custom Title",
        )

        @test_reference joinpath(basic, "props.1.txt") render(Templates.var"props-example";)
        @test_reference joinpath(basic, "props.2.txt") render(
            Templates.var"dynamic-props-example";
            class = "mx-2 flex",
        )

        @test_reference joinpath(basic, "props.3.txt") render(
            Templates.var"dollar-props-example";
            class = "mx-2 flex",
            id = 100,
        )

        @test_reference joinpath(basic, "props.4.txt") render(
            Templates.var"wrapped-props-example";
            class = "mx-2 flex",
        )

        @test_reference joinpath(basic, "layout-usage.1.txt") render(
            Templates.var"layout-usage";
            class = "p-2 bg-gray-200",
        )

        @test_reference joinpath(basic, "special-symbols.1.txt") render(
            Templates.var"special-symbols";
            class = "p-2 bg-purple-200",
        )
    end

    @testset "complex" begin
        complex = joinpath(templates, "complex")
        TC = Templates.Complex

        @test_reference joinpath(complex, "app.1.txt") render(TC.var"app";)

        @test_reference joinpath(complex, "help.1.txt") render(TC.var"help";)

        @test_reference joinpath(complex, "tutorials.1.txt") render(TC.var"tutorials";)

        @test_reference joinpath(complex, "home.1.txt") render(TC.var"home";)
    end

    @testset "keywords" begin
        keywords = joinpath(templates, "keywords")
        TK = Templates.Keywords

        @test_reference joinpath(keywords, "default-props.1.txt") render(
            TK.var"default-props";
        )
        @test_reference joinpath(keywords, "default-props.2.txt") render(
            TK.var"default-props";
            props = "string",
        )
        @test_reference joinpath(keywords, "default-props.3.txt") render(
            TK.var"default-props";
            props = 1:3:10,
        )

        @test_reference joinpath(keywords, "default-typed-props.1.txt") render(
            TK.var"default-typed-props";
        )
        @test_reference joinpath(keywords, "default-typed-props.2.txt") render(
            TK.var"default-typed-props";
            props = [4, 5, 6],
        )
        @test_throws TypeError render(TK.var"default-typed-props"; props = "string")

        @test_reference joinpath(keywords, "typed-props.1.txt") render(
            TK.var"typed-props";
            props = [1, 2, 3],
        )
        @test_throws UndefKeywordError render(TK.var"typed-props";)
        @test_throws TypeError render(TK.var"typed-props"; props = "string")
    end

    @testset "data-htloc" begin
        HypertextTemplates._DATA_FILENAME_ATTR[] = true
        html = render(Templates.Complex.app)
        @test contains(html, "data-htloc")

        # Since the filenames are encoded as an integer counter in the order
        # they are encountered, we need to map them back to the original
        # filename for the test to be easily readable.
        mapping = Dict(
            basename(file) => line for
            (file, line) in HypertextTemplates.DATA_FILENAME_MAPPING
        )
        @test contains(html, "$(mapping["base-layout.html"]):8")
        @test contains(html, "$(mapping["sidebar.html"]):2")
        @test contains(html, "$(mapping["app.html"]):4")
        @test contains(html, "$(mapping["button.html"]):2")
        @test contains(html, "$(mapping["dropdown.html"]):2")
        @test contains(html, "$(mapping["dropdown.html"]):3")
    end
end
