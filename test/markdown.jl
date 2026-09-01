module ExternalDefs

using HypertextTemplates

function markdown_component_ext end
@deftag macro markdown_component_ext end

end

@cm_component markdown_component(; x) = joinpath(@__DIR__, "markdown.md")
@deftag macro markdown_component end

@cm_component ExternalDefs.markdown_component_ext(; x) = joinpath(@__DIR__, "markdown.md")

@testset "Markdown" begin
    render_test("references/markdown/markdown.txt") do io
        @render io @markdown_component {x = 1}
    end
    render_test("references/markdown/markdown-ext.txt") do io
        @render io ExternalDefs.@markdown_component_ext {x = 1}
    end
end
