"""
    @Stack

A flexible stack component for arranging child elements with consistent spacing in vertical or horizontal layouts. Stack simplifies the common pattern of placing elements in a row or column with uniform gaps between them, eliminating the need for manual margin management. It's particularly useful for creating button groups, form layouts, card arrangements, and any scenario where you need predictable spacing between a series of elements.

# Props
- `direction::Union{Symbol,String}`: Stack direction (`:vertical` or `:horizontal`) (default: `:vertical`)
- `gap::Union{Symbol,String,Int}`: Gap size using Tailwind spacing scale or preset (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `4`)
- `align::Union{Symbol,String}`: Alignment (`:start`, `:center`, `:end`, `:stretch`) (default: `:stretch`)
- `justify::Union{Symbol,String}`: Justification (`:start`, `:center`, `:end`, `:between`, `:around`, `:evenly`) (default: `:start`)
- `wrap::Bool`: Whether items should wrap (default: `false`)

# Slots
- Child elements to be stacked with automatic spacing

# Example
```julia
# Vertical stack with cards
@Stack {gap = :lg} begin
    @Card "First item"
    @Card "Second item"
    @Card "Third item"
end

# Horizontal button group
@Stack {direction = :horizontal, gap = :sm} begin
    @Button "Save"
    @Button {variant = :secondary} "Cancel"
end
```

# See also
- [`Grid`](@ref) - For multi-column layouts
- [`Container`](@ref) - For constraining content width
- [`Card`](@ref) - Common child component for stacks
"""
@component function Stack(;
    direction::Union{Symbol,String} = :vertical,
    gap::Union{Symbol,String,Int} = 4,
    align::Union{Symbol,String} = :stretch,
    justify::Union{Symbol,String} = :start,
    wrap::Bool = false,
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbols
    direction_sym = Symbol(direction)
    align_sym = Symbol(align)
    justify_sym = Symbol(justify)

    # Direct theme access
    base_class = theme.stack.base
    direction_class = theme.stack.direction[direction_sym]
    align_class = theme.stack.align[align_sym]
    justify_class = theme.stack.justify[justify_sym]
    wrap_class = wrap ? theme.stack.wrap : ""
    
    # Handle gap as symbol or int
    gap_class = if gap isa Symbol
        theme.stack.gap[gap]
    else
        # Use gap prefix for numeric values
        "$(theme.stack.gap_prefix)$(gap)"
    end

    # Build component default attributes
    component_attrs = (
        class = "$base_class $direction_class $gap_class $align_class $justify_class $wrap_class",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro Stack end
