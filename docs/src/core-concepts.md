# Core Concepts

What the macros do with a template, and why one behaves the way it does.

## Macro-Based DSL Philosophy

Every element is a macro. A template is ordinary Julia code that writes HTML as
it runs.

### Compile-Time Optimization

Tag names and literal attributes are known while the macro expands. They become
constants there, and the render writes them out.

```@example compile-time
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @div {class = "container"} @p "Hello"

Main.display_html(html) #hide
```

### Native Julia Integration

A loop or a branch in a template is the loop or branch you would write anywhere
else:

```@example control-flow
using HypertextTemplates
using HypertextTemplates.Elements

@render @ul begin
    for i in 1:5
        if isodd(i)
            @li {class = "odd"} "Item " $i
        else
            @li {class = "even"} "Item " $i
        end
    end
end

Main.display_html(ans) #hide
```

### Typed Props

Props are keyword arguments. Annotate one and Julia checks it when the component
is called, raising a `TypeError` that names the prop.

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

items = ["Apple", "Banana", "Cherry"]
html = @render @typed_list {items}

Main.display_html(html) #hide
```

## The `{}` Attribute Syntax

Building on the macro foundation, attributes use a special `{}` syntax that resembles Julia's NamedTuple syntax:

### Basic Attributes

```@example attributes-basic
using HypertextTemplates
using HypertextTemplates.Elements

# Simple attributes
@render @div {id = "main", class = "container"} "Content"

Main.display_html(ans) #hide
```

```@example attributes-computed
using HypertextTemplates
using HypertextTemplates.Elements

# Computed attributes
width = 100
@render @img {src = "/logo.png", width = width * 2}

Main.display_html(ans) #hide
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

Main.display_html(ans) #hide
```

### Attribute Spreading

Spread multiple attributes from a collection:

```@example spreading
using HypertextTemplates
using HypertextTemplates.Elements

common_attrs = (class = "btn", type = "button")
@render @button {id = "submit", common_attrs...} "Submit"

Main.display_html(ans) #hide
```

### Boolean Attributes

Boolean handling follows HTML5 semantics:

```@example booleans
using HypertextTemplates
using HypertextTemplates.Elements

# true renders the attribute name only
@render @input {type = "checkbox", checked = true}

Main.display_html(ans) #hide
```

```@example booleans
# false omits the attribute entirely
@render @input {type = "checkbox", checked = false}

Main.display_html(ans) #hide
```

## Text Rendering and Interpolation

### Variable Interpolation with `$`

The `$` syntax marks expressions for rendering with automatic escaping:

```@example interpolation
using HypertextTemplates
using HypertextTemplates.Elements

user_input = "<script>alert('xss')</script>"
html = @render @p "User said: " $user_input

Main.display_html(html) #hide
```

### The `@text` Macro

The `$` syntax is actually shorthand for `@text`:

```@example text-macro
using HypertextTemplates
using HypertextTemplates.Elements

value = 42

# These are equivalent
html1 = @render @p "\$ Value: " $value

Main.display_html(html1) #hide
```

```@example text-macro
html2 = @render @p "@text Value: " @text value

Main.display_html(html2) #hide
```

```@example text-macro
a, b = 10, 20
# @text can handle complex expressions
html3 = @render @p @text "The sum is $(a + b)"

Main.display_html(html3) #hide
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

Main.display_html(html) #hide
```

## Streaming Design

The macro expansion described above feeds a rendering pipeline that writes straight to an `IO` stream. There is no DOM and no string concatenation, so a render allocates a few hundred bytes of context and nothing per element, however long the document runs, and the first byte reaches the client before the last one is computed. Rendering to a `String` fills an append-only buffer and hands you its contents; rendering to an `IO` writes through to it. [Rendering & Performance](rendering.md) covers the pipeline, the streaming API, and how to keep a template on the fast path.

## Control Flow Integration

Since templates are Julia code, all control flow constructs work naturally:

### Loops

```@example loops-examples
using HypertextTemplates
using HypertextTemplates.Elements

# for loops
collection = ["Apple", "Banana", "Cherry"]
html1 = @render @ul for item in collection
    @li $item
end

Main.display_html(html1) #hide
```

```@example loops-examples
# while loops
count = 0
html2 = @render @div begin
    while count < 3
        @p "Count: " $count
        global count += 1
    end
end

Main.display_html(html2) #hide
```

```@example loops-examples
# comprehensions
html3 = @render @select begin
    [@option {value = i} "Option " $i for i in 1:5]
end

Main.display_html(html3) #hide
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

Main.display_html(html1) #hide
```

```@example conditionals
# ternary operator
isactive = false
html2 = @render @p {class = isactive ? "active" : "inactive"} "Status"

Main.display_html(html2) #hide
```

```@example conditionals
# short-circuit evaluation
hasdata = false
html3 = @render @div begin
    hasdata && @p "Data is available"
    !hasdata && @p "No data available"
end

Main.display_html(html3) #hide
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

The macro system and control flow integration come together in HypertextTemplates' component architecture:

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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
```

### Component Transformation

`@component` rewrites the function definition. This component:

```julia
@component function example(; prop)
    @div $prop
end
```

becomes a function that takes two keyword arguments alongside `prop`: the stream
to write to, and the slot content the caller passed. Both carry hidden names
that user code cannot collide with, and the body also binds the definition's
file and line so `data-htloc` can point back at it. `@macroexpand` shows the
whole expansion.

Because the stream is a plain argument, a component writes wherever it is told
to: an `IOBuffer`, a socket, or the batching writer behind `StreamingRender`.

## Performance Considerations

Macro expansion and the streaming design each cut work out of a render:

### Compile-Time Work

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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
```

## HTML Escaping Strategy

Anything interpolated with `$` or `@text` is escaped before it reaches the output, so a value that came from a user cannot close a tag or open a script. String literals written directly in a template are escaped too, during macro expansion, so what the render writes is the already-escaped text and nothing is escaped twice. A `script` and a `style` hold raw text rather than markup, so what is written directly in one goes out unescaped and that element's own end tag is neutralised instead, in a `SafeString` as much as in anything else. The innermost element decides, so an element nested inside a script starts markup again and its children are escaped, which is what a `<script type="text/template">` block needs from a value the page will later parse as HTML. [HTML Elements & Attributes](elements-attributes.md#Escaping-and-Security) sets out the full rules, the `SafeString` escape hatch, and `@esc_str` for escaping a value once at macro expansion.
