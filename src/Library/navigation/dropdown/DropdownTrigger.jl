"""
    @DropdownTrigger

The trigger element for dropdown menus that wraps any clickable element to control menu visibility. This component transforms its child element into an interactive trigger that opens the associated dropdown content on click. It automatically manages ARIA attributes for accessibility, including expanded state and menu ownership. The trigger can wrap various elements like buttons, links, or custom components, making it flexible for different design needs. It coordinates with the parent DropdownMenu to handle proper focus management and state synchronization.

# Props
- `attrs...`: Additional attributes passed to the wrapper

# Slots
- Clickable element that triggers the dropdown (typically a Button)

# Example
```julia
@DropdownTrigger begin
    @Button {variant = :secondary} "Menu"
end
```

# Accessibility
**ARIA:** Uses `aria-haspopup="true"` and maintains `aria-expanded` state.

**Keyboard:** Enter/Space and Arrow Down open dropdown, Escape closes (handled by parent).

# See also
- [`DropdownMenu`](@ref) - Parent dropdown container
- [`DropdownContent`](@ref) - Dropdown content that appears
- [`Button`](@ref) - Common trigger element
"""
@component function DropdownTrigger(; attrs...)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    base_class = theme.dropdown_trigger.base

    component_attrs = (
        var"x-ref" = "trigger",
        var"@click" = "toggle()",
        var":aria-expanded" = "open",
        var"aria-haspopup" = "true",
        class = base_class,
    )

    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro DropdownTrigger end
