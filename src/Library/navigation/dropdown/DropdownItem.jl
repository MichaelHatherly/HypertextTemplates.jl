"""
    @DropdownItem

An individual menu item within dropdown menus that represents a selectable action or navigation option. Dropdown items are the core interactive elements of any menu, supporting various states like hover, disabled, and different semantic variants (default, danger, success). They can function as either buttons for actions or links for navigation, include optional icons for visual clarity, and maintain consistent styling across different uses. The component ensures proper keyboard accessibility and provides visual feedback through smooth hover transitions.

# Props
- `href::Union{String,Nothing}`: Optional link URL
- `disabled::Bool`: Whether item is disabled (default: `false`)
- `icon::Union{String,Nothing}`: Optional icon name
- `variant::Symbol`: Item variant (`:default`, `:danger`, `:success`)
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Slots
- Menu item text or content

# Example
```julia
# Basic item
@DropdownItem "Settings"

# Link item with icon
@DropdownItem {href = "/profile", icon = "user"} "My Profile"

# Danger variant
@DropdownItem {variant = :danger} "Delete Account"

# Disabled item
@DropdownItem {disabled = true} "Coming Soon"
```

# Accessibility
**ARIA:** Uses `role="menuitem"` with proper disabled states via `aria-disabled`.

**Keyboard:** Enter/Space activates, participates in parent menu's navigation flow.

**Visual Design:** High contrast focus indicators and disabled states with reduced opacity.

# See also
- [`DropdownContent`](@ref) - Parent content container
- [`DropdownSubmenu`](@ref) - For nested items
- [`DropdownDivider`](@ref) - For separating items
- [`Icon`](@ref) - For item icons
"""
@component function DropdownItem(;
    href::Union{String,Nothing} = nothing,
    disabled::Bool = false,
    icon::Union{String,Nothing} = nothing,
    variant::Symbol = :default,
    class::String = "",
    attrs...,
)
    # Base classes
    base_classes = "block w-full text-left px-4 py-2 text-sm transition-colors duration-150"

    # Variant classes
    variant_classes = if disabled
        "text-gray-400 cursor-not-allowed dark:text-gray-500"
    elseif variant === :danger
        "text-red-600 hover:bg-red-50 hover:text-red-700 dark:text-red-400 dark:hover:bg-red-950/20 dark:hover:text-red-300"
    elseif variant === :success
        "text-green-600 hover:bg-green-50 hover:text-green-700 dark:text-green-400 dark:hover:bg-green-950/20 dark:hover:text-green-300"
    else
        "text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700"
    end

    # Combine classes
    item_class = "$base_classes $variant_classes $class"

    # Build component attributes
    component_attrs = (class = item_class, role = "menuitem", disabled = disabled)

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    # Render as link or button
    if !isnothing(href) && !disabled
        @a {href = href, merged_attrs...} begin
            if !isnothing(icon)
                @span {class = "inline-flex items-center gap-2"} begin
                    @Icon {name = icon, size = :sm}
                    @__slot__()
                end
            else
                @__slot__()
            end
        end
    else
        @button {type = "button", merged_attrs...} begin
            if !isnothing(icon)
                @span {class = "inline-flex items-center gap-2"} begin
                    @Icon {name = icon, size = :sm}
                    @__slot__()
                end
            else
                @__slot__()
            end
        end
    end
end

@deftag macro DropdownItem end
