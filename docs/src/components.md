# Components Guide

Components are the building blocks for creating reusable, maintainable templates in HypertextTemplates.jl. This guide covers everything from basic component creation to advanced patterns.

## Basic Component Definition

Components are defined using the `@component` macro applied to a function:

```@example basic-component
using HypertextTemplates
using HypertextTemplates.Elements

@component function greeting(; name = "World")
    @div {class = "greeting"} begin
        @h1 "Hello, " $name "!"
    end
end

# Important: Define a macro for the component
@deftag macro greeting end

# Now you can use it
html = @render @greeting {name = "Julia"}

Main.display_html(html) #hide
```

```@example basic-component
# Also works with default value
html2 = @render @greeting

Main.display_html(html2) #hide
```

## Component Properties (Props)

Props are passed as keyword arguments to component functions:

### Required Props

Omit default values to make props required:

```@example required-props
using HypertextTemplates
using HypertextTemplates.Elements

@component function user_card(; username, email)  # Both required
    @div {class = "user-card"} begin
        @h3 $username
        @p $email
    end
end

@deftag macro user_card end

# Must provide both props
html = @render @user_card {username = "julia_dev", email = "julia@example.com"}
Main.display_html(html) #hide
```

### Optional Props with Defaults

```@example optional-props
using HypertextTemplates
using HypertextTemplates.Elements

@component function my_button(; 
    text = "Click me",
    type = "button",
    variant = "primary",
    disabled = false
)
    classes = "btn btn-" * variant
    @button {type, class = classes, disabled} $text
end

@deftag macro my_button end

# Use with defaults
@render @my_button {}

Main.display_html(ans) #hide
```

```@example optional-props
# Override specific props
@render @my_button {text = "Submit", variant = "success"}

Main.display_html(ans) #hide
```

```@example optional-props
# With disabled state
@render @my_button {text = "Loading...", disabled = true}
Main.display_html(ans) #hide
```

### Typed Props

Leverage Julia's type system for safer components:

```@example typed-props
using HypertextTemplates
using HypertextTemplates.Elements

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

@deftag macro product_price end

# Usage with different types
@render @product_price {amount = 29.99}

Main.display_html(ans) #hide
```

```@example typed-props
@render @product_price {amount = 100, currency = "EUR", decimal_places = 0}

Main.display_html(ans) #hide
```

## Slots System

Slots allow components to accept content from their parent, enabling flexible composition.

### Default Slot

The simplest form - a single content area:

```@example default-slot
using HypertextTemplates
using HypertextTemplates.Elements

@component function card(; title)
    @div {class = "card"} begin
        @div {class = "card-header"} @h3 $title
        @div {class = "card-body"} begin
            @__slot__  # Default slot receives content
        end
    end
end

@deftag macro card end

# Usage with content
html = @render @card {title = "User Profile"} begin
    @p "Name: Alice"
    @p "Role: Developer"
end
Main.display_html(html) #hide
```

### Named Slots

For more complex layouts with multiple content areas:

```@example named-slots
using HypertextTemplates
using HypertextTemplates.Elements

@component function layout()
    @div {class = "layout"} begin
        @header {class = "layout-header"} begin
            @__slot__ header  # Named slot: header
        end
        @article {class = "layout-main"} begin
            @__slot__  # Default slot
        end
        @footer {class = "layout-footer"} begin
            @__slot__ footer  # Named slot: footer
        end
    end
end

@deftag macro layout end

# Usage with named slots
html = @render @layout begin
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

Main.display_html(html) #hide
```

### Conditional Slots

Slots can be conditionally rendered:

```@example conditional-slots
using HypertextTemplates
using HypertextTemplates.Elements

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

@deftag macro message end

# Without close button content
html1 = @render @message {type = "warning"} begin
    @p "This is a warning"
end

Main.display_html(html1) #hide
```

```@example conditional-slots
# With custom close button
html2 = @render @message {type = "error", dismissible = true} begin
    @p "An error occurred"
    close_button := @span "×"
end

Main.display_html(html2) #hide
```

### Slot Fallbacks

Provide default content when slots are empty:

