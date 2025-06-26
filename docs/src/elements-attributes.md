# HTML Elements & Attributes

This guide covers how to work with HTML elements and their attributes in HypertextTemplates.jl.

## HTML Element Macros

HypertextTemplates provides macros for all standard HTML elements. Import them from the `Elements` submodule:

```julia
using HypertextTemplates
using HypertextTemplates.Elements
```

### Common Elements

```julia
# Structural elements
@div @section @article @aside @header @footer @main @nav

# Text content
@h1 @h2 @h3 @h4 @h5 @h6 @p @span @blockquote @pre @code

# Lists
@ul @ol @li @dl @dt @dd

# Links and media
@a @img @video @audio @picture @source

# Forms
@form @input @button @select @option @textarea @label @fieldset

# Tables
@table @thead @tbody @tfoot @tr @th @td @caption @colgroup @col

# And many more...
```

### Complete Example

```julia
@render @article begin
    @header begin
        @h1 "Article Title"
        @p {class = "meta"} "Published on " @time {datetime = "2024-01-01"} "January 1, 2024"
    end
    
    @section begin
        @p "First paragraph of content..."
        @figure begin
            @img {src = "/image.jpg", alt = "Description"}
            @figcaption "Image caption"
        end
    end
    
    @footer begin
        @p "Article footer with " @a {href = "/more"} "related links"
    end
end
```

## Attribute Syntax

### Basic Attributes

Attributes are specified using `{}` with key-value pairs:

```julia
# Single attribute
@div {id = "main"} "Content"

# Multiple attributes
@a {href = "/home", class = "nav-link", target = "_blank"} "Home"

# Computed attributes
width = 300
height = 200
@img {src = "/photo.jpg", width, height, alt = "Photo"}
```

### Attribute Name Variations

#### Standard Identifiers

For valid Julia identifiers, use simple syntax:

```julia
@input {type = "text", name = "username", placeholder = "Enter username"}
```

#### Non-Standard Names

For attributes with special characters, use string literals with `:=`:

```julia
# Alpine.js attributes
@div {"x-data" := "{ open: false }"} begin
    @button {"@click" := "open = !open"} "Toggle"
    @div {"x-show" := "open"} "Hidden content"
end

# HTMX attributes
@button {
    "hx-post" := "/api/click",
    "hx-target" := "#result",
    "hx-swap" := "innerHTML"
} "Click me"

# Custom data attributes
@div {
    "data-user-id" := "123",
    "data-role" := "admin",
    "aria-label" := "User profile"
}
```

### Attribute Value Types

#### Strings

```julia
@div {class = "container", id = "main"}
```

#### Numbers

Numbers are automatically converted to strings:

```julia
@img {width = 640, height = 480}
@input {type = "range", min = 0, max = 100, step = 5}
```

#### Booleans

Boolean attributes follow HTML5 semantics:

```julia
# true renders just the attribute name
@input {type = "checkbox", checked = true}
# <input type="checkbox" checked>

# false omits the attribute entirely  
@input {type = "checkbox", checked = false}
# <input type="checkbox">

@button {disabled = is_loading} "Submit"
```

#### Nothing/Missing

`nothing` values are omitted:

```julia
optional_class = condition ? "active" : nothing
@div {class = optional_class} "Content"
# If condition is false: <div>Content</div>
# If condition is true: <div class="active">Content</div>
```

### Attribute Shortcuts

#### Variable Name Matching

When variable names match attribute names:

```julia
id = "user-123"
class = "profile-card"
role = "article"

# Instead of {id = id, class = class, role = role}
@div {id, class, role} "Content"
```

#### Spreading Attributes

Use `...` to spread attributes from collections:

```julia
# From NamedTuple
common_attrs = (class = "btn", type = "button")
@button {id = "submit", common_attrs...} "Submit"

# From Dict
attrs = Dict("data-value" => "123", "data-label" => "test")
@div {class = "widget", attrs...} "Content"

# Combining multiple sources
base = (class = "card")
extra = (id = "main", role = "region")
@article {base..., extra..., class = "card featured"} "Content"
# Note: Later values override earlier ones
```

### Conditional Attributes

Common patterns for conditional attributes:

```julia
# Using ternary operator
@div {class = isactive ? "active" : "inactive"} "Status"

# Using nothing for optional attributes
@a {
    href = "/page",
    target = external ? "_blank" : nothing,
    rel = external ? "noopener" : nothing
} "Link"

# Building class lists
classes = [
    "btn",
    size == :large ? "btn-lg" : "btn-sm",
    variant == :primary ? "btn-primary" : "btn-secondary",
    disabled ? "disabled" : nothing
] |> filter(!isnothing) |> join(" ")

@button {class = classes, disabled} "Click"
```

## Custom Elements

### Defining Custom Elements

Use `@element` to define custom HTML elements:

```julia
# Define a web component
@element "my-component" my_component

# Use it
@render @<my_component {prop = "value"} "Content"
# <my-component prop="value">Content</my-component>
```

### Creating Element Macros

Use `@deftag` to create macro shortcuts:

```julia
# Define the element
@element "custom-button" custom_button

# Create a macro for it
@deftag macro custom_button end

# Now use as a regular macro
@render @custom_button {variant = "primary"} "Click me"
```

### Web Components Example

```julia
# Define common web components
@element "sl-button" sl_button
@element "sl-input" sl_input
@element "sl-card" sl_card

@deftag macro sl_button end
@deftag macro sl_input end  
@deftag macro sl_card end

# Use Shoelace components
@render @sl_card begin
    @div {slot = "header"} "Card Title"
    @p "Card content"
    @div {slot = "footer"} begin
        @sl_button {variant = "primary"} "Save"
    end
end
```

