using CommonMark
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

function check_backtrace(bt, checks)
    io = IOBuffer()
    Base.show_backtrace(io, bt)
    text = String(take!(io))
    function handle(needle::Union{Regex,AbstractString})
        result = contains(text, needle)
        if !result
            @error "expected to find '$(repr(needle))' in backtrace:\n$text"
        end
        return result
    end
    function handle(fn)
        result = fn(text)
        if !result
            @error "expected to find match in backtrace:\n$text"
        end
        return result
    end
    for each in vec(checks)
        @test handle(each)
    end
end

macro test_throws_st(E, ex, contains)
    quote
        try
            $ex
            @test false
        catch e
            @test isa(e, $E)
            check_backtrace(catch_backtrace(), $contains)
        end
    end
end

@testset "HypertextTemplates" begin
    include("Lexbor.jl")

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
        @test_reference joinpath(basic, "show.3.txt") render(
            Templates.var"show-example-2";
            value = 1,
        )
        @test_reference joinpath(basic, "show.4.txt") render(
            Templates.var"show-example-2";
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

        @test_reference joinpath(basic, "escaped-content.1.txt") render(
            Templates.var"escaped-content";
            content = "&='`<>/",
            interpolated = "user-name",
        )

        @test_reference joinpath(basic, "escaped-content.2.txt") render(
            Templates.var"escaped-content";
            content = "&='`<>/",
            interpolated = "\"></a><script>alert('xss')</script><a href=\"",
        )

        @test_reference joinpath(basic, "escaped-content.3.txt") render(
            Templates.var"escaped-content";
            content = cm"**bold**",
            interpolated = "user-name",
        )

        struct HTMLObject
            value::String
        end
        HypertextTemplates.escape_html(io::IO, obj::HTMLObject) = print(io, obj.value)

        @test_reference joinpath(basic, "escaped-content.4.txt") render(
            Templates.var"escaped-content";
            content = HTMLObject(html(cm"**bold**")),
            interpolated = "user-name",
        )

        @test_reference joinpath(basic, "custom-elements.1.txt") render(
            Templates.var"custom-elements";
            value = true,
        )

        @test_reference joinpath(basic, "custom-elements-nested.1.txt") render(
            Templates.var"custom-elements-nested";
            value = true,
        )

        @test_reference joinpath(basic, "splat-args.1.txt") render(
            Templates.var"splat-args";
            key = :value,
        )

        @test_reference joinpath(basic, "splat-args.2.txt") render(
            Templates.var"splat-args";
        )

        @test_reference joinpath(basic, "splat-args.3.txt") render(
            Templates.var"splat-args";
            a = 1,
            b = 2,
        )

        @test_reference joinpath(basic, "splat-args-2.1.txt") render(
            Templates.var"splat-args-2";
        )

        @test_reference joinpath(basic, "splat-args-2.2.txt") render(
            Templates.var"splat-args-2";
            a = 2,
        )

        @test_reference joinpath(basic, "splat-args-2.3.txt") render(
            Templates.var"splat-args-2";
            a = 2,
            b = 10,
        )

        @test_reference joinpath(basic, "splatted-props.1.txt") render(
            Templates.var"splatted-props";
            props = (;),
        )

        @test_reference joinpath(basic, "splatted-props.2.txt") render(
            Templates.var"splatted-props";
            props = (; value = 2),
        )

        @test_reference joinpath(basic, "splatted-props.3.txt") render(
            Templates.var"splatted-props";
            props = (; option = "option"),
        )

        @test_reference joinpath(basic, "svg.1.txt") render(Templates.var"svg-content")

        @test_throws_st UndefVarError render(Templates.var"file-and-line-info-1") [
            "file-and-line-info.html:2",
            "file-and-line-info.html:1",
            !contains("file-and-line-info.html:7"),
            !contains(HypertextTemplates.SRC_DIR),
        ]
        @test_throws_st UndefVarError render(Templates.var"file-and-line-info-2") [
            "file-and-line-info.html:7",
            "file-and-line-info.html:5",
            !contains("file-and-line-info.html:1"),
            !contains(HypertextTemplates.SRC_DIR),
        ]
        @test_throws_st UndefVarError render(Templates.var"file-and-line-info-3") [
            "file-and-line-info.html:17",
            "file-and-line-info.html:15",
            !contains("file-and-line-info.html:21"),
            !contains(HypertextTemplates.SRC_DIR),
        ]
        @test_throws_st UndefVarError render(Templates.var"file-and-line-info-4") [
            "file-and-line-info.html:21",
            "file-and-line-info.html:23",
            "file-and-line-info.html:7",
            "file-and-line-info.html:5",
            !contains("file-and-line-info.html:1"),
            !contains(HypertextTemplates.SRC_DIR),
        ]
        @test_throws_st UndefVarError render(Templates.var"file-and-line-info-5") [
            "file-and-line-info.html:27",
            "file-and-line-info.html:29",
            "file-and-line-info.html:15",
            "file-and-line-info.html:17",
            !contains("file-and-line-info.html:3"),
            !contains(HypertextTemplates.SRC_DIR),
        ]
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

    @testset "markdown" begin
        markdown = joinpath(templates, "markdown")
        TM = Templates.Markdown

        @test_reference joinpath(markdown, "markdown.1.txt") render(
            TM.var"custom-markdown-name";
            prop = "prop-value",
        )
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
        @test contains(html, "$(mapping["base-layout.html"]):6")
        @test contains(html, "$(mapping["sidebar.html"]):2")
        @test contains(html, "$(mapping["app.html"]):4")
        @test contains(html, "$(mapping["button.html"]):2")
        @test contains(html, "$(mapping["dropdown.html"]):2")
        @test contains(html, "$(mapping["dropdown.html"]):3")

        html = render(Templates.Markdown.var"custom-markdown-name"; prop = "prop-value")
        @test contains(html, "data-htloc")

        mapping = Dict(
            basename(file) => line for
            (file, line) in HypertextTemplates.DATA_FILENAME_MAPPING
        )
        @test contains(html, "$(mapping["markdown.md"]):8")
        @test contains(html, "$(mapping["markdown.md"]):10")
        @test contains(html, "$(mapping["markdown.md"]):12")

        HypertextTemplates._DATA_FILENAME_ATTR[] = false
    end

    @testset "composed templates" begin
        template = Templates.Complex.var"base-layout"(
            slots(Templates.Markdown.var"custom-markdown-name"(; prop = "prop-value"));
            title = "title",
        )
        html = render(template)
        @test contains(html, "<!DOCTYPE")
        @test contains(html, "language-julia")
    end
end