```@example slot-fallbacks
using HypertextTemplates
using HypertextTemplates.Elements

@component function avatar(; src = nothing, alt = "")
    @div {class = "avatar"} begin
        if !isnothing(src)
            @img {src, alt}
        else
            @div {class = "avatar-placeholder"} begin
                # Show slot content (initials)
                @__slot__
            end
        end
    end
end

@deftag macro avatar end

# With image
html1 = @render @avatar {src = "/user.jpg", alt = "User"}

Main.display_html(html1) #hide
```

```@example slot-fallbacks
# With placeholder (slot content)
html2 = @render @avatar {alt = "John Doe"} begin
    @span "JD"  # Initials as fallback
end

Main.display_html(html2) #hide
```

## Component Composition

Components can use other components, enabling powerful composition patterns:

### Basic Composition

```@example component-composition
using HypertextTemplates
using HypertextTemplates.Elements

@component function nav_link(; href, active = false)
    class = active ? "nav-link active" : "nav-link"
    @a {href, class} @__slot__
end

@deftag macro nav_link end

@component function navbar(; links, current_path = "/")
    @nav {class = "navbar"} begin
        @ul begin
            for link in links
                @li begin
                    @nav_link {
                        href = link.href,
                        active = link.href == current_path
                    } begin
                        @text link.text
                    end
                end
            end
        end
    end
end

@deftag macro navbar end

# Usage
links = [
    (href = "/", text = "Home"),
    (href = "/about", text = "About"),
    (href = "/contact", text = "Contact")
]

html = @render @navbar {links, current_path = "/about"}

Main.display_html(html) #hide
```

### Higher-Order Components

Create components that modify behavior of other components:

```@example higher-order
using HypertextTemplates
using HypertextTemplates.Elements

@component function with_tooltip(; tooltip, position = "top")
    @div {
        class = "tooltip-wrapper",
        "data-tooltip" := tooltip,
        "data-position" := position
    } begin
        @__slot__
    end
end

@deftag macro with_tooltip end

# Wrap any content with tooltip
html = @render @with_tooltip {tooltip = "Click to submit"} begin
    @button "Submit"
end

Main.display_html(html) #hide
```

### Component Arrays

Render collections of components:

```@example component-arrays
using HypertextTemplates
using HypertextTemplates.Elements

@component function todo_item(; task, completed = false)
    @li {class = completed ? "completed" : ""} begin
        @input {type = "checkbox", checked = completed}
        @span " " $task
    end
end

@deftag macro todo_item end

@component function todo_list(; items)
    @ul {class = "todo-list"} begin
        for item in items
            @todo_item {task = item.task, completed = item.completed}
        end
    end
end

@deftag macro todo_list end

# Example usage
items = [
    (task = "Write documentation", completed = true),
    (task = "Add tests", completed = false),
    (task = "Deploy to production", completed = false)
]

html = @render @todo_list {items}

Main.display_html(html) #hide
```

## Dynamic Components

Use the `@<` macro to render components dynamically:

### Component as Props

```@example component-props
using HypertextTemplates
using HypertextTemplates.Elements

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

@deftag macro flexible_layout end

# Custom header component
@component function custom_header()
    @header {class = "fancy-header"} begin
        @h1 "My App"
    end
end

# Usage
html = @render @flexible_layout {
    header_component = custom_header,
    main_component = section
} begin
    @p "Main content here"
    sidebar := @p "Sidebar content"
end

Main.display_html(html) #hide
```

### Conditional Component Selection

```@example conditional-components
using HypertextTemplates
using HypertextTemplates.Elements

# Define icon components
@component function error_icon()
    @span {class = "icon icon-error"} "❌"
end

@component function warning_icon()
    @span {class = "icon icon-warning"} "⚠️"
end

@component function info_icon()
    @span {class = "icon icon-info"} "ℹ️"
end

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
        @span " "
        @span $message
    end
end

@deftag macro alert end

# Test different alert types
@render @alert {type = "info", message = "This is information"}

Main.display_html(ans)
```

```@example conditional-components
@render @alert {type = "warning", message = "This is a warning"}

Main.display_html(ans) #hide
```

```@example conditional-components
@render @alert {type = "error", message = "This is an error"}
Main.display_html(ans) #hide
```

## Module-Qualified Components

Components can be organized in modules and referenced with qualification:

