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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    dropdown_item_theme = theme.dropdown_item
    base_classes = dropdown_item_theme.base
    disabled_class = dropdown_item_theme.disabled
    icon_wrapper_class = dropdown_item_theme.icon_wrapper
    variants_theme = dropdown_item_theme.variants

    # Variant classes
    variant_classes = if disabled
        disabled_class
    else
        # Use get() for variant lookup since it might not exist
        get(variants_theme, variant, variants_theme.default)
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
                @span {class = icon_wrapper_class} begin
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
                @span {class = icon_wrapper_class} begin
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
