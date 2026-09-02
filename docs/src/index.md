# HypertextTemplates.jl

_HTML templating system for Julia_

HypertextTemplates.jl renders HTML from Julia macros. Elements are macros,
attributes use a `{}` syntax that mimics a NamedTuple, and loops and
conditionals are Julia's own. There is no separate template language and no
template parser at run time.

## Key Features

- **Templates are Julia** - Control flow, function calls and stack traces work the way they do everywhere else
- **Components** - Reusable components with props and slots
- **Escaped by default** - Interpolated values are escaped; `SafeString` is the one way to opt out
- **Static structure folded into constants** - Tags and literal attributes become constants while the macro expands
- **Streaming** - Render straight to an `IO`, or in chunks with `StreamingRender`
- **Development tools** - Source locations in the output, and a key press over an element opens the template that wrote it
- **Markdown** - Components from Markdown files, with props interpolated into them

## Quick Start

```@example get-started
using HypertextTemplates
using HypertextTemplates.Elements

# Simple example
html = @render @div {class = "container"} begin
    @h1 "Welcome to HypertextTemplates!"
    @p "Build fast, secure web applications with Julia."
end

Main.display_html(ans) #hide
```

```@example get-started
# Component example
@component function article_card(; title, author, content)
    @article {class = "card"} begin
        @header begin
            @h2 {class = "card-title"} $title
            @p {class = "author"} "by " $author
        end
        @div {class = "card-body"} $content
    end
end
@deftag macro article_card end

# Use the component
@render @article_card {
    title = "Hello",
    author = "Julia Developer",
    content = "This is a reusable component!"
}

Main.display_html(ans) #hide
```

## Documentation

### Getting Started
- [Getting Started Guide](getting-started.md) - Installation and first steps
- [Core Concepts](core-concepts.md) - Understanding the fundamentals

### Building Applications
- [Components Guide](components.md) - Creating reusable UI components
- [Elements & Attributes](elements-attributes.md) - Working with HTML elements
- [Rendering & Performance](rendering.md) - Optimization and streaming

### Advanced Topics
- [Advanced Features](advanced-features.md) - Once rendering, dynamic components
- [Markdown Integration](markdown-integration.md) - Using Markdown with templates
- [Development Tools](development-tools.md) - Source locations, editor lookup, Revise, Bonito

### API Reference
- [API Reference](api.md) - Complete API documentation

