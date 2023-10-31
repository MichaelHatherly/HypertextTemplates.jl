using HypertextTemplates
using Test
using ReferenceTests

module Templates

using HypertextTemplates

template"templates/basic/for.html"
template"templates/basic/julia.html"
template"templates/basic/show.html"
template"templates/basic/match.html"
template"templates/basic/slot.html"
template"templates/basic/named-slot.html"
template"templates/basic/complete.html"
template"templates/basic/props.html"
template"templates/basic/layout.html"
template"templates/basic/layout-usage.html"
template"templates/basic/special-symbols.html"

module Complex

using HypertextTemplates

template"templates/complex/layouts/base-layout.html"
template"templates/complex/layouts/sidebar.html"
template"templates/complex/layouts/docs.html"

template"templates/complex/pages/home.html"
template"templates/complex/pages/app.html"
template"templates/complex/pages/help.html"
template"templates/complex/pages/tutorials.html"

template"templates/complex/components/button.html"
template"templates/complex/components/dropdown.html"
template"templates/complex/components/tooltip.html"
template"templates/complex/components/modal.html"

end

module Keywords

using HypertextTemplates

template"templates/keywords/keywords.html"

end

end

# Helper function to render a template to a string. Perhaps fold this into
# HypertextTemplates itself?
function render(f, args...; kws...)
    buffer = IOBuffer()
    f(buffer, args...; kws...)
    return String(take!(buffer))
end

@testset "HypertextTemplates" begin
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
end
