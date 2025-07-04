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
    @div {var"x-ref" = "trigger", class = "inline-block $class", attrs...} begin
        @__slot__()
    end
end

@deftag macro TooltipTrigger end
