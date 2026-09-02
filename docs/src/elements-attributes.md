# HTML Elements & Attributes

This guide covers how to work with HTML elements and their attributes in HypertextTemplates.jl.

## HTML Element Macros

HypertextTemplates provides macros for all standard HTML elements. Import them from the `Elements` submodule:

```julia
using HypertextTemplates
using HypertextTemplates.Elements
```

### Common Elements

`Elements` covers the HTML5 element set, each one a macro named after its tag.
Anything outside that set, SVG included, is defined with [`@element`](@ref):

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

Main.display_html(html) #hide
```

## Attribute Syntax

### Basic Attributes

Attributes are specified using `{}` with key-value pairs:

```@example basic-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# Single attribute
@render @div {id = "main"} "Content"
Main.display_html(ans) #hide
```

```@example basic-attrs
# Multiple attributes
@render @a {href = "/home", class = "nav-link", target = "_blank"} "Home"
Main.display_html(ans) #hide
```

```@example computed-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# Computed attributes
width = 300
height = 200
@render @img {src = "/photo.jpg", width, height, alt = "Photo"}

Main.display_html(ans) #hide
```

### Attribute Name Variations

#### Standard Identifiers

For valid Julia identifiers, use simple syntax:

```@example standard-ids
using HypertextTemplates
using HypertextTemplates.Elements

html = @render @input {type = "text", name = "username", placeholder = "Enter username"}

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

@render @input {type = "range", min = 0, max = 100, step = 5}

Main.display_html(ans) #hide
```

#### Booleans

Boolean attributes follow HTML5 semantics:

```@example booleans-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# true renders just the attribute name
@render @input {type = "checkbox", checked = true}

Main.display_html(ans) #hide
```

```@example booleans-attrs
# false omits the attribute entirely  
@render @input {type = "checkbox", checked = false}

Main.display_html(ans) #hide
```

```@example booleans-attrs
# Dynamic boolean
is_loading = true
@render @button {disabled = is_loading} "Submit"

Main.display_html(ans) #hide
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

Main.display_html(html1) #hide
```

```@example nothing-values
# Test with true condition
condition = true
optional_class = condition ? "active" : nothing
html2 = @render @div {class = optional_class} "Content"

Main.display_html(html2) #hide
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

Main.display_html(ans) #hide
```

#### Spreading Attributes

Use `...` to spread attributes from collections:

```@example spreading-attrs
using HypertextTemplates
using HypertextTemplates.Elements

# From NamedTuple
common_attrs = (class = "btn", type = "button")
@render @button {id = "submit", common_attrs...} "Submit"

Main.display_html(ans) #hide
```

```@example spreading-dict
using HypertextTemplates
using HypertextTemplates.Elements

# From Dict
attrs = Dict(Symbol("data-value") => "123", Symbol("data-label") => "test")
@render @div {class = "widget", attrs...} "Content"

Main.display_html(ans) #hide
```

```@example spreading-combine
using HypertextTemplates
using HypertextTemplates.Elements

# Combining multiple sources
base = (; class = "card")
extra = (; id = "main", role = "region")
@render @article {base..., extra..., class = "card featured"} "Content"
# Note: Later values override earlier ones

Main.display_html(ans) #hide
```

### Conditional Attributes

Common patterns for conditional attributes:

```@example conditional-ternary
using HypertextTemplates
using HypertextTemplates.Elements

