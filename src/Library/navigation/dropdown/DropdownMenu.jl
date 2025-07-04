"""
    @DropdownMenu

A flexible dropdown menu component with support for nested submenus, powered by Alpine.js and Alpine Anchor. Provides trigger buttons, menu items, dividers, and intelligent positioning with click-outside behavior and keyboard navigation.

# Requirements
This component requires Alpine.js and Alpine Anchor for intelligent positioning:

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/anchor@latest/dist/cdn.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

**Browser Compatibility:** Modern browsers with ES6 support  
**Dependencies:** Tailwind CSS for styling classes

**Note:** JavaScript assets are automatically loaded via `@__once__` for optimal performance.

# Accessibility
**ARIA:** Uses `role="menu"` with `aria-haspopup` and `aria-expanded` states. Menu items have proper roles and state attributes.

**Keyboard:** Escape to close, Arrow keys to navigate, Enter/Space to activate, Tab to exit.

**Focus Management:** Returns to trigger when closed, moves to first item when opened via keyboard.

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Slots
- Should contain exactly one @DropdownTrigger and one @DropdownContent component

# Usage
```julia
@DropdownMenu begin
    @DropdownTrigger begin
        @Button "Options" {variant=:secondary}
    end

    @DropdownContent begin
        @DropdownItem {href="/profile"} "Profile"
        @DropdownItem {href="/settings"} "Settings"
        @DropdownDivider
        @DropdownItem {variant=:danger} "Logout"
    end
end
```

# See also
- [`DropdownTrigger`](@ref) - Dropdown trigger component
- [`DropdownContent`](@ref) - Dropdown content container
- [`DropdownItem`](@ref) - Individual menu items
- [`DropdownSubmenu`](@ref) - Nested dropdown menus
- [`Button`](@ref) - Common trigger element
"""
@component function DropdownMenu(; class::String = "", attrs...)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    base_class = theme.dropdown_menu.base

    # Combine base class with user-provided class
    final_class = "$base_class $class"

    # Load JavaScript and CSS for dropdown functionality
    @__once__ begin
        @script @text SafeString(
            read(joinpath(@__DIR__, "../../assets/dropdown.js"), String),
        )
        # CSS for x-cloak to ensure hidden elements don't affect layout
        @style @text "[x-cloak] { display: none !important; }"
    end

    # Build Alpine.js data configuration
    # Uses Alpine.data reference pattern.
    alpine_data = SafeString("""dropdown()""")

    # Build component attributes
    # Event handlers use method calls defined in the Alpine.data component:
    # - @keydown.escape: Calls close() method
    # - @click.outside: Calls handleClickOutside() method for clicks completely outside container
    # - @click: Calls handleContainerClick() to handle clicks within the container that aren't
    #          on the trigger or content (e.g., empty space to the right of the button)
    # - @dropdown-open.window: Calls handleDropdownOpen() for dropdown coordination
    # 
    # The @click handler is crucial for proper UX: without it, clicking empty space within
    # the dropdown container wouldn't close the dropdown, which feels broken to users.
    component_attrs = (
        class = final_class,
        var"x-data" = alpine_data,
        var"data-dropdown" = "true",
        var"@keydown.escape" = "close()",
        var"@click.outside" = "handleClickOutside",
        var"@click" = "handleContainerClick(\$event)",
        var"@dropdown-open.window" = "handleDropdownOpen",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro DropdownMenu end
