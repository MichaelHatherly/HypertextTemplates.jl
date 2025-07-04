"""
    @DropdownSubmenu

A nested submenu component that creates hierarchical flyout menus within dropdowns for organizing complex menu structures. Submenus are essential for creating multi-level navigation without overwhelming users with too many options at once. This component manages its own open state while coordinating with the parent dropdown, positions itself to the side of the parent menu item, and includes visual indicators like chevrons to show that it contains nested options. The submenu supports the same rich content as regular dropdown menus, enabling deep menu hierarchies while maintaining usability.

# Props
- `label::String`: The label for the submenu trigger
- `icon::Union{String,Nothing}`: Optional icon name
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Slots
- Submenu items - typically @DropdownItem components

# Example
```julia
@DropdownSubmenu {label = "Export As"} begin
    @DropdownItem {icon = "document"} "PDF"
    @DropdownItem {icon = "file"} "CSV"
    @DropdownItem {icon = "code"} "JSON"
end
```

# Implementation Notes
The submenu uses Alpine Anchor for positioning. The key to making this work is the
x-anchor directive on the submenu content, which references its trigger button using
`\$el.previousElementSibling`. This works because:

1. The DOM structure places the trigger button immediately before the submenu content
2. `\$el` in the x-anchor context refers to the element with the directive (submenu content)
3. `previousElementSibling` reliably points to the trigger button
4. This avoids complex ref lookups that can fail due to Alpine scope boundaries

The submenu state is managed by the parent dropdown's Alpine component through the
`openSubmenus` object, allowing multiple submenus to be open simultaneously.

# Accessibility
**ARIA:** Maintains proper hierarchy for nested menus with expandable content indicators.

**Keyboard:** Arrow Right opens submenu, Arrow Left closes, Escape closes all menus.

**Focus Management:** Logical movement between menu levels with proper focus return.

# See also
- [`DropdownMenu`](@ref) - Root dropdown component
- [`DropdownContent`](@ref) - Parent content container
- [`DropdownItem`](@ref) - Menu items within submenu
"""
@component function DropdownSubmenu(;
    label::AbstractString,
    icon::Union{AbstractString,Nothing} = nothing,
    class::AbstractString = "",
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract dropdown_submenu theme safely
    dropdown_submenu_theme = if isa(theme, NamedTuple) && haskey(theme, :dropdown_submenu)
        theme.dropdown_submenu
    else
        HypertextTemplates.Library.default_theme().dropdown_submenu
    end

    # Get container class
    container_class = get(
        dropdown_submenu_theme,
        :container,
        HypertextTemplates.Library.default_theme().dropdown_submenu.container,
    )
    content_class = get(
        dropdown_submenu_theme,
        :content,
        HypertextTemplates.Library.default_theme().dropdown_submenu.content,
    )

    # Get trigger theme
    trigger_theme =
        if isa(dropdown_submenu_theme, NamedTuple) &&
           haskey(dropdown_submenu_theme, :trigger)
            dropdown_submenu_theme.trigger
        else
            HypertextTemplates.Library.default_theme().dropdown_submenu.trigger
        end
    trigger_base_class = get(
        trigger_theme,
        :base,
        HypertextTemplates.Library.default_theme().dropdown_submenu.trigger.base,
    )
    icon_wrapper_class = get(
        trigger_theme,
        :icon_wrapper,
        HypertextTemplates.Library.default_theme().dropdown_submenu.trigger.icon_wrapper,
    )
    chevron_icon = get(
        trigger_theme,
        :chevron_icon,
        HypertextTemplates.Library.default_theme().dropdown_submenu.trigger.chevron_icon,
    )

    # Generate unique ID for this submenu to track its open/closed state
    submenu_id = "submenu-$(hash(label))"

    @div {class = container_class, "data-submenu-id" = submenu_id} begin
        # Trigger button - must come first in DOM for x-anchor to work
        @button {
            type = "button",
            class = trigger_base_class,
            "@click" = "toggleSubmenu('$submenu_id', \$event)",
            "x-ref" = "submenu_trigger_$submenu_id",  # Ref is kept for potential future use
        } begin
            @span {class = icon_wrapper_class} begin
                if !isnothing(icon)
                    @Icon {name = icon, size = :sm}
                end
                @text label
            end
            # Chevron icon
            @text SafeString(chevron_icon)
        end

        # Submenu content - positioned using Alpine Anchor
        # IMPORTANT: This div MUST come immediately after the trigger button in the DOM
        # for the x-anchor positioning to work correctly.
        @div {
            "x-ref" = "submenu_content_$submenu_id",
            "x-show" = "isSubmenuOpen('$submenu_id')",
            "x-cloak" = "",
            # Critical: x-anchor uses $el.previousElementSibling to find the trigger button
            # This works because:
            # 1. $el refers to this submenu content div
            # 2. previousElementSibling gets the immediately preceding element (the button above)
            # 3. Alpine Anchor then positions this div relative to that button
            # 4. The SafeString wrapper preserves the $ character from being escaped
            "x-anchor.right-start.offset.4" = SafeString("\$el.previousElementSibling"),
            "x-transition:enter" = "transition ease-out duration-100",
            "x-transition:enter-start" = "transform opacity-0 scale-95",
            "x-transition:enter-end" = "transform opacity-100 scale-100",
            "x-transition:leave" = "transition ease-in duration-75",
            "x-transition:leave-start" = "transform opacity-100 scale-100",
            "x-transition:leave-end" = "transform opacity-0 scale-95",
            class = "$content_class $class",
            role = "menu",
            "@click.stop" = "",  # Prevent clicks from bubbling up
        } begin
            @__slot__()
        end
    end
end

@deftag macro DropdownSubmenu end