```@example module-qualified
using HypertextTemplates
using HypertextTemplates.Elements

module UI
    using HypertextTemplates
    using HypertextTemplates.Elements

    @component function my_button(; variant = "primary")
        @button {class = "ui-button ui-button-$variant"} @__slot__
    end

    @deftag macro my_button end

    @component function card()
        @div {class = "ui-card"} @__slot__
    end

    @deftag macro card end
end

# Usage with module qualification
html = @render @div begin
    @UI.card begin
        @h2 "Card Title"
        @UI.my_button {variant = "secondary"} "Click me"
    end
end

Main.display_html(html) #hide
```

## Creating Component Macros

Use `@deftag` to create macro shortcuts for components:

```@example component-macros
using HypertextTemplates
using HypertextTemplates.Elements

@component function badge(; text, variant = "primary", size = "normal")
    size_class = size == "small" ? "badge-sm" : "badge-normal"
    @span {
        class = "badge badge-$variant $size_class"
    } $text
end

# Create a macro for easier use
@deftag macro badge end

# Now can use as @badge instead of @<badge
html = @render @div begin
    @h3 begin
        @text "Products "
        @badge {text = "New", variant = "success", size = "small"}
    end
    @p begin
        @text "Status: "
        @badge {text = "In Stock", variant = "primary"}
    end
end

Main.display_html(html) #hide
```

## Component Patterns

### Container/Presenter Pattern

Separate logic from presentation:

```@example container-presenter
using HypertextTemplates
using HypertextTemplates.Elements

# Presenter component (pure UI)
@component function user_list_view(; users)
    @div {class = "user-list"} begin
        for user in users
            # Use data attributes for JavaScript interaction
            @div {class = "user-item", "data-user-id" := user.id} begin
                @img {src = user.avatar, alt = user.name, width = 32, height = 32}
                @span " " $(user.name)
            end
        end
    end
end

@deftag macro user_list_view end

# Example usage with mock data
users = [
    (id = 1, name = "Alice Johnson", avatar = "/avatars/alice.jpg"),
    (id = 2, name = "Bob Smith", avatar = "/avatars/bob.jpg"),
    (id = 3, name = "Charlie Brown", avatar = "/avatars/charlie.jpg")
]

html = @render @user_list_view {users}

Main.display_html(html) #hide
```

### Compound Components

Related components that work together:

```@example compound-components
using HypertextTemplates
using HypertextTemplates.Elements

module Tabs
    using HypertextTemplates
    using HypertextTemplates.Elements

    @component function container(; active_tab = 1)
        @div {class = "tabs", "data-active" := active_tab} begin
            @__slot__
        end
    end

    @deftag macro container end

    @component function list()
        @ul {class = "tab-list", role = "tablist"} begin
            @__slot__
        end
    end

    @deftag macro list end

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

    @deftag macro tab end

    @component function panels()
        @div {class = "tab-panels"} begin
            @__slot__
        end
    end

    @deftag macro panels end

    @component function panel(; index, active = false)
        @div {
            role = "tabpanel",
            class = active ? "panel active" : "panel",
            hidden = !active
        } begin
            @__slot__
        end
    end

    @deftag macro panel end
end

# Usage
html = @render @Tabs.container {active_tab = 2} begin
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

Main.display_html(html) #hide
```

### Safe Rendering Pattern

While HypertextTemplates renders directly to IO (making traditional try-catch error boundaries impossible), you can implement safe rendering patterns:

```@example safe-rendering
using HypertextTemplates
using HypertextTemplates.Elements

# Helper function to safely access nested data
safe_get(obj, field, default="N/A") = try
    getfield(obj, field)
catch
    default
end

# Component that handles potentially missing data
@component function user_card(; user=nothing)
    @div {class = "user-card"} begin
        if user !== nothing
            @h3 safe_get(user, :name, "Unknown User")
            @p "Email: " safe_get(user, :email)
            @p "Role: " safe_get(user, :role, "Guest")
        else
            @div {class = "empty-state"} begin
                @p "No user data available"
            end
        end
    end
end

@deftag macro user_card end

# Example with valid user
user = (name = "Alice", email = "alice@example.com", role = "Admin")
html1 = @render @user_card {user}

Main.display_html(html1) #hide
```

```@example safe-rendering
# Example with missing user
html2 = @render @user_card {}

Main.display_html(html2) #hide
```

```@example safe-rendering
# Example with partial data
partial_user = (name = "Bob")  # Missing email and role
html3 = @render @user_card {user = partial_user}

Main.display_html(html3) #hide
```

