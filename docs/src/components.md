# Components Guide

Components are the building blocks for creating reusable, maintainable templates in HypertextTemplates.jl. This guide covers everything from basic component creation to advanced patterns.

## Basic Component Definition

Components are defined using the `@component` macro applied to a function:

```julia
@component function greeting(; name = "World")
    @div {class = "greeting"} begin
        @h1 "Hello, " $name "!"
    end
end

# Usage
html = @render @greeting {name = "Julia"}
```

## Component Properties (Props)

Props are passed as keyword arguments to component functions:

### Required Props

```julia
@component function user_card(; username, email)  # Both required
    @div {class = "user-card"} begin
        @h3 $username
        @p $email
    end
end

# Must provide both props
@render @user_card {username = "julia_dev", email = "julia@example.com"}
```

### Optional Props with Defaults

```julia
@component function button(; 
    text = "Click me",
    type = "button",
    variant = "primary",
    disabled = false
)
    classes = "btn btn-" * variant
    @button {type, class = classes, disabled} $text
end

# Use with defaults
@render @button {}

# Override specific props
@render @button {text = "Submit", variant = "success"}
```

### Typed Props

Leverage Julia's type system for safer components:

```julia
@component function product_price(; 
    amount::Number,
    currency::String = "USD",
    decimal_places::Int = 2
)
    formatted = round(amount, digits = decimal_places)
    @span {class = "price"} begin
        @span {class = "currency"} $currency
        @span {class = "amount"} $formatted
    end
end
```

## Slots System

Slots allow components to accept content from their parent, enabling flexible composition.

### Default Slot

The simplest form - a single content area:

```julia
@component function card(; title)
    @div {class = "card"} begin
        @div {class = "card-header"} @h3 $title
        @div {class = "card-body"} begin
            @__slot__  # Default slot receives content
        end
    end
end

# Usage with content
@render @card {title = "User Profile"} begin
    @p "Name: Alice"
    @p "Role: Developer"
end
```

### Named Slots

For more complex layouts with multiple content areas:

```julia
@component function layout()
    @div {class = "layout"} begin
        @header {class = "layout-header"} begin
            @__slot__ header  # Named slot: header
        end
        @main {class = "layout-main"} begin
            @__slot__  # Default slot
        end
        @footer {class = "layout-footer"} begin
            @__slot__ footer  # Named slot: footer
        end
    end
end

# Usage with named slots
@render @layout begin
    # Named slot content uses := syntax
    header := begin
        @h1 "My Application"
        @nav begin
            @a {href = "/"} "Home"
            @a {href = "/about"} "About"
        end
    end
    
    # Default slot content
    @section begin
        @h2 "Welcome"
        @p "This is the main content area."
    end
    
    footer := @p "© 2024 My Company"
end
```

### Conditional Slots

Slots can be conditionally rendered:

```julia
@component function message(; type = "info", dismissible = false)
    @div {class = "message message-$type"} begin
        @__slot__  # Message content
        
        if dismissible
            @button {class = "message-close"} begin
                @__slot__ close_button  # Optional slot
            end
        end
    end
end

# Without close button content
@render @message {type = "warning"} begin
    @p "This is a warning"
end

# With custom close button
@render @message {type = "error", dismissible = true} begin
    @p "An error occurred"
    close_button := @span "×"
end
```

### Slot Fallbacks

Provide default content when slots are empty:

```julia
@component function avatar(; src = nothing, alt = "")
    @div {class = "avatar"} begin
        if !isnothing(src)
            @img {src, alt}
        else
            @div {class = "avatar-placeholder"} begin
                # Show slot content or default
                @__slot__
                # Note: You'll need to check if slot was provided
                # This is a simplified example
            end
        end
    end
end
```

## Component Composition

Components can use other components, enabling powerful composition patterns:

### Basic Composition

