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

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract badge theme safely
    badge_theme = if isa(theme, NamedTuple) && haskey(theme, :badge)
        theme.badge
    else
        HypertextTemplates.Library.default_theme().badge
    end

    # Get base classes
    base_classes =
        get(badge_theme, :base, HypertextTemplates.Library.default_theme().badge.base)

    # Get variant classes based on outline prop
    if outline
        variant_class =
            if haskey(badge_theme, :outline_variants) &&
               haskey(badge_theme.outline_variants, variant_sym)
                badge_theme.outline_variants[variant_sym]
            else
                HypertextTemplates.Library.default_theme().badge.outline_variants[variant_sym]
            end
    else
        variant_class =
            if haskey(badge_theme, :variants) && haskey(badge_theme.variants, variant_sym)
                badge_theme.variants[variant_sym]
            else
                HypertextTemplates.Library.default_theme().badge.variants[variant_sym]
            end
    end

    # Get size class with fallback
    size_class = if haskey(badge_theme, :sizes) && haskey(badge_theme.sizes, size_sym)
        badge_theme.sizes[size_sym]
    else
        HypertextTemplates.Library.default_theme().badge.sizes[size_sym]
    end

    # Get state classes
    states =
        get(badge_theme, :states, HypertextTemplates.Library.default_theme().badge.states)
    animation_class = animated ? get(states, :animated, "animate-pulse") : ""
    transition_class = get(states, :transition, "transition-all duration-200")

    @span {
        class = "$base_classes $variant_class $size_class $animation_class $transition_class",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Badge end
