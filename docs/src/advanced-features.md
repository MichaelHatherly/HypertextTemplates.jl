# Advanced Features

This guide covers advanced features in HypertextTemplates.jl that enable sophisticated template patterns and optimizations.

## The `@__once__` Macro

The `@__once__` macro ensures content is rendered only once per `@render` call, even if the component is used multiple times.

### Basic Usage

The `@__once__` macro is a powerful deduplication tool that ensures specific content (like CSS styles, JavaScript libraries, or initialization code) is only rendered once within a single `@render` call, even if the component containing it is used multiple times. This is essential for preventing duplicate script tags, style definitions, or other resources that should only appear once in your HTML output. The macro tracks what has been rendered and automatically skips subsequent occurrences within the same rendering context.

```@example once-basic
using HypertextTemplates
using HypertextTemplates.Elements

@component function include_jquery()
    @__once__ begin
        @script {src = "https://code.jquery.com/jquery-3.6.0.min.js"}
    end
end

@deftag macro include_jquery end

# The script tag appears only once in the output
html = @render @div begin
    @include_jquery  # Renders script
    @include_jquery  # Skips script (already rendered)
    @include_jquery  # Skips script (already rendered)
end

Main.display_html(html) #hide
# Note: Only one script tag appears!
```

### Common Use Cases

#### CSS Dependencies

```@example once-css
using HypertextTemplates
using HypertextTemplates.Elements

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

@deftag macro styled_button end

# Style block rendered once, buttons rendered multiple times
html = @render @div begin
    @styled_button {text = "Save", variant = "primary"}
    @styled_button {text = "Delete", variant = "danger"}
    @styled_button {text = "Cancel"}
end
Main.display_html(html) #hide
# Note: The <style> block appears only once at the beginning!
```

#### JavaScript Initialization

```@example once-js
using HypertextTemplates
using HypertextTemplates.Elements

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
        @thead @tr begin
            @th "Name"
            @th "Value"
        end
        @tbody begin
            for item in data
                @tr begin
                    @td $(item.name)
                    @td $(item.value)
                end
            end
        end
    end
    
    @script "initDataTable('$id');"
end

@deftag macro data_table end

# Multiple tables, but init function defined once
data1 = [(name = "A", value = 1), (name = "B", value = 2)]
data2 = [(name = "X", value = 10), (name = "Y", value = 20)]

html = @render @div begin
    @data_table {id = "table1", data = data1}
    @data_table {id = "table2", data = data2}
end

Main.display_html(html) #hide
# Note: initDataTable function defined once, but called twice
```

### Scoping Behavior

`@__once__` is scoped to the current render context:

```@example once-scoping
using HypertextTemplates
using HypertextTemplates.Elements

@component function scoped_script()
    @__once__ begin
        @script "console.log('Script loaded');"
    end
    @p "Component rendered"
end

@deftag macro scoped_script end

# First render - includes script
html1 = @render @div begin
    @scoped_script
end
println("First render:")
Main.display_html(html1) #hide

# Second render - includes script again (different render context)
html2 = @render @div begin
    @scoped_script  
end
println("\nSecond render (new context):")
Main.display_html(html2) #hide

# Within same render - deduplication works
html3 = @render @div begin
    @section @scoped_script  # Included
    @section @scoped_script  # Skipped
end
println("\nSame render context (deduplication):")
Main.display_html(html3) #hide
```

## The `@deftag` Macro

Create custom macros for components and elements for cleaner syntax.

### Basic Definition

The `@deftag` macro transforms your components and custom elements into first-class DSL elements that can be used with the same clean syntax as built-in HTML elements. Instead of calling components as functions, `@deftag` creates a macro that integrates seamlessly with the template syntax, supporting attributes in `{}` blocks and content blocks just like `@div` or `@p`. This makes your custom components feel native to the templating language and improves code readability.

