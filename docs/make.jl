using Documenter
using HypertextTemplates

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
            "Security" => "security.md",
        ],
        "Advanced" => [
            "Advanced Features" => "advanced-features.md",
            "Markdown Integration" => "markdown-integration.md",
        ],
        "API Reference" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/MichaelHatherly/HypertextTemplates.jl.git",
    push_preview = true,
)
