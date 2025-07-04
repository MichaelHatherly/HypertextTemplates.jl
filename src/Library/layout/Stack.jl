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

    direction_class = direction_sym == :horizontal ? "flex-row" : "flex-col"

    # Handle gap as symbol or int
    gap_presets = (xs = "gap-1", sm = "gap-2", base = "gap-4", lg = "gap-6", xl = "gap-8")

    gap_class = if gap isa Symbol
        get(gap_presets, gap, "gap-4")
    else
        "gap-$gap"
    end

    wrap_class = wrap ? "flex-wrap" : ""

    align_classes = (
        start = "items-start",
        center = "items-center",
        var"end" = "items-end",
        stretch = "items-stretch",
    )

    justify_classes = (
        start = "justify-start",
        center = "justify-center",
        var"end" = "justify-end",
        between = "justify-between",
        around = "justify-around",
        evenly = "justify-evenly",
    )

    align_class = get(align_classes, align_sym, "items-stretch")
    justify_class = get(justify_classes, justify_sym, "justify-start")

    # Build component default attributes
    component_attrs = (
        class = "flex $direction_class $gap_class $align_class $justify_class $wrap_class",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro Stack end
