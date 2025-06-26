# Core Concepts

Understanding the core concepts of HypertextTemplates.jl will help you use the library effectively and write maintainable templates.

## Macro-Based DSL Philosophy

HypertextTemplates.jl uses Julia's macro system to create a domain-specific language (DSL) for HTML generation. This approach provides several benefits:

### Compile-Time Optimization

```julia
# This macro call...
@div {class = "container"} @p "Hello"

# ...is transformed at compile time into efficient rendering code
# No runtime parsing or interpretation needed!
```

### Native Julia Integration

The DSL feels like natural Julia code because it *is* Julia code:

```julia
# Regular Julia control flow works seamlessly
@ul begin
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

```julia
@component function typed_list(items::Vector{T}) where T
    @ul begin
        for item in items
            @li $(string(item))  # Type-safe conversion
        end
    end
end
```

## The `{}` Attribute Syntax

Attributes in HypertextTemplates use a special `{}` syntax that resembles Julia's NamedTuple syntax:

### Basic Attributes

```julia
# Simple attributes
@div {id = "main", class = "container"}

# Computed attributes
width = 100
@img {src = "/logo.png", width = width * 2}
```

### Attribute Name Shortcuts

When variable names match attribute names:

```julia
class = "active"
disabled = true

# Instead of {class = class, disabled = disabled}
@button {class, disabled} "Click me"
```

### Attribute Spreading

Spread multiple attributes from a collection:

```julia
common_attrs = (class = "btn", type = "button")
@button {id = "submit", common_attrs...} "Submit"
# Renders: <button id="submit" class="btn" type="button">Submit</button>
```

### Boolean Attributes

Boolean handling follows HTML5 semantics:

```julia
# true renders the attribute name only
@input {type = "checkbox", checked = true}
# Renders: <input type="checkbox" checked>

# false omits the attribute entirely
@input {type = "checkbox", checked = false}
# Renders: <input type="checkbox">
```

## Text Rendering and Interpolation

HypertextTemplates provides multiple ways to render text content:

### String Literals

String literals are rendered directly without escaping:

```julia
@p "This is <b>bold</b> text"
# Renders: <p>This is <b>bold</b> text</p>
```

### Variable Interpolation with `$`

The `$` syntax marks expressions for rendering with automatic escaping:

```julia
user_input = "<script>alert('xss')</script>"
@p "User said: " $user_input
# Renders: <p>User said: &lt;script&gt;alert('xss')&lt;/script&gt;</p>
```

### The `@text` Macro

The `$` syntax is actually shorthand for `@text`:

```julia
# These are equivalent
@p "Value: " $value
@p "Value: " @text value

# @text can handle complex expressions
@p @text "The sum is $(a + b)"
```

### Mixed Content

You can mix different content types:

```julia
@div begin
    "Static text "        # String literal
    $dynamic_var         # Escaped variable
    @b "bold"           # Nested element
    " more text"        # Another literal
end
```

## Zero-Allocation Design

HypertextTemplates is designed for maximum performance with zero intermediate allocations:

### Direct IO Streaming

Instead of building a DOM tree, content streams directly to IO:

```julia
# No intermediate string allocations
io = IOBuffer()
@render io @div begin
    for i in 1:1000
        @p "Paragraph " $i
    end
end
```

### Efficient String Building

The rendering process uses Julia's efficient IO system:

```julia
# Internally uses write() calls, not string concatenation
@render @div begin
    @h1 "Title"
    @p "Content"
end

# Equivalent to:
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

```julia
# for loops
@ul for item in collection
    @li $item
end

# while loops
count = 0
@div begin
    while count < 5
        @p "Count: " $count
        count += 1
    end
end

# comprehensions
@select begin
    [@option {value = i} "Option " $i for i in 1:10]
end
```

### Conditionals

All conditional forms are supported:

```julia
# if-else
@div begin
    if condition
        @p "True branch"
    else
        @p "False branch"
    end
end

# ternary operator
@p {class = isactive ? "active" : "inactive"} "Status"

# short-circuit evaluation
@div begin
    hasdata && @table render_data(data)
    !hasdata && @p "No data available"
end
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

```julia
@component function alert(; type = "info", message)
    classes = "alert alert-" * type
    @div {class = classes, role = "alert"} $message
end
```

### Composition

Components compose naturally:

```julia
@component function alert_list(; alerts)
    @div {class = "alert-container"} begin
        for alert in alerts
            @alert {type = alert.type, message = alert.message}
        end
    end
end
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

```julia
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
```

### Runtime Efficiency

Only dynamic parts are computed at runtime:

```julia
@component function dynamic_list(; items)
    # Static structure compiled, only loop runs at runtime
    @ul {class = "list"} begin
        for item in items  # Only this loop runs at runtime
            @li $item
        end
    end
end
```

## HTML Escaping Strategy

Security is built into the rendering process:

### Automatic Escaping

All dynamic content is escaped by default:

```julia
unsafe = "<script>alert('xss')</script>"
@p $unsafe
# Renders: <p>&lt;script&gt;alert('xss')&lt;/script&gt;</p>
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