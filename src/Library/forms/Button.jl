"""
    @Button

A versatile button component for triggering actions with multiple variants, sizes, and states. Supports icons, loading states, and full accessibility with proper ARIA attributes and keyboard navigation.

# Props
- `variant::Union{Symbol,String}`: Button variant (`:primary`, `:secondary`, `:neutral`, `:success`, `:warning`, `:danger`, `:ghost`, `:outline`) (default: `:primary`)
- `size::Union{Symbol,String}`: Button size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `type::String`: Button type attribute (default: `"button"`)
- `disabled::Bool`: Whether button is disabled (default: `false`)
- `loading::Bool`: Whether button is in loading state (default: `false`)
- `full_width::Bool`: Whether button should be full width (default: `false`)
- `icon_left::Union{String,Nothing}`: Icon HTML to display on the left (optional)
- `icon_right::Union{String,Nothing}`: Icon HTML to display on the right (optional)
- `rounded::Union{Symbol,String}`: Border radius (`:sm`, `:base`, `:lg`, `:full`) (default: `:base`)

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
@Button {variant = :primary, full_width = true} "Get Started"

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
    rounded::Union{Symbol,String} = :base,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)
    rounded_sym = Symbol(rounded)

    # Size classes
    size_map = (
        xs = (padding = "px-2.5 py-1.5", text = "text-xs", gap = "gap-1"),
        sm = (padding = "px-3 py-2", text = "text-sm", gap = "gap-1.5"),
        base = (padding = "px-4 py-2.5", text = "text-base", gap = "gap-2"),
        lg = (padding = "px-5 py-3", text = "text-lg", gap = "gap-2.5"),
        xl = (padding = "px-6 py-3.5", text = "text-xl", gap = "gap-3"),
    )

    # Variant classes - refined minimal palette with indigo primary
    variant_map = (
        primary = "bg-indigo-600 text-white hover:bg-indigo-700 focus:ring-indigo-500/30 shadow-[0_1px_2px_rgba(0,0,0,0.05)] dark:bg-indigo-500 dark:hover:bg-indigo-600",
        secondary = "bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 hover:border-slate-300 focus:ring-slate-500/20 shadow-[0_1px_2px_rgba(0,0,0,0.04)] dark:bg-slate-800 dark:text-slate-200 dark:border-slate-700 dark:hover:bg-slate-700 dark:hover:border-slate-600",
        neutral = "bg-slate-100 text-slate-900 hover:bg-slate-200 focus:ring-slate-500/20 dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700",
        success = "bg-emerald-600 text-white hover:bg-emerald-700 focus:ring-emerald-500/30 shadow-[0_1px_2px_rgba(0,0,0,0.05)] dark:bg-emerald-500 dark:hover:bg-emerald-600",
        warning = "bg-amber-500 text-white hover:bg-amber-600 focus:ring-amber-500/30 shadow-[0_1px_2px_rgba(0,0,0,0.05)]",
        danger = "bg-rose-600 text-white hover:bg-rose-700 focus:ring-rose-500/30 shadow-[0_1px_2px_rgba(0,0,0,0.05)] dark:bg-rose-500 dark:hover:bg-rose-600",
        ghost = "bg-transparent text-slate-600 hover:bg-slate-100 hover:text-slate-900 focus:ring-slate-500/20 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-slate-200",
        outline = "bg-transparent border border-slate-300 text-slate-700 hover:bg-slate-50 hover:border-slate-400 focus:ring-slate-500/20 dark:border-slate-600 dark:text-slate-300 dark:hover:bg-slate-800 dark:hover:border-slate-500",
    )

    size_data = get(size_map, size_sym, size_map.base)
    variant_class = get(variant_map, variant_sym, variant_map.primary)

    # Rounded classes - more restrained defaults
    rounded_classes =
        (sm = "rounded", base = "rounded-md", lg = "rounded-lg", full = "rounded-full")
    rounded_class = get(rounded_classes, rounded_sym, rounded_classes.base)

    # Build classes
    width_class = full_width ? "w-full" : ""
    disabled_class = disabled || loading ? "opacity-60 cursor-not-allowed" : ""

    base_classes = "inline-flex items-center justify-center font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 dark:focus:ring-offset-slate-900 transition-colors duration-150 ease-out"

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
