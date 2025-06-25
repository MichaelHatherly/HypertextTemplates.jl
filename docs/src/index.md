# HypertextTemplates.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://michaelhatherly.github.io/HypertextTemplates.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://michaelhatherly.github.io/HypertextTemplates.jl/dev)

_Hypertext templating DSL for Julia_

HypertextTemplates.jl is a powerful and efficient HTML templating system that lets you write HTML using Julia's macro syntax. It provides zero-allocation rendering, a sophisticated component system, and seamless integration with Julia's ecosystem.

## Key Features

- **📝 Natural Syntax** - Write HTML using Julia macros that feel like native code
- **🚀 Zero-Allocation** - Direct IO streaming without intermediate DOM construction
- **🧩 Component System** - Build reusable components with props and slots
- **🔒 Auto-Escaping** - Automatic XSS protection with context-aware escaping
- **🔄 Live Reloading** - Development mode with source tracking and hot reload
- **📊 Streaming** - Async rendering with intelligent micro-batching
- **📚 Markdown Support** - Create components from Markdown files
- **🔌 Extensible** - Integrate with HTTP.jl, Bonito.jl, and more

## Quick Start

```julia
using HypertextTemplates
using HypertextTemplates.Elements

# Simple example
html = @render @div {class = "container"} begin
    @h1 "Welcome to HypertextTemplates!"
    @p "Build fast, secure web applications with Julia."
end

# Component example
@component function card(; title, content)
    @div {class = "card"} begin
        @h2 {class = "card-title"} $title
        @div {class = "card-body"} $content
    end
end

# Use the component
@render @card {
    title = "Hello",
    content = "This is a reusable component!"
}
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
- [Security](security.md) - Auto-escaping and XSS protection
- [Advanced Features](advanced-features.md) - Once rendering, dynamic components
- [Markdown Integration](markdown-integration.md) - Using Markdown with templates

### Development
- [Development Tools](development-tools.md) - Debugging and live reload
- [Integrations](integrations.md) - HTTP.jl, Bonito.jl, and custom integrations
- [Examples & Patterns](examples.md) - Real-world application examples

## API Reference

### Core Macros

#### `@render`
```julia
@render [io] template
```
Render a template to output. If `io` is not provided, returns a `String`.

#### `@component`
```julia
@component function name(; kwargs...)
    # template body
end
```
Define a reusable component with props passed as keyword arguments.

#### `@<`
```julia
@<component_or_element {props...}
```
Dynamically render a component or element stored in a variable.

#### `@deftag`
```julia
@deftag [export] macro name end
```
Create a macro shortcut for a component or element.

### Special Macros

#### `@__slot__`
```julia
@__slot__ [name]
```
Define a slot for content projection. Use without name for default slot.

#### `@__once__`
```julia
@__once__ begin
    # content rendered only once per @render
end
```
Ensure content is rendered only once, useful for dependencies.

#### `@text`
```julia
@text expression
```
Explicitly mark an expression for text rendering. The `$` syntax is shorthand for this.

#### `@element`
```julia
@element "tag-name" identifier
```
Define a custom HTML element.

### Markdown Integration

#### `@cm_component`
```julia
@cm_component name(; kwargs...) = "path/to/file.md"
```
Create a component from a Markdown file (requires CommonMark.jl).

### Types

#### `SafeString`
```julia
SafeString(html::String)
```
Mark a string as safe HTML that should not be escaped.

#### `StreamingRender`
```julia
StreamingRender(f::Function)
StreamingRender() do io
    @render io template
end
```
Create an iterator for streaming template rendering.

### Utilities

#### `@esc_str`
```julia
html = @esc_str "<div>Content</div>"
```
Escape HTML at compile time.

```@autodocs
Modules = [HypertextTemplates]
```

