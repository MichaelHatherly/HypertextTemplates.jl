"""
    @Grid

A responsive grid layout component for arranging content in columns. The Grid component provides a powerful and flexible way to create multi-column layouts that automatically adapt to different screen sizes. It handles the complexity of responsive design by allowing you to specify different column counts for various breakpoints, making it ideal for galleries, card layouts, product listings, and any content that benefits from a structured grid arrangement.

# Props
- `cols::Int`: Default number of columns (default: `1`)
- `sm::Int`: Columns on small screens (optional)
- `md::Int`: Columns on medium screens (optional)
- `lg::Int`: Columns on large screens (optional)
- `xl::Int`: Columns on extra large screens (optional)
- `gap::Int`: Gap size using Tailwind spacing scale (default: `4`)

# Slots
- Grid items to be arranged in columns

# Example
```julia
# Responsive card grid
@Grid {cols = 1, md = 2, lg = 3, gap = 6} begin
    @Card "Item 1"
    @Card "Item 2"
    @Card "Item 3"
    @Card "Item 4"
    @Card "Item 5"
    @Card "Item 6"
end

# Simple two-column layout
@Grid {cols = 2, gap = 4} begin
    @Section "Left content"
    @Section "Right content"
end
```

# See also
- [`Stack`](@ref) - For single-direction layouts
- [`Container`](@ref) - For constraining grid width
- [`Card`](@ref) - Common grid item component
"""
@component function Grid(;
    cols::Int = 1,
    sm::Union{Int,Nothing} = nothing,
    md::Union{Int,Nothing} = nothing,
    lg::Union{Int,Nothing} = nothing,
    xl::Union{Int,Nothing} = nothing,
    gap::Int = 4,
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract grid theme safely
    grid_theme = if isa(theme, NamedTuple) && haskey(theme, :grid)
        theme.grid
    else
        HypertextTemplates.Library.default_theme().grid
    end

    # Get base class
    base_class =
        get(grid_theme, :base, HypertextTemplates.Library.default_theme().grid.base)

    # Get prefixes for dynamic classes
    cols_prefix = get(
        grid_theme,
        :cols_prefix,
        HypertextTemplates.Library.default_theme().grid.cols_prefix,
    )
    sm_prefix = get(
        grid_theme,
        :sm_prefix,
        HypertextTemplates.Library.default_theme().grid.sm_prefix,
    )
    md_prefix = get(
        grid_theme,
        :md_prefix,
        HypertextTemplates.Library.default_theme().grid.md_prefix,
    )
    lg_prefix = get(
        grid_theme,
        :lg_prefix,
        HypertextTemplates.Library.default_theme().grid.lg_prefix,
    )
    xl_prefix = get(
        grid_theme,
        :xl_prefix,
        HypertextTemplates.Library.default_theme().grid.xl_prefix,
    )
    gap_prefix = get(
        grid_theme,
        :gap_prefix,
        HypertextTemplates.Library.default_theme().grid.gap_prefix,
    )

    # Build dynamic classes
    base_cols = "$(cols_prefix)$(cols)"
    sm_cols = isnothing(sm) ? "" : "$(sm_prefix)$(sm)"
    md_cols = isnothing(md) ? "" : "$(md_prefix)$(md)"
    lg_cols = isnothing(lg) ? "" : "$(lg_prefix)$(lg)"
    xl_cols = isnothing(xl) ? "" : "$(xl_prefix)$(xl)"
    gap_class = "$(gap_prefix)$(gap)"

    @div {
        class = "$base_class $base_cols $sm_cols $md_cols $lg_cols $xl_cols $gap_class",
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Grid end
