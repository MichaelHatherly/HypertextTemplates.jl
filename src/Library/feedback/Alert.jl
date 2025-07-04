"""
    @Alert

A notification component for displaying important messages with contextual styling and optional dismiss functionality. Alerts are essential for communicating important information, warnings, errors, or success messages to users in a clear and noticeable way. They support different severity levels through color-coded variants, can include icons for better visual recognition, and offer optional dismiss functionality for user control. With built-in animation support, alerts can appear smoothly and grab attention without being jarring.

# Props
- `variant::Union{Symbol,String}`: Alert variant (`:info`, `:success`, `:warning`, `:error`) (default: `:info`)
- `dismissible::Bool`: Whether alert can be dismissed (shows close button) (default: `false`)
- `icon::Bool`: Whether to show icon (default: `true`)
- `animated::Bool`: Whether to show fade-in animation (default: `true`)

# Slots
- Alert message content - can include text, links, or other inline elements

# Interactive Features
When `dismissible=true`, this component uses Alpine.js for interactive dismiss functionality.
To enable interactivity, include Alpine.js in your page:

```julia
@script {defer=true, src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"}
```

Without Alpine.js, the component will display the close button but won't be interactive.

# Example
```julia
# Simple alerts
@Alert "This is an informational message."
@Alert {variant = :success} "Operation completed successfully!"
@Alert {variant = :error} "An error occurred. Please try again."

# Dismissible alert
@Alert {variant = :warning, dismissible = true} begin
    @strong "Warning:"
    @text " Your session will expire in 5 minutes."
end

# Alert with custom content
@Alert {variant = :info, icon = false} begin
    @Text "New version available. "
    @Link {href = "/changelog"} "View changelog"
end
```

# See also
- [`Badge`](@ref) - For small status indicators
- [`Card`](@ref) - For general content containers
- [`Tooltip`](@ref) - For contextual help messages"""
@component function Alert(;
    variant::Union{Symbol,String} = :info,
    dismissible::Bool = false,
    icon::Bool = true,
    animated::Bool = true,
    attrs...,
)
    # Convert to symbol
    variant_sym = Symbol(variant)

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract alert theme safely
    alert_theme = if isa(theme, NamedTuple) && haskey(theme, :alert)
        theme.alert
    else
        HypertextTemplates.Library.default_theme().alert
    end

    # Get base classes
    base_classes =
        get(alert_theme, :base, HypertextTemplates.Library.default_theme().alert.base)

    # Get variant class with fallback
    variant_class =
        if haskey(alert_theme, :variants) && haskey(alert_theme.variants, variant_sym)
            alert_theme.variants[variant_sym]
        else
            HypertextTemplates.Library.default_theme().alert.variants[variant_sym]
        end

    # Get icon SVG with fallback
    icon_svg = if haskey(alert_theme, :icons) && haskey(alert_theme.icons, variant_sym)
        alert_theme.icons[variant_sym]
    else
        HypertextTemplates.Library.default_theme().alert.icons[variant_sym]
    end

    # Get state classes
    states =
        get(alert_theme, :states, HypertextTemplates.Library.default_theme().alert.states)
    animation_class = animated ? get(states, :animated, "") : ""
    transition_class = get(states, :transition, "transition-all duration-300")

    # Build component default attributes
    component_attrs = (
        class = "$base_classes $variant_class $animation_class $transition_class",
        role = "alert",
    )

    # Add Alpine.js attributes if dismissible
    if dismissible
        component_attrs = merge(
            component_attrs,
            (
                var"x-data" = SafeString("{ show: true }"),
                var"x-show" = SafeString("show"),
                var"x-transition:leave" = SafeString("transition ease-in duration-200"),
                var"x-transition:leave-start" = SafeString(
                    "opacity-100 transform scale-100",
                ),
                var"x-transition:leave-end" = SafeString("opacity-0 transform scale-95"),
            ),
        )
    end

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    # Get other theme classes
    icon_wrapper = get(
        alert_theme,
        :icon_wrapper,
        HypertextTemplates.Library.default_theme().alert.icon_wrapper,
    )
    content_with_icon = get(
        alert_theme,
        :content_with_icon,
        HypertextTemplates.Library.default_theme().alert.content_with_icon,
    )
    content_wrapper = get(
        alert_theme,
        :content_wrapper,
        HypertextTemplates.Library.default_theme().alert.content_wrapper,
    )
    dismiss_button = get(
        alert_theme,
        :dismiss_button,
        HypertextTemplates.Library.default_theme().alert.dismiss_button,
    )
    dismiss_icon = get(
        alert_theme,
        :dismiss_icon,
        HypertextTemplates.Library.default_theme().alert.dismiss_icon,
    )

    @div {merged_attrs...} begin
        @div {class = "flex"} begin
            if icon
                @div {class = icon_wrapper} begin
                    @text HypertextTemplates.SafeString(icon_svg)
                end
            end
            @div {class = icon ? content_with_icon : content_wrapper} begin
                @__slot__()
            end
            if dismissible
                @button {
                    type = "button",
                    class = dismiss_button,
                    "aria-label" := "Dismiss",
                    "@click" := "show = false",
                } begin
                    @text HypertextTemplates.SafeString(dismiss_icon)
                end
            end
        end
    end
end

@deftag macro Alert end
