# HypertextTemplates.jl

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://michaelhatherly.github.io/HypertextTemplates.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://michaelhatherly.github.io/HypertextTemplates.jl/dev)

_HTML templating system for Julia_

HypertextTemplates.jl renders HTML from Julia macros. Elements are macros,
attributes use a `{}` syntax that mimics a NamedTuple, and loops and
conditionals are Julia's own. There is no separate template language and no
template parser at run time.

## Features

- **Templates are Julia** - Control flow, function calls and stack traces work the way they do everywhere else
- **Component system** - Reusable components with props and slots
- **Escaped by default** - Interpolated values are escaped; `SafeString` is the one way to opt out
- **Static structure folded into constants** - Tags and literal attributes become constants while the macro expands
- **Streaming** - Render straight to an `IO`, or in chunks with `StreamingRender`
- **Development tools** - Source locations in the output, and a key press over an element opens the template that wrote it
- **Markdown integration** - Components from Markdown files, with props interpolated into them

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
@deftag macro article_card end

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

Guides, examples and the API reference are in the [documentation](https://michaelhatherly.github.io/HypertextTemplates.jl/stable).

## License

This package is licensed under the MIT License.

