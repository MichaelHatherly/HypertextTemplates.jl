# Getting Started

Welcome to HypertextTemplates.jl! This guide will help you get up and running with Julia's hypertext templating DSL.

## Installation

Add HypertextTemplates to your Julia project:

```julia
using Pkg
Pkg.add("HypertextTemplates")
```

Or in the Julia REPL's package mode (press `]`):

```julia
pkg> add HypertextTemplates
```

## First Steps

### Basic Usage

HypertextTemplates provides HTML elements as macros. Here's a simple example:

```julia
using HypertextTemplates
using HypertextTemplates.Elements

# Render a simple HTML fragment
html = @render @div begin
    @h1 "Welcome to HypertextTemplates!"
    @p "This is a simple example."
end

println(html)
# Output:
# <div><h1>Welcome to HypertextTemplates!</h1><p>This is a simple example.</p></div>
```

### Adding Attributes

Attributes are specified using `{}` syntax:

```julia
html = @render @div {id = "main", class = "container"} begin
    @h1 {class = "title"} "Styled Heading"
    @p {style = "color: blue;"} "Blue text"
end
```

### Using Variables and Expressions

Variables and expressions can be included using the `$` syntax:

```julia
name = "Julia"
count = 42

html = @render @div begin
    @h1 "Hello, " $name "!"
    @p "The answer is " $count
    @p "Double the answer: " $(count * 2)
end
```

## Building a Simple Page

Let's create a complete HTML page:

```julia
@component function page(; title, content)
    @html begin
        @head begin
            @meta {charset = "UTF-8"}
            @meta {name = "viewport", content = "width=device-width, initial-scale=1.0"}
            @title $title
        end
        @body begin
            @div {class = "container"} begin
                @h1 $title
                @main $content
            end
        end
    end
end

# Use the page component
html = @render @page {
    title = "My First Page",
    content = @div begin
        @p "Welcome to my website built with HypertextTemplates.jl!"
        @ul begin
            @li "Fast rendering"
            @li "Type-safe templates"
            @li "Julia-native syntax"
        end
    end
}
```

## Working with Loops

Julia's control flow integrates naturally:

```julia
items = ["Apple", "Banana", "Cherry"]

html = @render @ul begin
    for item in items
        @li $item
    end
end

# Or with enumeration
html = @render @ol begin
    for (i, item) in enumerate(items)
        @li {value = i * 10} "Item " $i ": " $item
    end
end
```

## Conditional Rendering

Use standard Julia conditionals:

```julia
user_logged_in = true
username = "julia_dev"

html = @render @div begin
    if user_logged_in
        @p "Welcome back, " $username "!"
        @button "Logout"
    else
        @p "Please log in to continue."
        @button "Login"
    end
end
```

## Creating Your First Component

Components are reusable template functions:

```julia
@component function card(; title, description, link_url = nothing, link_text = "Learn more")
    @div {class = "card"} begin
        @h3 {class = "card-title"} $title
        @p {class = "card-description"} $description
        if !isnothing(link_url)
            @a {href = link_url, class = "card-link"} $link_text
        end
    end
end

# Use the component
html = @render @div {class = "card-grid"} begin
    @card {
        title = "Getting Started",
        description = "Learn the basics of HypertextTemplates.jl"
    }
    @card {
        title = "Advanced Features",
        description = "Explore components, slots, and more",
        link_url = "/docs/advanced",
        link_text = "Explore"
    }
end
```

## Rendering to Different Outputs

By default, `@render` returns a String, but you can specify other outputs:

```julia
# Render to an IO buffer
io = IOBuffer()
@render io @div "Hello, IO!"
result = String(take!(io))

# Render to a byte array
bytes = @render Vector{UInt8} @div "Hello, bytes!"

# Render to a file
open("output.html", "w") do file
    @render file @html begin
        @body @h1 "Saved to file!"
    end
end
```

## Next Steps

Now that you understand the basics:

1. Learn about the [Core Concepts](core-concepts.md) underlying the DSL
2. Explore the [Component System](components.md) for building reusable UI
3. Understand [HTML Elements & Attributes](elements-attributes.md) in detail
4. Discover [Advanced Features](advanced-features.md) for complex applications

## Tips for Beginners

1. **Start Simple**: Begin with basic HTML structures before moving to components
2. **Use the REPL**: Test small snippets interactively to understand the syntax
3. **Leverage Type Safety**: Let Julia's type system help catch errors early
4. **Read Error Messages**: The macro system provides helpful error messages
5. **Explore Examples**: Check the [Examples](examples.md) section for real-world patterns

## Common Pitfalls

- **Forgetting `$` for variables**: Use `$` before variables in element content
- **Missing `begin...end`**: Multi-line content needs `begin...end` blocks
- **Attribute syntax**: Use `{}` for attributes, not `()`
- **String vs expressions**: String literals render as-is, expressions need `$`

Happy templating with HypertextTemplates.jl!