# Core Concepts

Understanding the core concepts of HypertextTemplates.jl will help you use the library effectively and write maintainable templates.

## Macro-Based DSL Philosophy

HypertextTemplates.jl uses Julia's macro system to create a domain-specific language (DSL) for HTML generation. This approach provides several benefits:

### Compile-Time Optimization

```@example compile-time
using HypertextTemplates
using HypertextTemplates.Elements

# This macro call...
html = @render @div {class = "container"} @p "Hello"
println(html)

# The structure is analyzed at compile time - no runtime parsing needed!
```

### Native Julia Integration

The DSL feels like natural Julia code because it *is* Julia code:

```@example control-flow
using HypertextTemplates
using HypertextTemplates.Elements

# Regular Julia control flow works seamlessly
@render @ul begin
    for i in 1:5
        if isodd(i)
            @li {class = "odd"} "Item " $i
        else
            @li {class = "even"} "Item " $i
        end
    end
end
```

### Type Safety

Julia's type system helps catch errors at compile time:

```@example type-safety
using HypertextTemplates
using HypertextTemplates.Elements

@component function typed_list(; items::Vector{String})
    @ul begin
        for item in items
            @li $item
        end
    end
end

@deftag macro typed_list end

# Julia's type system helps catch errors
items = ["Apple", "Banana", "Cherry"]
html = @render @typed_list {items}
println(html)
```

## The `{}` Attribute Syntax

Attributes in HypertextTemplates use a special `{}` syntax that resembles Julia's NamedTuple syntax:

### Basic Attributes

```@example attributes-basic
using HypertextTemplates
using HypertextTemplates.Elements

# Simple attributes
@render @div {id = "main", class = "container"} "Content"
```

```@example attributes-computed
using HypertextTemplates
using HypertextTemplates.Elements

# Computed attributes
width = 100
@render @img {src = "/logo.png", width = width * 2}
```

### Attribute Name Shortcuts

When variable names match attribute names:

```@example shortcuts
using HypertextTemplates
using HypertextTemplates.Elements

class = "active"
disabled = true

# Instead of {class = class, disabled = disabled}
@render @button {class, disabled} "Click me"
```

### Attribute Spreading

Spread multiple attributes from a collection:

```@example spreading
using HypertextTemplates
using HypertextTemplates.Elements

common_attrs = (class = "btn", type = "button")
@render @button {id = "submit", common_attrs...} "Submit"
```

### Boolean Attributes

Boolean handling follows HTML5 semantics:

```@example booleans
using HypertextTemplates
using HypertextTemplates.Elements

# true renders the attribute name only
println(@render @input {type = "checkbox", checked = true})

# false omits the attribute entirely
println(@render @input {type = "checkbox", checked = false})
```

## Text Rendering and Interpolation

HypertextTemplates provides multiple ways to render text content:

### String Literals

String literals are rendered directly without escaping:

```@example string-literals
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @p "This is <b>bold</b> text"
println(html)
# String literals are trusted content - HTML is preserved
```

### Variable Interpolation with `$`

The `$` syntax marks expressions for rendering with automatic escaping:

```@example interpolation
using HypertextTemplates
using HypertextTemplates.Elements

user_input = "<script>alert('xss')</script>"
html = @render @p "User said: " $user_input
println(html)
# Variables are automatically escaped for safety
```

### The `@text` Macro

The `$` syntax is actually shorthand for `@text`:

```@example text-macro
using HypertextTemplates
using HypertextTemplates.Elements

value = 42
a, b = 10, 20

# These are equivalent
html1 = @render @p "Value: " $value
html2 = @render @p "Value: " @text value

println("Using \$: ", html1)
println("Using @text: ", html2)

# @text can handle complex expressions
html3 = @render @p @text "The sum is $(a + b)"
println("Complex expression: ", html3)
```

### Mixed Content

You can mix different content types:

```@example mixed-content
using HypertextTemplates
using HypertextTemplates.Elements

dynamic_var = "dynamic content"

html = @render @div begin
    @span "Static text "   # String literal
    @code $dynamic_var     # Escaped variable
    @p "bold"              # Nested element
    @strong " more text"   # Another literal
end
println(html)
```

## Zero-Allocation Design

HypertextTemplates is designed for maximum performance with zero intermediate allocations:

### Direct IO Streaming

Instead of building a DOM tree, content streams directly to IO:

```@example io-streaming
using HypertextTemplates
using HypertextTemplates.Elements

# No intermediate string allocations
io = IOBuffer()
@render io @div begin
    for i in 1:5
        @p "Paragraph " $i
    end
end

result = String(take!(io))
println(result)
```

### Efficient String Building

The rendering process uses Julia's efficient IO system:

```@example efficient-building
using HypertextTemplates
using HypertextTemplates.Elements

# Internally uses write() calls, not string concatenation
html = @render @div begin
    @h1 "Title"
    @p "Content"
end
println(html)

# This is equivalent to direct write() calls:
# write(io, "<div>")
# write(io, "<h1>")
# write(io, "Title")
# write(io, "</h1>")
# ...
```

### Rendering Pipeline

The rendering pipeline works as follows:

1. **Macro Expansion**: Templates are transformed into Julia code at compile time
2. **IO Target**: All output goes to an IO stream (provided or created)
3. **Direct Writing**: HTML strings and escaped content are written directly
4. **No Buffering**: Content flows straight through without intermediate storage

This design means:
- Memory usage is constant regardless of output size
- First byte is written immediately (no buffering)
- Suitable for very large documents
- Optimal for streaming responses

