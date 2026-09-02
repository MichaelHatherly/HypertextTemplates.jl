using Documenter
using HypertextTemplates
using Deno_jll
using Markdown

# Function to format and display HTML in documentation
function display_html(html::AbstractString)
    # Create a temporary file for the HTML
    return mktempdir() do dir
        # Format using deno fmt
        formatted = try
            # Run deno fmt and capture output
            output = IOBuffer()
            Deno_jll.deno() do deno_path
                run(
                    pipeline(
                        `$deno_path fmt --ext html -`,
                        stdin = IOBuffer(html),
                        stdout = output,
                        stderr = devnull,
                    ),
                )
            end
            String(take!(output))
        catch e
            # If formatting fails, use original HTML
            @warn "Failed to format HTML with deno fmt" exception = e
            html
        end

        # Return as Markdown code block
        return Markdown.parse(
            """
            ---
            ```html
            $(strip(formatted))
            ```
            ---
            """
        )
    end
end

makedocs(
    sitename = "HypertextTemplates",
    format = Documenter.HTML(),
    modules = [HypertextTemplates],
    doctest = true,
    # `@cm_component` resolves a relative path against the working directory
    # when the call site has no file of its own, which is the case for code in
    # an `@example` block. Running examples from `fixtures/` lets the Markdown
    # pages name their files the way a user's own code would. The directory
    # sits outside `src/` because Documenter turns every `.md` file under
    # `src/` into a page of the manual.
    workdir = joinpath(@__DIR__, "fixtures"),
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "Guides" => [
            "Core Concepts" => "core-concepts.md",
            "Components" => "components.md",
            "Elements & Attributes" => "elements-attributes.md",
            "Rendering & Performance" => "rendering.md",
        ],
        "Advanced" => [
            "Advanced Features" => "advanced-features.md",
            "Markdown Integration" => "markdown-integration.md",
            "Development Tools" => "development-tools.md",
        ],
        "API Reference" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/MichaelHatherly/HypertextTemplates.jl.git",
    push_preview = true,
)
