# Getting Started

Welcome to HypertextTemplates.jl! This guide will help you get up and running with Julia's HTML templating system.

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

Every HTML element is a Julia macro. Use `@render` to convert templates to HTML strings:

```@example basic
using HypertextTemplates
using HypertextTemplates.Elements

# Render a simple HTML fragment
html = @render @div begin
    @h1 "Welcome to HypertextTemplates!"
    @p "This is a simple example."
end

println(html)
```

### Adding Attributes

Attributes use `{}` syntax, similar to Julia NamedTuples:

```@example attributes
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @div {id = "main", class = "container"} begin
    @h1 {class = "title"} "Styled Heading"
    @p {style = "color: blue;"} "Blue text"
end
```

### Using Variables and Expressions

Use `$` to interpolate variables and expressions. All values are automatically HTML-escaped for security:

```@example variables
using HypertextTemplates
using HypertextTemplates.Elements

name = "Julia"
count = 42

html = @render @div begin
    @h1 "Hello, " $name "!"
    @p "The answer is " $count
    @p "Double the answer: " $(count * 2)
end
```

## Building a Simple Page

Let's create a complete HTML page structure:

```@example complete-page
using HypertextTemplates
using HypertextTemplates.Elements

# Build a complete page
html = @render @html begin
    @head begin
        @meta {charset = "UTF-8"}
        @meta {name = "viewport", content = "width=device-width, initial-scale=1.0"}
        @title "My First Page"
    end
    @body begin
        @div {class = "container"} begin
            @h1 "My First Page"
            @section begin
                @p "Welcome to my website built with HypertextTemplates.jl!"
                @ul begin
                    @li "Fast rendering"
                    @li "Type-safe templates"
                    @li "Julia-native syntax"
                end
            end
        end
    end
end
println(html)
```

## Working with Loops

Julia's control flow integrates naturally:

```@example loops
using HypertextTemplates
using HypertextTemplates.Elements

items = ["Apple", "Banana", "Cherry"]

html = @render @ul begin
    for item in items
        @li $item
    end
end
```

```@example loops2
using HypertextTemplates
using HypertextTemplates.Elements

items = ["Apple", "Banana", "Cherry"]

# With enumeration
html = @render @ol begin
    for (i, item) in enumerate(items)
        @li {value = i * 10} "Item " $i ": " $item
    end
end
```

## Conditional Rendering

Use standard Julia conditionals:

```@example conditional
using HypertextTemplates
using HypertextTemplates.Elements

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

```@example first-component
using HypertextTemplates
using HypertextTemplates.Elements

@component function card(; title, description, link_url = nothing, link_text = "Learn more")
    @div {class = "card"} begin
        @h3 {class = "card-title"} $title
        @p {class = "card-description"} $description
        if !isnothing(link_url)
            @a {href = link_url, class = "card-link"} $link_text
        end
    end
end

# Important: Create a macro shortcut for easier use
@deftag macro card end

# Now you can use @card instead of @<card
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
println(html)
```

### Understanding Components

Components are functions that accept props and generate HTML. Use `@deftag` to create a convenient macro shortcut:

## Components with Slots

Slots allow components to accept child content:

```@example page-with-slots
using HypertextTemplates
using HypertextTemplates.Elements

@component function page(; title)
    @html begin
        @head begin
            @meta {charset = "UTF-8"}
            @meta {name = "viewport", content = "width=device-width, initial-scale=1.0"}
            @title $title
        end
        @body begin
            @div {class = "container"} begin
                @h1 $title
                @section begin
                    @__slot__
                end
            end
        end
    end
end

@deftag macro page end

# Use the page component with slot content
html = @render @page {title = "My First Page"} begin
    @p "Welcome to my website built with HypertextTemplates.jl!"
    @ul begin
        @li "Fast rendering"
        @li "Type-safe templates"
        @li "Julia-native syntax"
    end
end
println(html)
```

The `@__slot__` marker shows where child content renders inside the component.

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

## Common Pitfalls

Avoid these common mistakes when starting with HypertextTemplates:

### 1. Forgetting `$` for Variables
```julia
# Wrong - variable not interpolated
name = "Julia"
@render @p "Hello, name"  # Output: <p>Hello, name</p>

# Correct - use $ to interpolate
@render @p "Hello, " $name  # Output: <p>Hello, Julia</p>
```

### 2. Missing `begin...end` Blocks
```julia
# Wrong - syntax error
@render @div
    @h1 "Title"
    @p "Content"

# Correct - use begin...end for multiple elements
@render @div begin
    @h1 "Title"
    @p "Content"
end
```

### 3. Wrong Attribute Syntax
```julia
# Wrong - using parentheses
@render @div(class="container") "Content"  # Syntax error!

# Correct - use curly braces
@render @div {class = "container"} "Content"
```

### 4. String Literals vs Expressions
```julia
# String literals are NOT escaped (trusted content)
@render @p "<b>Bold</b>"  # Output: <p><b>Bold</b></p>

# Variables ARE escaped (safe from XSS)
text = "<b>Bold</b>"
@render @p $text  # Output: <p>&lt;b&gt;Bold&lt;/b&gt;</p>
```

### 5. Component Usage Without @deftag
```julia
# Define component
@component function my_button(; text = "Click")
    @button {class = "btn"} $text
end

# Wrong - can't use as macro without @deftag
@render @my_button {text = "Submit"}  # Error!

# Correct - either use @< or define a tag
@render @<my_button {text = "Submit"}  # Works

# Or better, define the tag
@deftag macro my_button end
@render @my_button {text = "Submit"}  # Now works!
```

Happy templating with HypertextTemplates.jl!