```@example deftag-basic
using HypertextTemplates
using HypertextTemplates.Elements

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
html = @render @alert {type = "warning", dismissible = true} begin
    @strong "Warning!" " Something went wrong."
end
Main.display_html(html) #hide

# Also works without dismissible
html2 = @render @alert {type = "info"} "This is an info message."
Main.display_html(html2) #hide
```

### Custom Element Tags

```@example custom-element-tags
using HypertextTemplates
using HypertextTemplates.Elements

# Define custom elements with macros
@element "my-custom-element" my_custom_element
@deftag macro my_custom_element end

# Use the custom element
html = @render @my_custom_element {prop = "value"} "Content"
Main.display_html(html) #hide

# Also works with nested content
@element "custom-card" custom_card
@deftag macro custom_card end

html2 = @render @custom_card {variant = "primary"} begin
    @h3 "Card Title"
    @p "Card content goes here"
end
println("\nNested custom element:")
Main.display_html(html2) #hide
```

### Module-Scoped Tags

```@example module-tags
using HypertextTemplates
using HypertextTemplates.Elements

module UI
    using HypertextTemplates
    using HypertextTemplates.Elements
    
    @component function button(; variant = "default")
        Elements.@button {class = "ui-btn ui-btn-$variant"} @__slot__
    end
    
    # Create and export the macro
    @deftag macro button end
    export @button
end

# Use from outside the module
html = @render @UI.button {variant = "primary"} "Click me"
Main.display_html(html) #hide

# Also can import and use directly
using .UI: @button
html2 = @render @button {variant = "success"} "Save"
println("\nImported usage:")
Main.display_html(html2) #hide
```

## Text Interpolation with `$`

The `$` syntax provides convenient text interpolation, similar to string interpolation.

### Basic Interpolation

Text interpolation with `$` provides a concise way to embed dynamic values directly within your templates, eliminating the need for explicit `@text` calls. This syntax works just like Julia's string interpolation but is HTML-aware, automatically escaping values for security. You can interpolate variables, expressions, and even complex computations, making your templates more readable and maintainable while maintaining the same performance and safety guarantees as explicit text nodes.

```@example basic-interp
using HypertextTemplates
using HypertextTemplates.Elements

name = "Julia"
version = 1.9

html = @render @div begin
    @h1 "Welcome to " $name " v" $version
end
Main.display_html(html) #hide
# Equivalent to:
# @h1 "Welcome to " @text name " v" @text version
```

### Expression Interpolation

```@example expr-interp
using HypertextTemplates
using HypertextTemplates.Elements

items = ["apple", "banana", "cherry"]

html = @render @ul begin
    for (i, item) in enumerate(items)
        @li "Item " $i ": " $(uppercase(item))
    end
end
Main.display_html(html) #hide
```

### Nested Interpolation

```@example nested-interp
using HypertextTemplates
using HypertextTemplates.Elements

@component function price_display(; amount, currency = "\$")
    @span {class = "price"} $currency $(round(amount, digits=2))
end

@deftag macro price_display end

html = @render @div begin
    @text "Total: "
    @price_display {amount = 99.999}
    @text " (Tax included: "
    @price_display {amount = 99.999 * 1.1} ")"
end
Main.display_html(html) #hide
```

## Dynamic Component Selection

The `@<` macro enables dynamic component rendering.

### Component as Variable

The `@<` macro enables dynamic component selection at runtime, allowing you to choose which component to render based on data or conditions. This pattern is essential for building flexible UIs where the component type needs to be determined programmatically - such as rendering different message types, form fields, or content blocks based on configuration. The syntax `@<component_var {props}` treats the component as a first-class value that can be stored in variables, passed as arguments, or selected from dictionaries.

```@example dynamic-component
using HypertextTemplates
using HypertextTemplates.Elements

# Define the specific components first
@component function error_message(; content)
    @div {class = "error"} @strong "Error: " $content
end

@component function warning_message(; content)
    @div {class = "warning"} @strong "Warning: " $content
end

@component function info_message(; content)
    @div {class = "info"} @strong "Info: " $content
end

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

@deftag macro message end

# Usage
html = @render @div begin
    @message {type = "error", content = "File not found"}
    @message {type = "warning", content = "Disk space low"}
    @message {type = "info", content = "Process completed"}
end
Main.display_html(html) #hide
```

