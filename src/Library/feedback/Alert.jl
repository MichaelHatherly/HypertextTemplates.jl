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

    variant_classes = (
        info = "bg-blue-50 border-blue-300 text-blue-800 dark:bg-blue-950/30 dark:border-blue-700 dark:text-blue-300",
        success = "bg-emerald-50 border-emerald-300 text-emerald-800 dark:bg-emerald-950/30 dark:border-emerald-700 dark:text-emerald-300",
        warning = "bg-amber-50 border-amber-300 text-amber-800 dark:bg-amber-950/30 dark:border-amber-700 dark:text-amber-300",
        error = "bg-rose-50 border-rose-300 text-rose-800 dark:bg-rose-950/30 dark:border-rose-700 dark:text-rose-300",
    )

    icon_svgs = (
        info = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" /></svg>""",
        success = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" /></svg>""",
        warning = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" /></svg>""",
        error = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" /></svg>""",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes.info)
    icon_svg = get(icon_svgs, variant_sym, icon_svgs.info)
    animation_class = animated ? "animate-[fadeIn_0.3s_ease-in-out]" : ""

    # Build component default attributes
    component_attrs = (
        class = "rounded-xl border-l-4 border-t border-r border-b p-4 shadow-sm $variant_class $animation_class transition-all duration-300",
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

    @div {merged_attrs...} begin
        @div {class = "flex"} begin
            if icon
                @div {class = "flex-shrink-0"} begin
                    @text HypertextTemplates.SafeString(icon_svg)
                end
            end
            @div {class = icon ? "ml-3 flex-1" : "flex-1"} begin
                @__slot__()
            end
            if dismissible
                @button {
                    type = "button",
                    class = "ml-3 inline-flex flex-shrink-0 rounded-lg p-1.5 hover:bg-black/10 dark:hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-transparent focus:ring-current transition-all duration-200",
                    "aria-label" := "Dismiss",
                    "@click" := "show = false",
                } begin
                    @text HypertextTemplates.SafeString(
                        """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" /></svg>""",
                    )
                end
            end
        end
    end
end

@deftag macro Alert end