```julia
@component function nav_link(; href, active = false)
    class = active ? "nav-link active" : "nav-link"
    @a {href, class} @__slot__
end

@component function navbar(; links, current_path = "/")
    @nav {class = "navbar"} begin
        @ul begin
            for link in links
                @li begin
                    @nav_link {
                        href = link.href,
                        active = link.href == current_path
                    } begin
                        $link.text
                    end
                end
            end
        end
    end
end

# Usage
links = [
    (href = "/", text = "Home"),
    (href = "/about", text = "About"),
    (href = "/contact", text = "Contact")
]

@render @navbar {links, current_path = "/about"}
```

### Higher-Order Components

Create components that modify behavior of other components:

```julia
@component function with_tooltip(; tooltip, position = "top")
    @div {
        class = "tooltip-wrapper",
        "data-tooltip" := tooltip,
        "data-position" := position
    } begin
        @__slot__
    end
end

# Wrap any content with tooltip
@render @with_tooltip {tooltip = "Click to submit"} begin
    @button "Submit"
end
```

### Component Arrays

Render collections of components:

```julia
@component function todo_item(; task, completed = false)
    @li {class = completed ? "completed" : ""} begin
        @input {type = "checkbox", checked = completed}
        @span $task
    end
end

@component function todo_list(; items)
    @ul {class = "todo-list"} begin
        for item in items
            @todo_item {task = item.task, completed = item.completed}
        end
    end
end
```

## Dynamic Components

Use the `@<` macro to render components dynamically:

### Component as Props

```julia
@component function flexible_layout(; 
    header_component = nothing,
    main_component = article,
    sidebar = true
)
    @div {class = "layout"} begin
        if !isnothing(header_component)
            @<header_component
        end
        
        @<main_component {class = "main-content"} begin
            @__slot__
        end
        
        if sidebar
            @aside {class = "sidebar"} begin
                @__slot__ sidebar
            end
        end
    end
end

# Custom header component
@component function custom_header()
    @header {class = "fancy-header"} begin
        @h1 "My App"
    end
end

# Usage
@render @flexible_layout {
    header_component = custom_header,
    main_component = section
} begin
    @p "Main content here"
    sidebar := @p "Sidebar content"
end
```

### Conditional Component Selection

```julia
@component function alert(; type = "info", message)
    # Select icon based on type
    icon_component = if type == "error"
        error_icon
    elseif type == "warning"
        warning_icon
    else
        info_icon
    end
    
    @div {class = "alert alert-$type"} begin
        @<icon_component
        @p $message
    end
end
```

## Module-Qualified Components

Components can be organized in modules and referenced with qualification:

```julia
module UI
    using HypertextTemplates
    
    @component function button(; variant = "primary")
        @button {class = "ui-button ui-button-$variant"} @__slot__
    end
    
    @component function card()
        @div {class = "ui-card"} @__slot__
    end
end

# Usage with module qualification
@render @div begin
    @UI.card begin
        @h2 "Card Title"
        @UI.button {variant = "secondary"} "Click me"
    end
end
```

## Creating Component Macros

Use `@deftag` to create macro shortcuts for components:

```julia
@component function icon(; name, size = 16)
    @svg {
        class = "icon icon-$name",
        width = size,
        height = size,
        viewBox = "0 0 24 24"
    } begin
        # SVG content would go here
        @use {href = "#icon-$name"}
    end
end

# Create a macro for easier use
@deftag macro icon end

# Now can use as @icon instead of @<icon
@render @button begin
    @icon {name = "save", size = 20}
    " Save"
end
```

## Component Patterns

### Container/Presenter Pattern

Separate logic from presentation:

```julia
# Presenter component (pure UI)
@component function user_list_view(; users, onUserClick = nothing)
    @div {class = "user-list"} begin
        for user in users
            onclick = isnothing(onUserClick) ? nothing : () -> onUserClick(user.id)
            @div {class = "user-item", "data-id" := user.id} begin
                @img {src = user.avatar, alt = user.name}
                @span $user.name
            end
        end
    end
end

# Container component (with logic)
@component function user_list_container()
    users = fetch_users()  # Get data
    
    @user_list_view {
        users = users,
        onUserClick = id -> select_user(id)
    }
end
```

### Compound Components

Related components that work together:

