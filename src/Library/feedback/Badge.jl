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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    # Direct theme access
    base_classes = theme.badge.base
    
    # Get variant classes based on outline prop
    variant_class = if outline
        theme.badge.outline_variants[variant_sym]
    else
        theme.badge.variants[variant_sym]
    end
    
    size_class = theme.badge.sizes[size_sym]
    animation_class = animated ? theme.badge.states.animated : ""
    transition_class = theme.badge.states.transition

    @span {
        class = "$base_classes $variant_class $size_class $animation_class $transition_class",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Badge end