### Polymorphic Components

```@example polymorphic
using HypertextTemplates
using HypertextTemplates.Elements

@component function flexible_container(; tag = div, class_name = "container")
    @<tag {class = class_name} begin
        @__slot__
    end
end

@deftag macro flexible_container end

# Use with different HTML elements
html1 = @render @flexible_container {tag = section} begin
    @h1 "Section Title"
    @p "Section content"
end
println("As section:")
Main.display_html(html1) #hide

html2 = @render @flexible_container {tag = article, class_name = "article-container"} begin
    @h2 "Article Title"
    @p "Article content"
end
println("\nAs article:")
Main.display_html(html2) #hide
```

### Component Maps

```@example component-maps
using HypertextTemplates
using HypertextTemplates.Elements

# Define field components
@component function text_field(; name, options = nothing)
    @input {type = "text", name, id = name}
end

@component function email_field(; name, options = nothing)
    @input {type = "email", name, id = name}
end

@component function select_field(; name, options = [])
    @select {name, id = name} begin
        for opt in options
            @option {value = opt.value} $(opt.label)
        end
    end
end

# Map of field types to components
const FIELD_COMPONENTS = Dict(
    :text => text_field,
    :email => email_field,
    :select => select_field
)

@component function form_field(; type, name, label, options = nothing)
    component = get(FIELD_COMPONENTS, type, text_field)
    
    @div {class = "form-field"} begin
        Elements.@label {"for" := name} $label
        @<component {name, options}
    end
end

@deftag macro form_field end

# Usage examples
html = @render @form begin
    @form_field {type = :text, name = "username", label = "Username:"}
    @form_field {type = :email, name = "email", label = "Email:"}
    @form_field {
        type = :select,
        name = "country",
        label = "Country:",
        options = [
            (value = "us", label = "United States"),
            (value = "uk", label = "United Kingdom"),
            (value = "ca", label = "Canada")
        ]
    }
end

Main.display_html(html) #hide
```

## Advanced Patterns

### Memoization

Cache expensive computations:

```@example memoization
using HypertextTemplates
using HypertextTemplates.Elements

const COMPUTED_CACHE = Dict{Any,Any}()

@component function memoized(; key, compute)
    value = get!(COMPUTED_CACHE, key) do
        compute()
    end
    
    @div {class = "memoized"} $value
end

@deftag macro memoized end

# Simulate expensive calculation
function expensive_calculation(id)
    println("Computing for id=$id...")
    return "Result for $id"
end

# First call computes
html1 = @render @memoized {
    key = "expensive-42",
    compute = () -> expensive_calculation(42)
}
println("First render: ", html1)

# Second call uses cache (no "Computing..." message)
html2 = @render @memoized {
    key = "expensive-42",
    compute = () -> expensive_calculation(42)
}
println("Second render (cached): ", html2)

# Different key computes again
html3 = @render @memoized {
    key = "expensive-99",
    compute = () -> expensive_calculation(99)
}
println("Different key: ", html3)
```

### Render Props Pattern

Pass rendering functions as props:

```@example render-props
using HypertextTemplates
using HypertextTemplates.Elements

# Simulate data fetching
function fetch_data(url)
    if url == "/api/users"
        # Simulate successful fetch
        data = [(name = "Alice",), (name = "Bob",), (name = "Charlie",)]
        return (data = data, error = nothing, loading = false)
    elseif url == "/api/error"
        return (data = nothing, error = "Network error", loading = false)
    else
        return (data = nothing, error = nothing, loading = true)
    end
end

@component function data_fetcher(; url, render_loading, render_error, render_success)
    result = fetch_data(url)

    if result.loading
        @<render_loading
    elseif !isnothing(result.error)
        @<render_error {error = result.error}
    else
        @<render_success {data = result.data}
    end
end

@deftag macro data_fetcher end

# Define render components
@component function loading_comp()
    @p {class = "loading"} "Loading..."
end
@component function error_comp(; error)
    @p {class = "error"} "Error: " $error
end
@component function success_comp(; data)
    @ul begin
        for user in data
            @li $(user.name)
        end
    end
end

# Success case
println("Success case:")
html1 = @render @data_fetcher {
    url = "/api/users",
    render_loading = loading_comp,
    render_error = error_comp,
    render_success = success_comp
}
Main.display_html(html1) #hide

# Error case
println("\nError case:")
html2 = @render @data_fetcher {
    url = "/api/error",
    render_loading = loading_comp,
    render_error = error_comp,
    render_success = success_comp
}
Main.display_html(html2) #hide
```

