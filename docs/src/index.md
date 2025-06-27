# HypertextTemplates.jl

_HTML templating system for Julia_

HypertextTemplates.jl is a powerful and efficient HTML templating system that lets you write HTML using Julia's macro syntax. It provides zero-allocation rendering, a sophisticated component system, and seamless integration with Julia's ecosystem.

## Key Features

- **Natural Syntax** - Write HTML using Julia macros that feel like native code
- **Zero-allocation rendering** - Direct IO streaming without intermediate DOM construction
- **Component System** - Build reusable components with props and slots
- **Automatic HTML escaping** - Automatic XSS protection with context-aware escaping
- **Development tools** - Source location tracking and editor integration
- **Streaming rendering** - Asynchronous rendering with micro-batched output
- **Markdown Support** - Create components from Markdown files

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

### API Reference
- [API Reference](api.md) - Complete API documentation