# Using ternary operator
isactive = true
html = @render @div {class = isactive ? "active" : "inactive"} "Status"

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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
        if (data.value > 100 && data.value < 200) { ready(); }
    """

    @style """
        .custom-class {
            color: blue;
            font-size: 16px;
        }
    """
end

Main.display_html(html) #hide
```

A browser decodes no entity inside a script or a style, so `&lt;` there is the
five characters it spells rather than a `<`. Children of these two elements are
written without entity escaping for that reason, literal and interpolated
alike, and what cannot appear in them is whatever would take the parser back
out of the element. In a style that is only its own end tag, `</style`; in a
script, `</script` and `<!--`, since a comment puts the parser in a state where
the element's own `</script>` no longer ends it. Both are written with a
backslash after the `<`, which JavaScript reads as the sequence itself inside a
string. An end tag for any other element is left alone, since the parser reads
the name after the `</` and hands the characters back as text unless they name
the element that is open:

```@example script-style
comment = "</script><img src=x onerror=alert(1)>"
html = @render @script "var comment = \"$comment\";"

Main.display_html(html) #hide
```

Whatever a `@script` or a `@style` writes directly is that element's raw text:
literal children, interpolated values, `@text`, and content passed into a slot
the element renders. A component can therefore take a script body from its
caller and have it come out as JavaScript:

```@example script-style
@component function inline_script()
    @script @__slot__
end

@deftag macro inline_script end

html = @render @inline_script "if (a < b && c) { ready(); }"

Main.display_html(html) #hide
```

The innermost element is what decides, so an element nested inside a script or
a style starts markup again and its own children are escaped. That is what a
template script needs. A `<script type="text/template">` block holds markup
rather than a program: the page reads it back out and parses it as HTML, and
the parse decodes any entity in it, so a value that reached the block from a
user has to be escaped for that later parse or it becomes markup in the page
the template is expanded into.

```@example script-style
user_input = "<img src=x onerror=alert(1)>"
html = @render @script {type = "text/template"} @div $user_input

Main.display_html(html) #hide
```

The nested element's own tags reach the page as they were written, so the block
is still markup when the page parses it back.

A [`SafeString`](@ref) written in a script or a style is not escaped either,
and the same sequences are neutralised in it. Trusted JSON assembled from a
user's data can carry a `</script`, and that would end the element and leave
the rest of the value as markup. `<\/` is what JavaScript reads as `</` inside
a string and is a valid JSON string escape, so what the script runs and what it
parses are unchanged. The comment opener is the exception: `<\!--` is not a
JSON escape, so a value carrying one will not parse back.

```@example script-style
payload = SafeString("{\"bio\": \"</script><img src=x onerror=alert(1)>\"}")
html = @render @script "var data = " $payload ";"

Main.display_html(html) #hide
```

`@<` given a variable is the one place the element is not known while the macro
expands. Which element it renders only arrives with the render, so its children
are escaped the way every other element's are.

### SVG Elements

SVG tags are not part of `Elements`. Define the ones you use with `@element`
and they behave like any other element:

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

Main.display_html(html) #hide
```

## Escaping and Security

### Automatic Escaping

Attribute values from variables are automatically escaped:

```@example attr-escaping
using HypertextTemplates
using HypertextTemplates.Elements

user_input = "\" onclick=\"alert('xss')\""
html = @render @div {title = user_input} "Safe"
# Output shows escaped attributes

Main.display_html(html) #hide
```

Element content goes through the same treatment:

```@example attr-escaping
unsafe = "<script>alert('xss')</script>"
html = @render @p $unsafe

Main.display_html(html) #hide
```

### Escape Rules

1. String literals in templates ARE escaped, once, during macro expansion
2. Variables and expressions with `$` or `@text` ARE escaped
3. Attribute values from variables ARE escaped
4. Element content from components is already rendered (not double-escaped)
5. Content written directly in a `@script` or a `@style` is not entity-escaped,
   since those two hold raw text; that element's own end tag is neutralised
   instead, in a `SafeString` as much as in anything else. An element nested
   inside one is markup again and its children ARE escaped

Escaping is written to stay off the allocator: a string with no special characters takes a fast path that writes it through unchanged, and only a string that needs replacing pays for one.

### Escaping a Literal at Macro Expansion

A string literal written straight into a template is escaped during macro expansion, so the render writes a constant and pays nothing. A string held in a variable is escaped on every render instead. The `@esc_str` string macro closes that gap: it escapes the literal once during expansion and hands back a [`SafeString`](@ref), which the renderer writes without escaping it again.

```@example attr-escaping
html = @render @p $(esc"5 > 3 && 2 < 4")

Main.display_html(html) #hide
```

### Pre-escaped Content

A value wrapped in `SafeString` is written as it stands, in an attribute as
much as in element content. Wrap only markup you produced yourself: a value
that reached you from a user and goes out through a `SafeString` is an
injection.

```@example pre-escaped
using HypertextTemplates
using HypertextTemplates.Elements

safe_attr = SafeString("complex&value")
html = @render @div {"data-value" := safe_attr} "Content"

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
```

```@example semantic-html
# Article with semantic structure
html2 = @render @article begin
    @header @h1 "Article Title"
    @section @p "Content..."
    @footer @button {type = "submit"} "Submit"
end

Main.display_html(html2) #hide
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

Main.display_html(html) #hide
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

Main.display_html(html) #hide
```