## Control Flow Integration

### Loops

Any Julia loop construct works:

```@example loops-examples
using HypertextTemplates
using HypertextTemplates.Elements

# for loops
collection = ["Apple", "Banana", "Cherry"]
html1 = @render @ul for item in collection
    @li $item
end
println("For loop:")
println(html1)

# while loops
count = 0
html2 = @render @div begin
    while count < 3
        @p "Count: " $count
        global count += 1
    end
end
println("\nWhile loop:")
println(html2)

# comprehensions
html3 = @render @select begin
    [@option {value = i} "Option " $i for i in 1:5]
end
println("\nComprehension:")
println(html3)
```

### Conditionals

All conditional forms are supported:

```@example conditionals
using HypertextTemplates
using HypertextTemplates.Elements

# if-else
condition = true
html1 = @render @div begin
    if condition
        @p "True branch"
    else
        @p "False branch"
    end
end
println("If-else:")
println(html1)

# ternary operator
isactive = false
html2 = @render @p {class = isactive ? "active" : "inactive"} "Status"
println("\nTernary operator:")
println(html2)

# short-circuit evaluation
hasdata = false
html3 = @render @div begin
    hasdata && @p "Data is available"
    !hasdata && @p "No data available"
end
println("\nShort-circuit:")
println(html3)
```

### Pattern Matching

Works with any macro-based control flow:

```julia
# With Match.jl (example)
@div begin
    @match value begin
        1 => @p "One"
        2 => @p "Two"
        _ => @p "Other"
    end
end
```

## Component Architecture

Components in HypertextTemplates are just Julia functions with special handling:

### Function-Based Components

```@example function-components
using HypertextTemplates
using HypertextTemplates.Elements

@component function alert(; type = "info", message)
    classes = "alert alert-" * type
    @div {class = classes, role = "alert"} $message
end

@deftag macro alert end

# Use the component
html = @render @alert {type = "warning", message = "This is a warning!"}
println(html)
```

### Composition

Components compose naturally:

```@example composition
using HypertextTemplates
using HypertextTemplates.Elements

# Reuse the alert component from above
@component function alert(; type = "info", message)
    classes = "alert alert-" * type
    @div {class = classes, role = "alert"} $message
end

@deftag macro alert end

@component function alert_list(; alerts)
    @div {class = "alert-container"} begin
        for alert in alerts
            @alert {type = alert.type, message = alert.message}
        end
    end
end

@deftag macro alert_list end

# Use the composed component
alerts = [
    (type = "info", message = "Information message"),
    (type = "warning", message = "Warning message"),
    (type = "error", message = "Error message")
]

html = @render @alert_list {alerts}
println(html)
```

### Component Transformation

The `@component` macro transforms the function to:
1. Accept rendering context (IO stream)
2. Handle slot content (both default and named slots)
3. Manage source location tracking (in development mode)
4. Support streaming render (for async operations)

For example, this component:
```julia
@component function example(; prop)
    @div $prop
end
```

Is transformed into a function that:
- Accepts an internal `__io__` parameter for rendering
- Can receive slot content via hidden parameters
- Tracks its definition location for debugging
- Works seamlessly with `StreamingRender`

## Performance Considerations

### Compile-Time Work

Much work happens at compile time:

```@example compile-time-work
using HypertextTemplates
using HypertextTemplates.Elements

# This template structure is analyzed at compile time
@component function static_heavy()
    @div {class = "wrapper"} begin
        @header begin
            @nav begin
                @ul begin
                    @li @a {href = "/"} "Home"
                    @li @a {href = "/about"} "About"
                end
            end
        end
    end
end

@deftag macro static_heavy end

# The structure is compiled, not interpreted at runtime
html = @render @static_heavy
println(html)
```

### Runtime Efficiency

Only dynamic parts are computed at runtime:

```@example runtime-efficiency
using HypertextTemplates
using HypertextTemplates.Elements

@component function dynamic_list(; items)
    # Static structure compiled, only loop runs at runtime
    @ul {class = "list"} begin
        for item in items  # Only this loop runs at runtime
            @li $item
        end
    end
end

@deftag macro dynamic_list end

# Only the loop execution is runtime work
items = ["Dynamic 1", "Dynamic 2", "Dynamic 3"]
html = @render @dynamic_list {items}
println(html)
```

## HTML Escaping Strategy

Security is built into the rendering process:

### Automatic Escaping

All dynamic content is escaped by default:

```@example auto-escaping
using HypertextTemplates
using HypertextTemplates.Elements

unsafe = "<script>alert('xss')</script>"
html = @render @p $unsafe
println(html)
# Dynamic content is automatically escaped for safety
```

### Escape Rules

1. String literals in templates are NOT escaped (trusted content)
2. Variables and expressions with `$` or `@text` ARE escaped
3. Attribute values from variables ARE escaped
4. Element content from components is already rendered (not double-escaped)

### Performance

Escaping uses optimized routines:
- Fast-path for strings without special characters
- Efficient replacement for strings with special characters
- Minimal allocations during escaping

## Summary

These core concepts work together to create a powerful, efficient, and safe templating system:

1. **Macros** provide compile-time optimization and natural syntax
2. **`{}` attributes** offer flexible, Julia-like property handling  
3. **Direct IO streaming** ensures maximum performance
4. **Native control flow** integration makes templates feel like regular Julia code
5. **Automatic escaping** provides security by default
6. **Component architecture** enables code reuse and composition

Understanding these concepts will help you write better templates and troubleshoot issues effectively.
