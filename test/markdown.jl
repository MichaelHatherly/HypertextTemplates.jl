@testitem "markdown components" tags = [:markdown] setup = [Templates] begin
    import CommonMark
    using HypertextTemplates.Elements

    module ExternalDefs

    using HypertextTemplates

    function markdown_component_ext end
    @deftag macro markdown_component_ext end

    end

    @cm_component markdown_component(; x) = joinpath(@__DIR__, "markdown.md")
    @deftag macro markdown_component end

    @cm_component ExternalDefs.markdown_component_ext(; x) =
        joinpath(@__DIR__, "markdown.md")

    render_test("references/markdown/markdown.txt") do io
        @render io @markdown_component {x = 1}
    end
    render_test("references/markdown/markdown-ext.txt") do io
        @render io ExternalDefs.@markdown_component_ext {x = 1}
    end

    # The reference renders above turn source locations off, which leaves
    # the CommonMark extension's own `data-htloc` branch unrendered.
    annotated = @render @markdown_component {x = 1}
    markdown = joinpath(@__DIR__, "markdown.md")
    @test contains(annotated, "<h1 data-htloc=\"$(markdown):1\"")
    @test contains(annotated, "<p data-htloc=\"$(markdown):3\"")

    # The component `@cm_component` builds has to report the `@cm_component`
    # call as its definition site rather than a line inside the package.
    definition_line = @__LINE__() + 1
    @cm_component located_component(; x) = joinpath(@__DIR__, "markdown.md")
    @test functionloc(located_component) == (@__FILE__, definition_line)

    # A node parsed without source information has no `meta` to read one
    # from, which is no location rather than an error.
    bare = CommonMark.Parser()("plain *text*")
    rendered = @render @div $bare
    @test contains(rendered, "<em>text</em>")
    @test !contains(rendered, "<p data-htloc")
end

@testitem "cm_component expansion without a call site" tags = [:markdown] setup = [Templates] begin
    # Expansion from a call site with no file -- the REPL, or a macro
    # driven programmatically -- has to work rather than throw.
    expansion = Base.invokelatest(
        getfield(HypertextTemplates, Symbol("@cm_component")),
        LineNumberNode(1),
        @__MODULE__,
        :(fileless(; x) = "markdown.md"),
    )
    @test expansion isa Expr
end
