"""
    @Button

A versatile button component for triggering actions with multiple variants, sizes, and states. Supports icons, loading states, and full accessibility with proper ARIA attributes and keyboard navigation.

# Props
- `variant::Union{Symbol,String}`: Button variant (`:primary`, `:secondary`, `:neutral`, `:success`, `:warning`, `:danger`, `:gradient`, `:ghost`, `:outline`) (default: `:primary`)
- `size::Union{Symbol,String}`: Button size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `type::String`: Button type attribute (default: `"button"`)
- `disabled::Bool`: Whether button is disabled (default: `false`)
- `loading::Bool`: Whether button is in loading state (default: `false`)
- `full_width::Bool`: Whether button should be full width (default: `false`)
- `icon_left::Union{String,Nothing}`: Icon HTML to display on the left (optional)
- `icon_right::Union{String,Nothing}`: Icon HTML to display on the right (optional)
- `rounded::Union{Symbol,String}`: Border radius (`:base`, `:lg`, `:xl`, `:full`) (default: `:xl`)

# Slots
- Button label text or content

# Example
```julia
# Basic buttons
@Button "Click me"
@Button {variant = :secondary} "Cancel"
@Button {variant = :danger, size = :sm} "Delete"

# Button with icon
@Button {icon_left = @Icon {name = "save"}} "Save changes"

# Loading state
@Button {loading = true} "Processing..."

# Full width button
@Button {variant = :gradient, full_width = true} "Get Started"

# Icon-only button
@Button {variant = :ghost, size = :sm, rounded = :full} begin
    @Icon {name = "settings"}
end
```

# Accessibility
**ARIA & Keyboard:** Semantic `<button>` element with standard Enter/Space activation. Disabled and loading states are properly announced to screen readers.

**Icon-only buttons:** Must include `aria-label` for screen reader context.

**Visual Design:** High contrast focus indicators and 4.5:1 color contrast across all variants.

# See also
- [`Link`](@ref) - For navigation links
- [`Icon`](@ref) - For button icons
- [`DropdownMenu`](@ref) - For button dropdowns
- [`Badge`](@ref) - For button badges/counters
"""
@component function Button(;
    variant::Union{Symbol,String} = :primary,
    size::Union{Symbol,String} = :base,
    type::String = "button",
    disabled::Bool = false,
    loading::Bool = false,
    full_width::Bool = false,
    icon_left::Union{String,Nothing} = nothing,
    icon_right::Union{String,Nothing} = nothing,
    rounded::Union{Symbol,String} = :xl,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)
    rounded_sym = Symbol(rounded)

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract button theme safely
    button_theme = if isa(theme, NamedTuple) && haskey(theme, :button)
        theme.button
    else
        HypertextTemplates.Library.default_theme().button
    end

    # Get base classes
    base_classes =
        get(button_theme, :base, HypertextTemplates.Library.default_theme().button.base)

    # Get variant classes with fallback
    variant_class =
        if haskey(button_theme, :variants) && haskey(button_theme.variants, variant_sym)
            button_theme.variants[variant_sym]
        else
            HypertextTemplates.Library.default_theme().button.variants[variant_sym]
        end

    # Get size data with fallback
    size_data = if haskey(button_theme, :sizes) && haskey(button_theme.sizes, size_sym)
        button_theme.sizes[size_sym]
    else
        HypertextTemplates.Library.default_theme().button.sizes[size_sym]
    end

    # Get rounded classes with fallback
    rounded_class =
        if haskey(button_theme, :rounded) && haskey(button_theme.rounded, rounded_sym)
            button_theme.rounded[rounded_sym]
        else
            HypertextTemplates.Library.default_theme().button.rounded[rounded_sym]
        end

    # Get state classes
    states =
        get(button_theme, :states, HypertextTemplates.Library.default_theme().button.states)
    width_class = full_width ? get(states, :full_width, "w-full") : ""
    disabled_class =
        disabled || loading ? get(states, :disabled, "opacity-60 cursor-not-allowed") : ""

    final_classes = "$base_classes $rounded_class $(size_data.padding) $(size_data.text) $(size_data.gap) $variant_class $width_class $disabled_class"

    @button {type = type, class = final_classes, disabled = disabled || loading, attrs...} begin
        if loading
            # Modern loading spinner
            @text HypertextTemplates.SafeString(
                """<svg class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
</svg>""",
            )
        elseif !isnothing(icon_left)
            @text HypertextTemplates.SafeString(icon_left)
        end

        @__slot__()

        if !isnothing(icon_right) && !loading
            @text HypertextTemplates.SafeString(icon_right)
        end
    end
end

@deftag macro Button end