## Best Practices

### 1. Keep Components Focused

Each component should have a single, clear purpose:

```@example focused-components
using HypertextTemplates
using HypertextTemplates.Elements

# Good: Focused components
@component function price_display(; amount, currency = "USD")
    @span {class = "price"} $currency " " $amount
end

@deftag macro price_display end

@component function product_card(; product)
    @div {class = "product"} begin
        @h3 $(product.name)
        @price_display {amount = product.price, currency = product.currency}
    end
end

@deftag macro product_card end

# Example usage
product = (name = "Laptop", price = 999.99, currency = "USD")
html = @render @product_card {product}

Main.display_html(html) #hide
```

### 2. Use Props for Configuration

Make components flexible through props:

```@example props-configuration
using HypertextTemplates
using HypertextTemplates.Elements

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
    ] |> x -> filter(!isnothing, x) |> x -> join(x, " ")

    @table {class = classes} begin
        @thead begin
            @tr begin
                for col in columns
                    @th $col
                end
            end
        end
        @tbody begin
            for row in data
                @tr begin
                    for value in row
                        @td $value
                    end
                end
            end
        end
    end
end

@deftag macro data_table end

# Example usage
columns = ["Name", "Age", "City"]
data = [
    ["Alice", 25, "New York"],
    ["Bob", 30, "London"],
    ["Charlie", 35, "Tokyo"]
]

html = @render @data_table {data, columns, striped = true, bordered = true}

Main.display_html(html) #hide
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

```@example performance-optimization
using HypertextTemplates
using HypertextTemplates.Elements

# Precompute static values
const BUTTON_CLASSES = Dict(
    :primary => "btn btn-primary",
    :secondary => "btn btn-secondary",
    :danger => "btn btn-danger"
)

@component function my_button(; variant = :primary)
    @button {class = BUTTON_CLASSES[variant]} @__slot__
end

@deftag macro my_button end

# Example usage
@render @my_button {variant = :primary} "Click me"

Main.display_html(ans) #hide
```

```@example performance-optimization
@render @my_button {variant = :danger} "Delete"
Main.display_html(ans) #hide
```

### 5. Error Handling

Handle edge cases gracefully:

```@example error-handling
using HypertextTemplates
using HypertextTemplates.Elements

@component function safe_image(; src, alt = "", fallback = "/placeholder.png")
    image_src = isempty(src) ? fallback : src
    @img {src = image_src, alt, onerror = "this.src='$fallback'"}
end

@deftag macro safe_image end

# Example usage
@render @safe_image {src = "/user.jpg", alt = "User avatar"}

Main.display_html(ans) #hide
```

```@example error-handling
@render @safe_image {src = "", alt = "User avatar"}

Main.display_html(ans) #hide
```

## Context: Avoiding Prop Drilling

For cross-cutting concerns like themes, authentication, or localization, passing props through every component level becomes cumbersome. The context system provides a cleaner solution:

```@example context-intro
using HypertextTemplates
using HypertextTemplates.Elements

@deftag macro app_without_context end
@deftag macro navbar end
@deftag macro user_menu end
@deftag macro navbar_ctx end
@deftag macro user_menu_ctx end

# Without context - props passed through every level
@component function app_without_context(; user)
    @navbar {user}  # Pass to navbar
end

@component function navbar(; user)
    @user_menu {user}  # Pass to user menu
end

@component function user_menu(; user)
    @span "Welcome, $(user.name)!"
end

# With context - cleaner and more maintainable
@component function app_with_context(; user)
    @context {current_user = user} begin
        @navbar_ctx  # No need to pass user
    end
end

@component function navbar_ctx()
    @user_menu_ctx  # No need to pass user
end

@component function user_menu_ctx()
    user = @get_context(:current_user)
    @span "Welcome, $(user.name)!"
end
```

Context is particularly useful for:
- **Theme systems** - Colors, styles, dark/light mode
- **Authentication** - Current user, permissions
- **Localization** - Language, date/number formats
- **Feature flags** - Enable/disable features globally

For detailed context usage and patterns, see the [Context System](advanced-features.md#context-system) section in the Advanced Features guide.

## Summary

Components combine reusability, composition through slots, type safety, flexible rendering, and context support to create maintainable templates. Use these patterns to structure your applications effectively.
