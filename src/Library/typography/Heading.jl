"""
    @Heading

A semantic heading component that establishes clear visual hierarchy and structure in your content through flexible typography options. Headings are fundamental to web accessibility and SEO, providing both visual and semantic structure that helps users and search engines understand content organization. This component automatically renders the appropriate HTML heading element (h1-h6) based on the specified level while allowing complete control over visual appearance through size overrides, weight adjustments, and color options. Special features like gradient text effects enable eye-catching headlines that maintain readability and accessibility standards.

# Props
- `level::Int`: Heading level (`1`-`6`) (default: `1`)
- `size::Union{Symbol,String,Nothing}`: Override size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`, `"2xl"`, `"3xl"`, `"4xl"`, `"5xl"`, `"6xl"`) (optional)
- `weight::Union{Symbol,String}`: Font weight (`:light`, `:normal`, `:medium`, `:semibold`, `:bold`, `:extrabold`) (default: `:bold`)
- `color::Union{String,Nothing}`: Text color class (optional)
- `gradient::Bool`: Whether to use gradient text effect (default: `false`)
- `tracking::Union{Symbol,String}`: Letter spacing (`:tight`, `:normal`, `:wide`) (default: `:tight`)

# Slots
- Heading text content

# Example
```julia
# Basic headings
@Heading "Welcome to Our Site"
@Heading {level = 2} "About Us"
@Heading {level = 3, weight = :medium} "Our Services"

# Gradient heading
@Heading {gradient = true} "Amazing Features"

# Custom sized heading
@Heading {level = 2, size = "4xl"} "Large Subheading"

# Colored heading
@Heading {level = 4, color = "text-blue-600 dark:text-blue-400"} "Blue Heading"
```

# See also
- [`Text`](@ref) - For body text
- [`Link`](@ref) - For hyperlinks
- [`Badge`](@ref) - For small labels
"""
@component function Heading(;
    level::Int = 1,
    size::Union{Symbol,String,Nothing} = nothing,
    weight::Union{Symbol,String} = :bold,
    color::Union{String,Nothing} = nothing,
    gradient::Bool = false,
    tracking::Union{Symbol,String} = :tight,
    attrs...,
)
    # Default sizes for each heading level
    default_sizes = (
        #= 1 =#"text-4xl sm:text-5xl",
        #= 2 =#"text-3xl sm:text-4xl",
        #= 3 =#"text-2xl sm:text-3xl",
        #= 4 =#"text-xl sm:text-2xl",
        #= 5 =#"text-lg sm:text-xl",
        #= 6 =#"text-base sm:text-lg",
    )

    # Convert to symbols
    size_sym = isnothing(size) ? size : Symbol(size)
    weight_sym = Symbol(weight)
    tracking_sym = Symbol(tracking)

    # Size overrides
    size_classes = (
        xs = "text-xs",
        sm = "text-sm",
        base = "text-base",
        lg = "text-lg",
        xl = "text-xl",
        var"2xl" = "text-2xl",
        var"3xl" = "text-3xl",
        var"4xl" = "text-4xl",
        var"5xl" = "text-5xl",
    )

    weight_classes = (
        light = "font-light",
        normal = "font-normal",
        medium = "font-medium",
        semibold = "font-semibold",
        bold = "font-bold",
        extrabold = "font-extrabold",
    )

    tracking_classes =
        (tight = "tracking-tight", normal = "tracking-normal", wide = "tracking-wide")

    size_class =
        isnothing(size_sym) ? _get(default_sizes, level, "text-2xl") :
        get(size_classes, size_sym, "text-2xl")
    weight_class = get(weight_classes, weight_sym, "font-bold")
    tracking_class = get(tracking_classes, tracking_sym, "tracking-tight")

    if gradient
        color_class = "bg-gradient-to-r from-indigo-500 to-indigo-600 bg-clip-text text-transparent"
    else
        color_class = isnothing(color) ? "text-slate-900 dark:text-slate-100" : color
    end

    elements = (
        #= 1 =#Elements.h1,
        #= 2 =#Elements.h2,
        #= 3 =#Elements.h3,
        #= 4 =#Elements.h4,
        #= 5 =#Elements.h5,
        #= 6 =#Elements.h6,
    )
    element = _get(elements, level, Elements.h1)

    @<element {class = "$size_class $weight_class $color_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Heading end