### Template Inheritance

Build template inheritance systems:

```@example template-inheritance
using HypertextTemplates
using HypertextTemplates.Elements

@component function base_layout(; title = "Default Title")
    @html begin
        @head begin
            @title $title
            @__slot__ head  # Additional head content
        end
        @body begin
            @header @__slot__ header
            Elements.@main @__slot__     # Default slot for main content
            @footer @__slot__ footer
        end
    end
end

@deftag macro base_layout end

@component function blog_layout(; post)
    @base_layout {title = post.title} begin
        # Main content
        @article begin
            @h1 $(post.title)
            @div {class = "content"} $(SafeString(post.html))
        end

        # Named slots
        head := @meta {name = "author", content = post.author}

        header := @nav @a {href = "/blog"} "← Back to Blog"

        footer := @p "Published: " $(post.date)
    end
end

@deftag macro blog_layout end

# Example blog post
post = (
    title = "Understanding Julia Macros",
    author = "Jane Developer",
    date = "2024-01-15",
    html = "<p>Julia macros are powerful metaprogramming tools...</p>"
)

html = @render @blog_layout {post}
Main.display_html(html) #hide
```

### Lazy Loading Pattern

Load data on-demand during rendering:

```@example lazy-loading
using HypertextTemplates
using HypertextTemplates.Elements

const DATA_CACHE = Dict{Any,Any}()

# Simulate database fetch
function fetch_users_from_db()
    println("Fetching from database...")
    return [
        (name = "Alice", id = 1),
        (name = "Bob", id = 2),
        (name = "Charlie", id = 3)
    ]
end

@component function lazy_data(; data_loader, cache_key = nothing)
    # Load data during render (blocking)
    data = if !isnothing(cache_key) && haskey(DATA_CACHE, cache_key)
        println("Using cached data for key: $cache_key")
        DATA_CACHE[cache_key]
    else
        result = data_loader()
        if !isnothing(cache_key)
            DATA_CACHE[cache_key] = result
        end
        result
    end

    @div {class = "data-container"} begin
        if isempty(data)
            @p {class = "empty"} "No data available"
        else
            @ul begin
                for item in data
                    @li "$(item.name) (ID: $(item.id))"
                end
            end
        end
    end
end

@deftag macro lazy_data end

# First render - fetches data
println("First render:")
html1 = @render @lazy_data {
    cache_key = "users",
    data_loader = () -> fetch_users_from_db()
}
Main.display_html(html1) #hide

# Second render - uses cache
println("\nSecond render:")
html2 = @render @lazy_data {
    cache_key = "users",
    data_loader = () -> fetch_users_from_db()
}
Main.display_html(html2) #hide
```

## Best Practices

1. **Use `@__once__` for dependencies** - Include CSS/JS dependencies once
2. **Create domain-specific tags** - Use `@deftag` for common patterns
3. **Leverage `$` interpolation** - Cleaner than multiple `@text` calls
4. **Cache expensive operations** - Use memoization for complex computations

## Summary

Advanced features in HypertextTemplates.jl enable:

- **Dependency management** with `@__once__`
- **Custom DSLs** via `@deftag`
- **Dynamic rendering** with `@<`
- **Sophisticated patterns** like render props

These features combine to support complex application architectures while maintaining the simplicity and performance that makes HypertextTemplates.jl powerful.
