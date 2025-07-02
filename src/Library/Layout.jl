"""
    @Container

A responsive container component that constrains content width and provides consistent padding. This component serves as the primary layout wrapper for page content, ensuring readable line lengths and appropriate spacing across different screen sizes. It automatically centers content and applies responsive breakpoints to maintain optimal viewing experiences from mobile devices to large desktop displays.

# Props
- `size::Union{Symbol,String}`: Container size (`:sm`, `:md`, `:lg`, `:xl`, `"2xl"`, `:full`) (default: `:xl`)
- `padding::Bool`: Whether to include horizontal padding (default: `true`)
- `centered::Bool`: Whether to center the container (default: `true`)
- `role::Union{String,Nothing}`: ARIA role for the container (e.g., "main") (optional)
- `glass::Bool`: Whether to apply glassmorphism effect (default: `false`)

# Slots
- Content to be contained within the responsive wrapper

# Example
```julia
@Container {size = :lg} begin
    @Heading "Welcome"
    @Text "This content is constrained to a large container width."
end

# With glass effect
@Container {glass = true, size = :md} begin
    @Card "Glassmorphic content"
end
```

# See also
- [`Section`](@ref) - For page sections with vertical spacing
- [`Stack`](@ref) - For stacking elements with consistent gaps
- [`Grid`](@ref) - For grid-based layouts
"""
@component function Container(;
    size::Union{Symbol,String} = :xl,
    padding::Bool = true,
    centered::Bool = true,
    role::Union{String,Nothing} = nothing,
    glass::Bool = false,
    attrs...,
)
    # Convert to symbol
    size_sym = Symbol(size)

    size_classes = (
        sm = "max-w-screen-sm",
        md = "max-w-screen-md",
        lg = "max-w-screen-lg",
        xl = "max-w-screen-xl",
        var"2xl" = "max-w-screen-2xl",
        full = "max-w-full",
    )

    size_class = get(size_classes, size_sym, "max-w-screen-xl")
    padding_class = padding ? "px-4 sm:px-6 lg:px-8" : ""
    centered_class = centered ? "mx-auto" : ""
    glass_class =
        glass ?
        "backdrop-blur-sm bg-white/80 dark:bg-gray-900/80 rounded-2xl shadow-xl ring-1 ring-black/5 dark:ring-white/5 p-6" :
        ""

    @div {
        class = "$size_class $padding_class $centered_class $glass_class transition-all duration-300",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Container end

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
    base_cols = "grid-cols-$cols"
    sm_cols = isnothing(sm) ? "" : "sm:grid-cols-$sm"
    md_cols = isnothing(md) ? "" : "md:grid-cols-$md"
    lg_cols = isnothing(lg) ? "" : "lg:grid-cols-$lg"
    xl_cols = isnothing(xl) ? "" : "xl:grid-cols-$xl"
    gap_class = "gap-$gap"

    @div {
        class = "grid $base_cols $sm_cols $md_cols $lg_cols $xl_cols $gap_class",
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Grid end

"""
    @Section

A semantic section component with consistent vertical spacing for page structure. Section provides a standardized way to divide your page into distinct content areas with appropriate padding and optional background colors. It helps maintain visual hierarchy and breathing room between different parts of your page, making it perfect for hero sections, feature showcases, content blocks, and any logical grouping of related information.

# Props
- `spacing::Union{Symbol,String}`: Vertical spacing size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `background::Union{String,Nothing}`: Background color class (optional)

# Slots
- Section content

# Example
```julia
# Hero section
@Section {spacing = :lg, background = "bg-gray-50 dark:bg-gray-900"} begin
    @Container begin
        @Heading {level = 1} "Welcome to our site"
        @Text {variant = :lead} "Discover amazing features"
    end
end

# Content section
@Section begin
    @Container begin
        @Grid {cols = 1, md = 2} begin
            @div "Feature 1"
            @div "Feature 2"
        end
    end
end
```

# See also
- [`Container`](@ref) - For constraining content within sections
- [`Stack`](@ref) - For organizing section content
- [`Grid`](@ref) - For section grid layouts
"""
@component function Section(;
    spacing::Union{Symbol,String} = :md,
    background::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbol
    spacing_sym = Symbol(spacing)

    spacing_classes = (
        sm = "py-8 sm:py-12",
        md = "py-12 sm:py-16 md:py-20",
        lg = "py-16 sm:py-20 md:py-24 lg:py-32",
    )

    spacing_class = get(spacing_classes, spacing_sym, "py-12 sm:py-16 md:py-20")
    bg_class = isnothing(background) ? "" : background

    @section {class = "$spacing_class $bg_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Section end
