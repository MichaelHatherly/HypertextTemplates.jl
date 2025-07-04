"""
    @TooltipTrigger

The trigger element within TooltipWrapper that activates tooltip display. Acts as a transparent wrapper for any element, handling event bindings and ARIA attributes while maintaining original functionality.

# Props
- `class::String`: Additional CSS classes (optional)
- `attrs...`: Additional attributes

# Slots
- Trigger element - any element that should show the tooltip when interacted with

# Example
```julia
@TooltipTrigger begin
    @Button {variant = :ghost} "Hover me"
end
```

# Accessibility
**ARIA:** Maintains semantic relationship with tooltip while preserving original element accessibility.

**Keyboard:** Enter/Space shows tooltip, Escape dismisses, Tab for normal behavior.

**Guidelines:** Works with any trigger element type while maintaining original functionality.

# See also
- [`TooltipWrapper`](@ref) - Parent wrapper component
- [`TooltipContent`](@ref) - Tooltip content component
"""
@component function TooltipTrigger(; class::String = "", attrs...)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    base_class = theme.tooltip_trigger.base

    # Combine base class with user-provided class
    final_class = "$base_class $class"

    @div {var"x-ref" = "trigger", class = final_class, attrs...} begin
        @__slot__()
    end
end

@deftag macro TooltipTrigger end
