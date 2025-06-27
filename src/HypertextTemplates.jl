"""
    HypertextTemplates

A hypertext templating DSL for Julia that allows writing HTML using native Julia syntax.

HypertextTemplates provides a macro-based DSL where all HTML elements are exposed as macros
(e.g., `@div`, `@p`). It uses a special `{}` syntax for attributes that mimics NamedTuples,
allowing natural integration of Julia control flow directly in templates.

# Key Features
- **Zero-allocation rendering**: Direct IO streaming without intermediate DOM
- **Component system**: Reusable components with props and slots
- **Auto-escaping**: Automatic HTML escaping for security (bypass with `SafeString`)
- **Streaming support**: Efficient chunked rendering for large documents
- **Markdown integration**: Render Markdown files as components (requires CommonMark.jl)

# Basic Usage
```julia
using HypertextTemplates, HypertextTemplates.Elements

# Simple rendering
@render @div {class = "greeting"} "Hello, World!"

# Components with slots
@component function card(; title)
    @div {class = "card"} begin
        @h2 \$title
        @div {class = "body"} @__slot__
    end
end
```

# Main Exports
- `@render`: Render templates to strings or IO
- `@component`: Define reusable components
- `@deftag`: Create macro shortcuts for components
- `SafeString`: Mark content as pre-escaped HTML
- `StreamingRender`: Iterator for chunked rendering
- `@<`: Dynamic component/element rendering

See the documentation for detailed examples and advanced features.
"""
module HypertextTemplates

# Imports:

import CodeTracking
import PackageExtensionCompat
import MacroTools

# Exports:

export @<
export @__once__
export @__slot__
export @cm_component
export @component
export @deftag
export @element
export @esc_str
export @render
export @text
export SafeString
export StreamingRender

# Includes:

include("revise.jl")
include("hidden-var-macros.jl")
include("render-macro.jl")
include("tag-macro.jl")
include("text-macro.jl")
include("component-macro.jl")
include("slot-macro.jl")
include("element-rendering.jl")
include("SafeString.jl")
include("html-escaping.jl")
include("element-macro.jl")
include("deftag.jl")
include("Elements.jl")
include("template-source-lookup.jl")
include("render.jl")
include("stream.jl")
include("cmfile.jl")
include("once.jl")

# Initialization:

function __init__()
    PackageExtensionCompat.@require_extensions
end

end # module HypertextTemplates
