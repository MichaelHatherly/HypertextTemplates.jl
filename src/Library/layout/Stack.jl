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
    # Convert to symbols
    direction_sym = Symbol(direction)
    align_sym = Symbol(align)
    justify_sym = Symbol(justify)

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract stack theme safely
    stack_theme = if isa(theme, NamedTuple) && haskey(theme, :stack)
        theme.stack
    else
        HypertextTemplates.Library.default_theme().stack
    end

    # Get base class
    base_class =
        get(stack_theme, :base, HypertextTemplates.Library.default_theme().stack.base)

    # Get direction class with fallback
    direction_class =
        if haskey(stack_theme, :direction) && haskey(stack_theme.direction, direction_sym)
            stack_theme.direction[direction_sym]
        else
            HypertextTemplates.Library.default_theme().stack.direction[direction_sym]
        end

    # Handle gap as symbol or int
    gap_class = if gap isa Symbol
        if haskey(stack_theme, :gap) && haskey(stack_theme.gap, gap)
            stack_theme.gap[gap]
        else
            HypertextTemplates.Library.default_theme().stack.gap[gap]
        end
    else
        # Use gap prefix for numeric values
        gap_prefix = get(
            stack_theme,
            :gap_prefix,
            HypertextTemplates.Library.default_theme().stack.gap_prefix,
        )
        "$(gap_prefix)$(gap)"
    end

    # Get wrap class
    wrap_class =
        wrap ?
        get(stack_theme, :wrap, HypertextTemplates.Library.default_theme().stack.wrap) : ""

    # Get align class with fallback
    align_class = if haskey(stack_theme, :align) && haskey(stack_theme.align, align_sym)
        stack_theme.align[align_sym]
    else
        HypertextTemplates.Library.default_theme().stack.align[align_sym]
    end

    # Get justify class with fallback
    justify_class =
        if haskey(stack_theme, :justify) && haskey(stack_theme.justify, justify_sym)
            stack_theme.justify[justify_sym]
        else
            HypertextTemplates.Library.default_theme().stack.justify[justify_sym]
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