## Special Elements

### Void Elements

Self-closing elements work automatically:

```julia
@img {src = "/photo.jpg", alt = ""}
@br
@hr {class = "divider"}
@input {type = "text", name = "field"}
@meta {charset = "UTF-8"}
```

### Raw HTML with Script and Style

Script and style elements preserve their content:

```julia
@script {type = "text/javascript"} """
    console.log("This is preserved as-is");
    const data = { value: 123 };
"""

@style """
    .custom-class {
        color: blue;
        font-size: 16px;
    }
"""
```

### SVG Elements

SVG elements work like regular elements:

```julia
@svg {width = "100", height = "100", viewBox = "0 0 100 100"} begin
    @circle {cx = "50", cy = "50", r = "40", fill = "blue"}
    @rect {x = "10", y = "10", width = "30", height = "30", fill = "red"}
    @path {d = "M 10 10 L 90 90", stroke = "black", "stroke-width" := "2"}
end
```

## Escaping and Security

### Automatic Escaping

Attribute values from variables are automatically escaped:

```julia
user_input = "\" onclick=\"alert('xss')\""
@div {title = user_input} "Safe"
# <div title="&quot; onclick=&quot;alert('xss')&quot;">Safe</div>
```

### Literal Values

String literals in the template are NOT escaped:

```julia
# This is trusted content, not escaped
@div {class = "foo&bar"} "Content"
# <div class="foo&bar">Content</div>
```

### Pre-escaped Content

Use `SafeString` for pre-escaped attribute values:

```julia
safe_attr = SafeString("complex&value")
@div {data = safe_attr}
```

## Advanced Patterns

### Dynamic Attribute Names

Build attributes programmatically:

```julia
@component function dynamic_attrs(; prefix = "data", values = Dict())
    attrs = Dict()
    for (key, value) in values
        attrs["$prefix-$key"] = value
    end
    
    @div {attrs...} @__slot__
end
```

### Attribute Builders

Create reusable attribute sets:

```julia
function button_attrs(; variant = "primary", size = "md", disabled = false)
    classes = ["btn", "btn-$variant", "btn-$size"]
    disabled && push!(classes, "disabled")
    
    return (
        class = join(classes, " "),
        disabled = disabled,
        type = "button"
    )
end

# Usage
@button {button_attrs(variant = "danger", size = "lg")...} "Delete"
```

### ARIA Attributes

Accessibility attributes using proper patterns:

```julia
@component function accessible_modal(; open = false, title_id = "modal-title")
    @div {
        role = "dialog",
        "aria-modal" := "true",
        "aria-labelledby" := title_id,
        "aria-hidden" := !open
    } begin
        @h2 {id = title_id} @__slot__ title
        @div @__slot__
    end
end
```

### Style Objects

Building inline styles:

```julia
function style_string(; styles...)
    parts = String[]
    for (prop, value) in pairs(styles)
        prop_str = replace(string(prop), "_" => "-")
        push!(parts, "$prop_str: $value")
    end
    return join(parts, "; ")
end

# Usage
@div {
    style = style_string(
        background_color = "blue",
        padding = "1rem",
        border_radius = "0.5rem"
    )
} "Styled div"
```

### Complex Data Attributes

Working with structured data attributes:

```julia
# For complex data, use JSON serialization
using JSON

@component function interactive_widget(; config)
    @div {
        class = "widget",
        "data-config" := JSON.json(config),
        "data-initialized" := "false"
    } begin
        @__slot__
    end
end

# Usage
@render @interactive_widget {
    config = Dict(
        "theme" => "dark",
        "features" => ["search", "filter"],
        "maxItems" => 50
    )
} begin
    @p "Widget content"
end
```

## Best Practices

### 1. Use Semantic HTML

Choose elements that convey meaning:

```julia
# Good: Semantic elements
@nav @ul @li @a {href = "/"} "Home"
@article @header @h1 "Title"
@button {type = "submit"} "Submit"

# Avoid: Non-semantic elements for structure
@div {onclick = "handleClick()"} "Click me"  # Use @button instead
```

### 2. Accessibility First

Always include accessibility attributes:

```julia
@img {src = "/logo.png", alt = "Company logo"}
@button {type = "button", "aria-label" := "Close dialog"} "×"
@input {type = "email", id = "email", "aria-describedby" := "email-error"}
```

### 3. Consistent Naming

Use consistent patterns for classes and IDs:

```julia
# Component-based naming
@div {class = "card"} begin
    @div {class = "card__header"} "Title"
    @div {class = "card__body"} "Content"
    @button {class = "card__action card__action--primary"} "Save"
end
```

### 4. Avoid Inline Styles

Prefer classes over inline styles:

```julia
# Good: Use classes
@div {class = "alert alert-warning"} "Warning message"

# Avoid: Inline styles (except when dynamic)
@div {style = "color: orange; padding: 1rem;"} "Warning"
```

### 5. Data Attributes for JavaScript

Use data attributes for JavaScript hooks:

```julia
@button {
    class = "btn btn-primary",
    "data-action" := "submit-form",
    "data-form-id" := "user-form",
    "data-confirm" := "true"
} "Submit"
```

## Summary

HypertextTemplates.jl provides a comprehensive and flexible system for working with HTML elements and attributes:

- All standard HTML elements available as macros
- Flexible attribute syntax with `{}` notation
- Support for dynamic and computed attributes
- Automatic security through escaping
- Custom element definition support
- Advanced patterns for complex use cases

The system is designed to feel natural to Julia developers while providing all the features needed for modern web development.