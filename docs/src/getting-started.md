# Getting Started

Start here if you have not used the package before.

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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
```

A component is a function that takes props and writes HTML. `@deftag` gives it a
macro shortcut, so `@card` stands in for `@<card`.

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

Main.display_html(html) #hide
```

The `@__slot__` marker shows where child content renders inside the component.

## Rendering to Different Outputs

By default, `@render` returns a String, but you can specify other outputs:

```@example getting-started
using HypertextTemplates
using HypertextTemplates.Elements

# Render to an IO buffer
io = IOBuffer()
@render io @div "Hello, IO!"
result = String(take!(io))
```

```@example getting-started
# Render to a byte array
bytes = @render Vector{UInt8} @div "Hello, bytes!"
```

```@example getting-started
# Render to a file
path = joinpath(mktempdir(), "output.html")
open(path, "w") do file
    @render file @html begin
        @body @h1 "Saved to file!"
    end
end

read(path, String)
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

```@example getting-started
# Wrong - variable not interpolated
name = "Julia"
@render @p "Hello, name"
```

```@example getting-started
# Correct - use $ to interpolate
@render @p "Hello, " $name
```

The blocks below are not executed by this manual, since the "wrong" half of each one does not run.

### 2. Missing `begin...end` Blocks

Without a block the three lines are three separate statements: the render
produces an empty `div`, and the two element macros that follow it error with
"`@h1` and `@<h1` cannot be used outside of a `@render` or `@component` macro".

```julia
# Wrong - only the div is rendered
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

Parentheses parse, so this is not a syntax error. `@render` only recognises the
`{}` form, so `@div` is left to expand on its own and reports that it is
outside a `@render`.

```julia
# Wrong - using parentheses
@render @div(class="container") "Content"

# Correct - use curly braces
@render @div {class = "container"} "Content"
```

### 4. String Literals vs Expressions

Both are escaped, so both render the same HTML. The difference is when the
escaping happens: a literal is escaped once while the macro expands, an
interpolated value on every render.

```@example getting-started
# Escaped during macro expansion
@render @p "<b>Bold</b>"
```

```@example getting-started
# Escaped on every render (safe from XSS)
text = "<b>Bold</b>"
@render @p $text
```

### 5. Component Usage Without `@deftag`

```julia
# Define component
@component function my_button(; text = "Click")
    @button {class = "btn"} $text
end

# Wrong - no such macro, so this is an UndefVarError
@render @my_button {text = "Submit"}

# Correct - reach the component with @<
@render @<my_button {text = "Submit"}

# Or define the tag and use it like any element
@deftag macro my_button end
@render @my_button {text = "Submit"}
```
