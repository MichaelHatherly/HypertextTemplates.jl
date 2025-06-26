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

```@example complete-article
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @article begin
    @header begin
        @h1 "Article Title"
        @p {class = "meta"} "Published on " Elements.@time {datetime = "2024-01-01"} "January 1, 2024"
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

println(html)
```

## Attribute Syntax

### Basic Attributes

Attributes are specified using `{}` with key-value pairs:

```@example basic-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# Single attribute
println(@render @div {id = "main"} "Content")

# Multiple attributes
println(@render @a {href = "/home", class = "nav-link", target = "_blank"} "Home")
```

```@example computed-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# Computed attributes
width = 300
height = 200
@render @img {src = "/photo.jpg", width, height, alt = "Photo"}
```

### Attribute Name Variations

#### Standard Identifiers

For valid Julia identifiers, use simple syntax:

```@example standard-ids
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @input {type = "text", name = "username", placeholder = "Enter username"}
println(html)
```

#### Non-Standard Names

For attributes with special characters, use string literals with `:=`:

```@example alpine-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# Alpine.js attributes
html = @render @div {"x-data" := "{ open: false }"} begin
    @button {"@click" := "open = !open"} "Toggle"
    @div {"x-show" := "open"} "Hidden content"
end
println(html)
```

```@example htmx-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# HTMX attributes
html = @render @button {
    "hx-post" := "/api/click",
    "hx-target" := "#result",
    "hx-swap" := "innerHTML"
} "Click me"
println(html)
```

```@example data-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# Custom data attributes
html = @render @div {
    "data-user-id" := "123",
    "data-role" := "admin",
    "aria-label" := "User profile"
} "Content"
println(html)
```

### Attribute Value Types

#### Strings

```julia
@div {class = "container", id = "main"}
```

#### Numbers

Numbers are automatically converted to strings:

```@example numbers
using HypertextTemplates
using HypertextTemplates.Elements

println(@render @img {width = 640, height = 480})
println(@render @input {type = "range", min = 0, max = 100, step = 5})
```

#### Booleans

Boolean attributes follow HTML5 semantics:

```@example booleans-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# true renders just the attribute name
println(@render @input {type = "checkbox", checked = true})

# false omits the attribute entirely  
println(@render @input {type = "checkbox", checked = false})

# Dynamic boolean
is_loading = true
println(@render @button {disabled = is_loading} "Submit")
```

#### Nothing/Missing

`nothing` values are omitted:

```@example nothing-values
using HypertextTemplates
using HypertextTemplates.Elements

# Test with false condition
condition = false
optional_class = condition ? "active" : nothing
html1 = @render @div {class = optional_class} "Content"
println("With condition=false: ", html1)

# Test with true condition
condition = true
optional_class = condition ? "active" : nothing
html2 = @render @div {class = optional_class} "Content"
println("With condition=true: ", html2)
```

### Attribute Shortcuts

#### Variable Name Matching

When variable names match attribute names:

```@example shortcuts-vars
using HypertextTemplates
using HypertextTemplates.Elements

id = "user-123"
class = "profile-card"
role = "article"

# Instead of {id = id, class = class, role = role}
@render @div {id, class, role} "Content"
```

#### Spreading Attributes

Use `...` to spread attributes from collections:

```@example spreading-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# From NamedTuple
common_attrs = (class = "btn", type = "button")
println(@render @button {id = "submit", common_attrs...} "Submit")
```

```@example spreading-dict
using HypertextTemplates
using HypertextTemplates.Elements

# From Dict
attrs = Dict(Symbol("data-value") => "123", Symbol("data-label") => "test")
println(@render @div {class = "widget", attrs...} "Content")
```

```@example spreading-combine
using HypertextTemplates
using HypertextTemplates.Elements

# Combining multiple sources
base = (; class = "card")
extra = (; id = "main", role = "region")
@render @article {base..., extra..., class = "card featured"} "Content"
# Note: Later values override earlier ones
```

### Conditional Attributes

Common patterns for conditional attributes:

```@example conditional-ternary
using HypertextTemplates
using HypertextTemplates.Elements

# Using ternary operator
isactive = true
html = @render @div {class = isactive ? "active" : "inactive"} "Status"
println(html)
```

```@example conditional-optional
using HypertextTemplates
using HypertextTemplates.Elements

# Using nothing for optional attributes
external = true
html = @render @a {
    href = "/page",
    target = external ? "_blank" : nothing,
    rel = external ? "noopener" : nothing
} "External Link"
println(html)
```

```@example conditional-classes
using HypertextTemplates
using HypertextTemplates.Elements

# Building class lists
size = :large
variant = :primary
disabled = true

classes = [
    "btn",
    size == :large ? "btn-lg" : "btn-sm",
    variant == :primary ? "btn-primary" : "btn-secondary",
    disabled ? "disabled" : nothing
] |> x -> filter(!isnothing, x) |> x -> join(x, " ")

html = @render @button {class = classes, disabled} "Click"
println(html)
```

## Custom Elements

### Defining Custom Elements

Use `@element` to define custom HTML elements:

```@example custom-element
using HypertextTemplates
using HypertextTemplates.Elements

# Define a web component
@element "my-component" my_component

# Use it
html = @render @<my_component {prop = "value"} "Content"
println(html)
# Output: <my-component prop="value">Content</my-component>
```

### Creating Element Macros

Use `@deftag` to create macro shortcuts:

```@example element-macros
using HypertextTemplates
using HypertextTemplates.Elements

# Define the element
@element "custom-button" custom_button

# Create a macro for it
@deftag macro custom_button end

# Now use as a regular macro
html = @render @custom_button {variant = "primary"} "Click me"
println(html)
```

### Web Components Example

```@example web-components
using HypertextTemplates
using HypertextTemplates.Elements

# Define common web components
@element "sl-button" sl_button
@element "sl-input" sl_input
@element "sl-card" sl_card

@deftag macro sl_button end
@deftag macro sl_input end  
@deftag macro sl_card end

# Use Shoelace components
html = @render @sl_card begin
    @div {slot = "header"} "Card Title"
    @p "Card content"
    @div {slot = "footer"} begin
        @sl_button {variant = "primary"} "Save"
    end
end

println(html)
```

## Special Elements

### Void Elements

Self-closing elements work automatically:

```@example void-elements
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @div begin
    @img {src = "/photo.jpg", alt = ""}
    @br
    @hr {class = "divider"}
    @input {type = "text", name = "field"}
    @meta {charset = "UTF-8"}
end

println(html)
```

### Raw HTML with Script and Style

Script and style elements preserve their content:

```@example script-style
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @div begin
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
end

println(html)
```

### SVG Elements

SVG elements work like regular elements:

```@example svg-elements
using HypertextTemplates
using HypertextTemplates.Elements

@element "svg" svg
@element "circle" circle
@element "rect" rect
@element "path" path

@deftag macro svg end
@deftag macro circle end
@deftag macro rect end
@deftag macro path end

html = @render @svg {width = "100", height = "100", viewBox = "0 0 100 100"} begin
    @circle {cx = "50", cy = "50", r = "40", fill = "blue"}
    @rect {x = "10", y = "10", width = "30", height = "30", fill = "red"}
    @path {d = "M 10 10 L 90 90", stroke = "black", "stroke-width" := "2"}
end

println(html)
```

## Escaping and Security

### Automatic Escaping

Attribute values from variables are automatically escaped:

```@example auto-escaping
using HypertextTemplates
using HypertextTemplates.Elements

user_input = "\" onclick=\"alert('xss')\""
html = @render @div {title = user_input} "Safe"
println(html)
# Output shows escaped attributes
```

### Pre-escaped Content

Use `SafeString` for pre-escaped attribute values:

```@example pre-escaped
using HypertextTemplates
using HypertextTemplates.Elements

safe_attr = SafeString("complex&value")
html = @render @div {"data-value" := safe_attr} "Content"
println(html)
```

## Advanced Patterns

### Dynamic Attribute Names

Build attributes programmatically:

```@example dynamic-attrs
using HypertextTemplates
using HypertextTemplates.Elements

@component function dynamic_attrs(; prefix = "data", values = Dict())
    attrs = Dict()
    for (key, value) in values
        attrs[Symbol("$prefix-$key")] = value
    end
    
    @div {attrs...} @__slot__
end

@deftag macro dynamic_attrs end

# Usage example
html = @render @dynamic_attrs {
    prefix = "data",
    values = Dict("id" => "123", "name" => "test")
} "Content with dynamic attributes"

println(html)
```

### ARIA Attributes

Accessibility attributes using proper patterns:

```@example aria-attrs
using HypertextTemplates
using HypertextTemplates.Elements

@component function accessible_modal(; open = false, title_id = "modal-title")
    @div {
        role = "dialog",
        "aria-modal" := "true",
        "aria-labelledby" := title_id,
        "aria-hidden" := !open
    } begin
        @h2 {id = title_id} begin
            @__slot__ title
        end
        @div begin
            @__slot__
        end
    end
end

@deftag macro accessible_modal end

# Usage example
html = @render @accessible_modal {open = true} begin
    title := "Important Dialog"
    @p "This is the modal content."
end

println(html)
```

### Style Objects

Building inline styles:

```@example style-objects
using HypertextTemplates
using HypertextTemplates.Elements

function style_string(; styles...)
    parts = String[]
    for (prop, value) in pairs(styles)
        prop_str = replace(string(prop), "_" => "-")
        push!(parts, "$prop_str: $value")
    end
    return join(parts, "; ")
end

# Usage
html = @render @div {
    style = style_string(
        background_color = "blue",
        padding = "1rem",
        border_radius = "0.5rem"
    )
} "Styled div"

println(html)
```

## Best Practices

### 1. Use Semantic HTML

Choose elements that convey meaning:

```@example semantic-html
using HypertextTemplates
using HypertextTemplates.Elements

# Good: Semantic elements
html = @render @nav begin
    @ul begin
        @li @a {href = "/"} "Home"
        @li @a {href = "/about"} "About"
    end
end
println("Semantic navigation:")
println(html)

# Article with semantic structure
html2 = @render @article begin
    @header @h1 "Article Title"
    @section @p "Content..."
    @footer @button {type = "submit"} "Submit"
end
println("\nSemantic article:")
println(html2)
```

### 2. Accessibility First

Always include accessibility attributes:

```@example accessibility
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @div begin
    @img {src = "/logo.png", alt = "Company logo"}
    @button {type = "button", "aria-label" := "Close dialog"} "×"
    @input {type = "email", id = "email", "aria-describedby" := "email-error"}
    @span {id = "email-error", class = "error"} "Please enter a valid email"
end

println(html)
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

```@example data-js-attrs
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @button {
    class = "btn btn-primary",
    "data-action" := "submit-form",
    "data-form-id" := "user-form",
    "data-confirm" := "true"
} "Submit"

println(html)
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