```julia
module Tabs
    using HypertextTemplates
    
    @component function container(; active_tab = 1)
        @div {class = "tabs", "data-active" := active_tab} begin
            @__slot__
        end
    end
    
    @component function list()
        @ul {class = "tab-list", role = "tablist"} begin
            @__slot__
        end
    end
    
    @component function tab(; index, active = false)
        @li {role = "presentation"} begin
            @button {
                role = "tab",
                class = active ? "tab active" : "tab",
                "aria-selected" := active
            } begin
                @__slot__
            end
        end
    end
    
    @component function panels()
        @div {class = "tab-panels"} begin
            @__slot__
        end
    end
    
    @component function panel(; index, active = false)
        @div {
            role = "tabpanel",
            class = active ? "panel active" : "panel",
            hidden = !active
        } begin
            @__slot__
        end
    end
end

# Usage
@render @Tabs.container {active_tab = 2} begin
    @Tabs.list begin
        @Tabs.tab {index = 1, active = false} "Tab 1"
        @Tabs.tab {index = 2, active = true} "Tab 2"
        @Tabs.tab {index = 3, active = false} "Tab 3"
    end
    
    @Tabs.panels begin
        @Tabs.panel {index = 1, active = false} begin
            @p "Content for tab 1"
        end
        @Tabs.panel {index = 2, active = true} begin
            @p "Content for tab 2"
        end
        @Tabs.panel {index = 3, active = false} begin
            @p "Content for tab 3"
        end
    end
end
```

### Renderless Components

Components that provide functionality without specific markup:

```julia
@component function mouse_tracker(; render)
    # This is a conceptual example
    # In practice, you'd need client-side JS
    mouse_position = (x = 0, y = 0)
    
    # Render prop pattern
    @<render {position = mouse_position}
end

# Usage
@render @mouse_tracker {
    render = @component function(; position)
        @div "Mouse at: $(position.x), $(position.y)"
    end
}
```

## Best Practices

### 1. Keep Components Focused

Each component should have a single, clear purpose:

```julia
# Good: Focused components
@component function price_display(; amount, currency = "USD")
    @span {class = "price"} $currency " " $amount
end

@component function product_card(; product)
    @div {class = "product"} begin
        @h3 $product.name
        @price_display {amount = product.price, currency = product.currency}
    end
end
```

### 2. Use Props for Configuration

Make components flexible through props:

```julia
@component function data_table(;
    data,
    columns,
    striped = true,
    hoverable = true,
    bordered = false
)
    classes = [
        "table",
        striped ? "table-striped" : nothing,
        hoverable ? "table-hover" : nothing,
        bordered ? "table-bordered" : nothing
    ] |> filter(!isnothing) |> join(_, " ")
    
    @table {class = classes} begin
        # Table implementation
    end
end
```

### 3. Document Components

Add docstrings to components:

```julia
"""
    @alert(; type, title, message, dismissible)

Display an alert message with optional dismiss button.

# Arguments
- `type::String = "info"`: Alert type (info, warning, error, success)
- `title::String`: Alert title
- `message::String`: Alert message body  
- `dismissible::Bool = false`: Whether alert can be dismissed
"""
@component function alert(; type = "info", title, message, dismissible = false)
    # Implementation
end
```

### 4. Consider Performance

For frequently rendered components, optimize:

```julia
# Precompute static values
const BUTTON_CLASSES = Dict(
    :primary => "btn btn-primary",
    :secondary => "btn btn-secondary",
    :danger => "btn btn-danger"
)

@component function button(; variant = :primary)
    @button {class = BUTTON_CLASSES[variant]} @__slot__
end
```

### 5. Error Handling

Handle edge cases gracefully:

```julia
@component function safe_image(; src, alt = "", fallback = "/placeholder.png")
    image_src = isempty(src) ? fallback : src
    @img {src = image_src, alt, onerror = "this.src='$fallback'"}
end
```

## Summary

Components in HypertextTemplates.jl provide:

- **Reusability** through parameterized templates
- **Composition** via nesting and slots
- **Type safety** with Julia's type system
- **Flexibility** through props and dynamic rendering
- **Organization** via modules and namespaces

Master these patterns to build maintainable, scalable web applications with HypertextTemplates.jl.