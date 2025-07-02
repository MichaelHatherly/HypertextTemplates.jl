using Documenter
using HypertextTemplates
using Deno_jll
using Markdown

# Function to format and display HTML in documentation
function display_html(html::AbstractString)
    # Create a temporary file for the HTML
    mktempdir() do dir
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
        return Markdown.parse("""
        ---
        ```html
        $(strip(formatted))
        ```
        ---
        """)
    end
end

include("generate_examples.jl")

makedocs(
    sitename = "HypertextTemplates",
    format = Documenter.HTML(),
    modules = [HypertextTemplates],
    doctest = true,
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "Guides" => [
            "Core Concepts" => "core-concepts.md",
            "Components" => "components.md",
            "Elements & Attributes" => "elements-attributes.md",
            "Rendering & Performance" => "rendering.md",
            "Library Components" => "library-components.md",
        ],
        "Advanced" => [
            "Advanced Features" => "advanced-features.md",
            "Markdown Integration" => "markdown-integration.md",
        ],
        "API Reference" => [
            "Public API" => "api-public.md",
            "Library Components" => "api-library.md", 
            "Internal API" => "api-internal.md",
        ],
    ],
)

deploydocs(
    repo = "github.com/MichaelHatherly/HypertextTemplates.jl.git",
    push_preview = true,
)
