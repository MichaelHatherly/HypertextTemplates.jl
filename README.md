# HypertextTemplates.jl

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://michaelhatherly.github.io/HypertextTemplates.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://michaelhatherly.github.io/HypertextTemplates.jl/dev)

_Hypertext templating DSL for Julia_

HypertextTemplates.jl provides a Julian approach to writing HTML using macros that feel natural within the language. Build web pages using Julia's control flow, components, and type safety—all with zero-allocation rendering for maximum performance.

## Features

- **Native Julia syntax** - Write HTML using macros that integrate seamlessly with Julia's control flow
- **Component system** - Create reusable components with props and slots
- **Zero-allocation rendering** - Direct IO streaming without intermediate DOM construction
- **Auto-escaping** - Automatic HTML escaping for security with `SafeString` for trusted content
- **Development tools** - Source location tracking and editor integration for debugging
- **Streaming support** - Asynchronous rendering with micro-batched output
- **Markdown integration** - Create components from Markdown files with interpolation support

## Quick Example

```julia
using HypertextTemplates
using HypertextTemplates.Elements

# Define a reusable component
@component function article_card(; title, author, content)
    @article {class = "card"} begin
        @header begin
            @h1 $title
            @p {class = "author"} "by " $author
        end
        @div {class = "content"} $content
    end
end

# Render HTML
html = @render @div {class = "container"} begin
    @article_card {
        title = "Hello, HypertextTemplates!",
        author = "Julia Developer",
        content = "Building web content with Julia is fast and elegant."
    }
end
```

## Installation

```julia
pkg> add HypertextTemplates

julia> using HypertextTemplates
```

## Documentation

For comprehensive documentation, examples, and guides, visit the [documentation](https://michaelhatherly.github.io/HypertextTemplates.jl/stable).

## License

This package is licensed under the MIT License.

