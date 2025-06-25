# Advanced Features

This guide covers advanced features in HypertextTemplates.jl that enable sophisticated template patterns and optimizations.

## The `@__once__` Macro

The `@__once__` macro ensures content is rendered only once per `@render` call, even if the component is used multiple times.

### Basic Usage

```julia
@component function include_jquery()
    @__once__ begin
        @script {src = "https://code.jquery.com/jquery-3.6.0.min.js"}
    end
end

# The script tag appears only once in the output
@render @div begin
    @include_jquery  # Renders script
    @include_jquery  # Skips script (already rendered)
    @include_jquery  # Skips script (already rendered)
end
# Output: <div><script src="https://code.jquery.com/jquery-3.6.0.min.js"></script></div>
```

### Common Use Cases

#### CSS Dependencies

```julia
@component function styled_button(; text, variant = "primary")
    @__once__ begin
        @style """
        .btn {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 0.25rem;
            cursor: pointer;
        }
        .btn-primary { background: #007bff; color: white; }
        .btn-danger { background: #dc3545; color: white; }
        """
    end
    
    @button {class = "btn btn-$variant"} $text
end

# Style block rendered once, buttons rendered multiple times
@render @div begin
    @styled_button {text = "Save", variant = "primary"}
    @styled_button {text = "Delete", variant = "danger"}
    @styled_button {text = "Cancel"}
end
```

#### JavaScript Initialization

```julia
@component function data_table(; id, data)
    @__once__ begin
        @script """
        function initDataTable(id) {
            // Initialize table sorting, filtering, etc.
            console.log('Initializing table:', id);
        }
        """
    end
    
    @table {id} begin
        # Table content...
    end
    
    @script "initDataTable('$id');"
end
```

### Scoping Behavior

`@__once__` is scoped to the current render context:

```julia
# First render - includes script
html1 = @render @div begin
    @include_jquery
end

# Second render - includes script again (different render context)
html2 = @render @div begin
    @include_jquery  
end

# Within same render - deduplication works
html3 = @render @div begin
    @section @include_jquery  # Included
    @section @include_jquery  # Skipped
end
```

## The `@deftag` Macro

Create custom macros for components and elements for cleaner syntax.

### Basic Definition

```julia
# Define a component
@component function alert(; type = "info", dismissible = false)
    @div {class = "alert alert-$type"} begin
        @__slot__
        if dismissible
            @button {class = "close"} "×"
        end
    end
end

# Create a macro for it
@deftag macro alert end

# Now use as a regular element macro
@render @alert {type = "warning", dismissible = true} begin
    @strong "Warning!" " Something went wrong."
end
```

### Custom Element Tags

```julia
# Define custom elements with macros
@element "my-custom-element" my_custom_element
@deftag macro my_custom_element end

# Use the custom element
@render @my_custom_element {prop = "value"} "Content"
# Output: <my-custom-element prop="value">Content</my-custom-element>
```

### Module-Scoped Tags

```julia
module UI
    using HypertextTemplates
    
    @component function button(; variant = "default")
        @button {class = "ui-btn ui-btn-$variant"} @__slot__
    end
    
    # Export the macro
    @deftag export macro button end
end

# Use from another module
using .UI
@render @UI.button {variant = "primary"} "Click me"
```

## Text Interpolation with `$`

The `$` syntax provides convenient text interpolation, similar to string interpolation.

### Basic Interpolation

```julia
name = "Julia"
version = 1.9

@render @div begin
    @h1 "Welcome to " $name " v" $version
end
# Equivalent to:
# @h1 "Welcome to " @text name " v" @text version
```

### Expression Interpolation

```julia
items = ["apple", "banana", "cherry"]

@render @ul begin
    for (i, item) in enumerate(items)
        @li "Item " $i ": " $(uppercase(item))
    end
end
```

### Nested Interpolation

```julia
@component function price_display(; amount, currency = "$")
    @span {class = "price"} begin
        $currency $(round(amount, digits=2))
    end
end

@render @div begin
    "Total: " @price_display {amount = 99.999}
end
# Output: <div>Total: <span class="price">$100.0</span></div>
```

## Dynamic Component Selection

The `@<` macro enables dynamic component rendering.

### Component as Variable

```julia
# Select component based on condition
@component function message(; type, content)
    component = if type == "error"
        error_message
    elseif type == "warning"  
        warning_message
    else
        info_message
    end
    
    @<component {content}
end

# Define the specific components
@component error_message(; content)
    @div {class = "error"} @strong "Error: " $content
end

@component warning_message(; content)
    @div {class = "warning"} @strong "Warning: " $content
end

@component info_message(; content)
    @div {class = "info"} @strong "Info: " $content
end
```

### Polymorphic Components

```julia
@component function flexible_container(; tag = div, children)
    @<tag {class = "container"} begin
        for child in children
            @<child
        end
    end
end

# Use with different tags
@render @flexible_container {tag = section, children = [
    @component() @h1 "Title",
    @component() @p "Content"
]}
```

### Component Maps

```julia
const FIELD_COMPONENTS = Dict(
    :text => text_field,
    :email => email_field,
    :select => select_field,
    :checkbox => checkbox_field
)

@component function form_field(; type, name, label, options = nothing)
    component = get(FIELD_COMPONENTS, type, text_field)
    
    @div {class = "form-field"} begin
        @label {for = name} $label
        @<component {name, options}
    end
end
```

## Hidden Variable Management

HypertextTemplates uses hidden variables to manage internal state without polluting your namespace.

### Automatic Variable Hygiene

```julia
@component function no_conflicts()
    # These don't conflict with internal variables
    io = "my io value"
    slot = "my slot value"
    
    @div begin
        @p $io
        @p $slot
    end
end
```

