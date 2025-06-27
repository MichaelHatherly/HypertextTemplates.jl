"""
    @Container

A responsive container component with proper max-widths and padding.

# Props
- `size::Union{Symbol,String}`: Container size (`:sm`, `:md`, `:lg`, `:xl`, `"2xl"`) (default: `:xl`)
- `padding::Bool`: Whether to include horizontal padding (default: `true`)
- `centered::Bool`: Whether to center the container (default: `true`)
"""
@component function Container(;
    size::Union{Symbol,String} = :xl,
    padding::Bool = true,
    centered::Bool = true,
    attrs...,
)
    # Convert to symbol
    size_sym = Symbol(size)

    size_classes = Dict(
        :sm => "max-w-screen-sm",
        :md => "max-w-screen-md",
        :lg => "max-w-screen-lg",
        :xl => "max-w-screen-xl",
        Symbol("2xl") => "max-w-screen-2xl",
    )

    size_class = get(size_classes, size_sym, "max-w-screen-xl")
    padding_class = padding ? "px-4 sm:px-6 lg:px-8" : ""
    centered_class = centered ? "mx-auto" : ""

    @div {class="$size_class $padding_class $centered_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Container end

"""
    @Stack

A flexible stack component for vertical or horizontal layouts with consistent spacing.

# Props
- `direction::Union{Symbol,String}`: Stack direction (`:vertical` or `:horizontal`) (default: `:vertical`)
- `gap::Int`: Gap size using Tailwind spacing scale (default: `4`)
- `align::Union{Symbol,String}`: Alignment (`:start`, `:center`, `:end`, `:stretch`) (default: `:stretch`)
- `justify::Union{Symbol,String}`: Justification (`:start`, `:center`, `:end`, `:between`, `:around`, `:evenly`) (default: `:start`)
"""
@component function Stack(;
    direction::Union{Symbol,String} = :vertical,
    gap::Int = 4,
    align::Union{Symbol,String} = :stretch,
    justify::Union{Symbol,String} = :start,
    attrs...,
)
    # Convert to symbols
    direction_sym = Symbol(direction)
    align_sym = Symbol(align)
    justify_sym = Symbol(justify)

    direction_class = direction_sym == :horizontal ? "flex-row" : "flex-col"
    gap_class = "gap-$gap"

    align_classes = Dict(
        :start => "items-start",
        :center => "items-center",
        :end => "items-end",
        :stretch => "items-stretch",
    )

    justify_classes = Dict(
        :start => "justify-start",
        :center => "justify-center",
        :end => "justify-end",
        :between => "justify-between",
        :around => "justify-around",
        :evenly => "justify-evenly",
    )

    align_class = get(align_classes, align_sym, "items-stretch")
    justify_class = get(justify_classes, justify_sym, "justify-start")

    @div {class="flex $direction_class $gap_class $align_class $justify_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Stack end

"""
    @Grid

A responsive grid layout component.

# Props
- `cols::Int`: Default number of columns (default: `1`)
- `sm::Int`: Columns on small screens (optional)
- `md::Int`: Columns on medium screens (optional)
- `lg::Int`: Columns on large screens (optional)
- `xl::Int`: Columns on extra large screens (optional)
- `gap::Int`: Gap size using Tailwind spacing scale (default: `4`)
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
    base_cols = "grid-cols-$cols"
    sm_cols = isnothing(sm) ? "" : "sm:grid-cols-$sm"
    md_cols = isnothing(md) ? "" : "md:grid-cols-$md"
    lg_cols = isnothing(lg) ? "" : "lg:grid-cols-$lg"
    xl_cols = isnothing(xl) ? "" : "xl:grid-cols-$xl"
    gap_class = "gap-$gap"

    @div {class="grid $base_cols $sm_cols $md_cols $lg_cols $xl_cols $gap_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Grid end

"""
    @Section

A page section component with consistent vertical spacing.

# Props
- `spacing::Union{Symbol,String}`: Vertical spacing size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `background::Union{String,Nothing}`: Background color class (optional)
"""
@component function Section(;
    spacing::Union{Symbol,String} = :md,
    background::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbol
    spacing_sym = Symbol(spacing)

    spacing_classes = Dict(
        :sm => "py-8 sm:py-12",
        :md => "py-12 sm:py-16 md:py-20",
        :lg => "py-16 sm:py-20 md:py-24 lg:py-32",
    )

    spacing_class = get(spacing_classes, spacing_sym, "py-12 sm:py-16 md:py-20")
    bg_class = isnothing(background) ? "" : background

    @section {class="$spacing_class $bg_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Section end
