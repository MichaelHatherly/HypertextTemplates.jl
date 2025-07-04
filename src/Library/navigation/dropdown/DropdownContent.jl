"""
    @DropdownContent

The container for dropdown menu items that appears when the dropdown is triggered, providing the visual menu panel. This component creates a floating panel that positions itself intelligently relative to the trigger using Alpine Anchor, automatically adjusting to stay within viewport bounds. It manages the menu's appearance with smooth transitions, handles keyboard navigation between items, and provides proper focus management. The content container supports various menu patterns including simple lists, grouped items with dividers, and complex layouts with nested submenus.

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Slots
- Dropdown menu items - should contain @DropdownItem, @DropdownDivider, and @DropdownSubmenu components

# Example
```julia
@DropdownContent begin
    @DropdownItem {href = "/profile"} "Profile"
    @DropdownItem {href = "/settings"} "Settings"
    @DropdownDivider
    @DropdownSubmenu {label = "More"} begin
        @DropdownItem "Option 1"
        @DropdownItem "Option 2"
    end
end
```

# Accessibility
**ARIA:** Uses `role="menu"` with proper ARIA relationships and focus management.

**Keyboard:** Arrow keys navigate, Home/End jump to first/last, Enter/Space activate, Escape closes.

**Screen Reader:** Menu structure and item states are announced with positional feedback.

# See also
- [`DropdownMenu`](@ref) - Parent dropdown container
- [`DropdownItem`](@ref) - Menu items
- [`DropdownDivider`](@ref) - Visual separator
- [`DropdownSubmenu`](@ref) - Nested menus
"""
@component function DropdownContent(; class::String = "", attrs...)
    # Hardcoded positioning: bottom-start with automatic flipping to top if no space
    # Alpine Anchor with Floating UI handles the automatic repositioning
    component_attrs = (
        var"x-ref" = "content",
        var"x-show" = "open",
        var"x-cloak" = "",
        var"x-anchor.bottom-start.offset.4" = "\$refs.trigger ? \$refs.trigger : null",
        var"x-transition:enter" = "transition ease-out duration-100",
        var"x-transition:enter-start" = "transform opacity-0 scale-95",
        var"x-transition:enter-end" = "transform opacity-100 scale-100",
        var"x-transition:leave" = "transition ease-in duration-75",
        var"x-transition:leave-start" = "transform opacity-100 scale-100",
        var"x-transition:leave-end" = "transform opacity-0 scale-95",
        var"@keydown" = "handleKeydown(\$event)",
        var"@focus" = "focusFirstItem",
        class = "absolute z-[9999] min-w-[12rem] rounded-lg border border-gray-200 bg-white shadow-lg dark:border-gray-700 dark:bg-gray-800 py-1 $class",
        role = "menu",
        var"aria-orientation" = "vertical",
        tabindex = "-1",
    )

    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro DropdownContent end