### Understanding Macro Expansion

```julia
# See what the macro generates
@macroexpand @div {class = "test"} "content"

# The expansion uses gensym'd variables to avoid conflicts
# Internal variables like __io__, __slot__, etc. are hidden
```

## Source Location Tracking

Development mode includes source location information for debugging.

### Automatic Tracking

```julia
# In development, elements include data attributes
@render IOContext(stdout, :mode => :development) @div begin
    @h1 "Title"  # Includes data-htloc attribute
    @p "Content" # Includes data-htloc attribute
end
```

### Controlling Source Tracking

```julia
# Global toggle
HypertextTemplates.SOURCE_TRACKING[] = false  # Disable
HypertextTemplates.SOURCE_TRACKING[] = true   # Enable

# Per-render control
io_dev = IOContext(io, :mode => :development)  # Include source
io_prod = IOContext(io, :mode => :production)  # Exclude source

@render io_prod @div "No source tracking"
```

### Custom Source Information

```julia
@component function tracked_component()
    # Source location automatically captured
    @div {class = "tracked"} begin
        @__slot__
    end
end

# The component definition location is preserved
# Useful for debugging which component rendered what
```

## Advanced Patterns

### Memoization

Cache expensive computations:

```julia
const COMPUTED_CACHE = Dict{Any,Any}()

@component function memoized(; key, compute)
    value = get!(COMPUTED_CACHE, key) do
        compute()
    end
    
    @div {class = "memoized"} $value
end

# Usage
@memoized {
    key = "expensive-$id",
    compute = () -> expensive_calculation(id)
}
```

### Render Props Pattern

Pass rendering functions as props:

```julia
@component function data_fetcher(; url, render_loading, render_error, render_success)
    data, error, loading = fetch_data(url)  # Simplified
    
    if loading
        @<render_loading
    elseif !isnothing(error)
        @<render_error {error}
    else
        @<render_success {data}
    end
end

# Usage
@data_fetcher {
    url = "/api/users",
    render_loading = @component() @p "Loading...",
    render_error = @component(; error) @p {class="error"} "Error: " $error,
    render_success = @component(; data) @ul for user in data
        @li $user.name
    end
}
```

### Portal Pattern

Render content outside the current DOM hierarchy:

```julia
# Global portal targets
const PORTALS = Dict{Symbol,Vector{Any}}()

@component function portal(; to, content)
    # Register content for rendering elsewhere
    push!(get!(PORTALS, to, []), content)
    # Return nothing in current position
    @text ""
end

@component function portal_target(; name)
    contents = get(PORTALS, name, [])
    @div {id = "portal-$name"} begin
        for content in contents
            @<content
        end
    end
    empty!(contents)  # Clear after rendering
end

# Usage
@render @html begin
    @body begin
        @div begin
            @h1 "Page content"
            @portal {to = :modals, content = @component() begin
                @div {class = "modal"} "Modal content"
            end}
        end
        
        # Modals render at body end
        @portal_target {name = :modals}
    end
end
```

### Template Inheritance

Build template inheritance systems:

```julia
@component function base_layout(; title = "Default Title")
    @html begin
        @head begin
            @title $title
            @__slot__ head  # Additional head content
        end
        @body begin
            @header @__slot__ header
            @main @__slot__     # Default slot for main content
            @footer @__slot__ footer
        end
    end
end

@component function blog_layout(; post)
    @base_layout {title = post.title} begin
        # Main content
        @article begin
            @h1 $post.title
            @div {class = "content"} $(SafeString(post.html))
        end
        
        # Named slots
        head := @meta {name = "author", content = post.author}
        
        header := @nav @a {href = "/blog"} "← Back to Blog"
        
        footer := @p "Published: " $post.date
    end
end
```

### Async Component Pattern

Handle async operations in components:

```julia
@component function async_data(; loader, fallback = nothing)
    # This is a simplified example
    # In practice, you'd need proper async handling
    task = @async loader()
    
    if istaskdone(task)
        data = fetch(task)
        @div {class = "loaded"} @__slot__ data
    else
        if !isnothing(fallback)
            @<fallback
        else
            @div {class = "loading"} "Loading..."
        end
    end
end
```

## Performance Optimizations

### Compile-Time Optimization

```julia
# Constants are embedded at compile time
const STATIC_CLASSES = "btn btn-primary"

@component function optimized_button()
    # This is faster than computing at runtime
    @button {class = STATIC_CLASSES} @__slot__
end
```

### Reducing Allocations

```julia
# Pre-allocate buffers for repeated rendering
const BUFFER_POOL = [IOBuffer() for _ in 1:Threads.nthreads()]

function render_with_pooled_buffer(component)
    buffer = BUFFER_POOL[Threads.threadid()]
    truncate(buffer, 0)  # Reset buffer
    @render buffer component
    String(take!(buffer))
end
```

## Best Practices

1. **Use `@__once__` for dependencies** - Include CSS/JS dependencies once
2. **Create domain-specific tags** - Use `@deftag` for common patterns
3. **Leverage `$` interpolation** - Cleaner than multiple `@text` calls
4. **Cache expensive operations** - Use memoization for complex computations
5. **Profile macro expansions** - Use `@macroexpand` to understand generated code
6. **Manage global state carefully** - Portal and once patterns need coordination

## Summary

Advanced features in HypertextTemplates.jl enable:

- **Dependency management** with `@__once__`
- **Custom DSLs** via `@deftag`
- **Dynamic rendering** with `@<`
- **Clean interpolation** with `$`
- **Sophisticated patterns** like portals and render props
- **Performance optimizations** through compile-time computation

These features combine to support complex application architectures while maintaining the simplicity and performance that makes HypertextTemplates.jl powerful.