"""
    @Badge

A small label component for displaying status, counts, or categorization. Badges are compact visual indicators that draw attention to important information without disrupting the flow of content. They're commonly used to show notification counts, status indicators, tags, or to highlight new features. With support for multiple color variants and sizes, badges can effectively communicate different states and priorities while maintaining visual hierarchy in your interface.

# Props
- `variant::Union{Symbol,String}`: Badge variant (`:default`, `:primary`, `:secondary`, `:success`, `:warning`, `:danger`, `:gradient`) (default: `:default`)
- `size::Union{Symbol,String}`: Badge size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `role::Union{String,Nothing}`: ARIA role (e.g., "status" for dynamic updates) (optional)
- `animated::Bool`: Whether badge has subtle animation (default: `false`)
- `outline::Bool`: Whether badge has outline style (default: `false`)

# Slots
- Badge text or content (typically short text, numbers, or icons)

# Example
```julia
# Status badges
@Badge {variant = :success} "Active"
@Badge {variant = :danger} "Expired"
@Badge {variant = :warning} "Pending"

# Count badge
@Badge {variant = :primary, size = :sm} "99+"

# Animated badge for live updates
@Badge {variant = :gradient, animated = true, role = "status"} "Live"

# Outline style
@Badge {variant = :secondary, outline = true} "Beta"
```

# See also
- [`Card`](@ref) - Container component often used with badges
- [`Button`](@ref) - Interactive element with similar variants
- [`Alert`](@ref) - For larger notification messages
"""
@component function Badge(;
    variant::Union{Symbol,String} = :default,
    size::Union{Symbol,String} = :base,
    role::Union{String,Nothing} = nothing,
    animated::Bool = false,
    outline::Bool = false,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    variant_classes = (
        default = "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300",
        primary = "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
        secondary = "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300",
        success = "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300",
        warning = "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
        danger = "bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-300",
        gradient = "bg-gradient-to-r from-blue-500 to-purple-600 text-white",
    )

    outline_classes = (
        default = "bg-transparent border border-gray-300 text-gray-700 dark:border-gray-600 dark:text-gray-300",
        primary = "bg-transparent border border-blue-300 text-blue-700 dark:border-blue-600 dark:text-blue-300",
        secondary = "bg-transparent border border-purple-300 text-purple-700 dark:border-purple-600 dark:text-purple-300",
        success = "bg-transparent border border-emerald-300 text-emerald-700 dark:border-emerald-600 dark:text-emerald-300",
        warning = "bg-transparent border border-amber-300 text-amber-700 dark:border-amber-600 dark:text-amber-300",
        danger = "bg-transparent border border-rose-300 text-rose-700 dark:border-rose-600 dark:text-rose-300",
        gradient = "bg-transparent border-2 border-transparent bg-gradient-to-r from-blue-500 to-purple-600 bg-clip-text text-transparent",
    )

    size_classes = (
        xs = "px-2 py-0.5 text-xs",
        sm = "px-2.5 py-0.5 text-xs",
        base = "px-3 py-1 text-sm",
        md = "px-3 py-1 text-sm",  # For backward compatibility
        lg = "px-3.5 py-1.5 text-base",
        xl = "px-4 py-2 text-lg",
    )

    variant_class =
        outline ? get(outline_classes, variant_sym, outline_classes.default) :
        get(variant_classes, variant_sym, variant_classes.default)
    size_class = get(size_classes, size_sym, size_classes.base)
    animation_class = animated ? "animate-pulse" : ""
    transition_class = "transition-all duration-200"

    @span {
        class = "inline-flex items-center font-medium rounded-full $variant_class $size_class $animation_class $transition_class",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Badge end
