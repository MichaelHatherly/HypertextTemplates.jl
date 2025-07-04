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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract heading theme safely
    heading_theme = if isa(theme, NamedTuple) && haskey(theme, :heading)
        theme.heading
    else
        HypertextTemplates.Library.default_theme().heading
    end

    # Get theme values
    default_sizes = get(
        heading_theme,
        :default_sizes,
        HypertextTemplates.Library.default_theme().heading.default_sizes,
    )
    default_color = get(
        heading_theme,
        :default_color,
        HypertextTemplates.Library.default_theme().heading.default_color,
    )
    gradient_color = get(
        heading_theme,
        :gradient_color,
        HypertextTemplates.Library.default_theme().heading.gradient_color,
    )

    # Get nested themes
    sizes_theme = if isa(heading_theme, NamedTuple) && haskey(heading_theme, :sizes)
        heading_theme.sizes
    else
        HypertextTemplates.Library.default_theme().heading.sizes
    end

    weights_theme = if isa(heading_theme, NamedTuple) && haskey(heading_theme, :weights)
        heading_theme.weights
    else
        HypertextTemplates.Library.default_theme().heading.weights
    end

    tracking_theme = if isa(heading_theme, NamedTuple) && haskey(heading_theme, :tracking)
        heading_theme.tracking
    else
        HypertextTemplates.Library.default_theme().heading.tracking
    end

    # Convert to symbols
    size_sym = isnothing(size) ? size : Symbol(size)
    weight_sym = Symbol(weight)
    tracking_sym = Symbol(tracking)

    # Get classes
    size_class =
        isnothing(size_sym) ? _get(default_sizes, level, "text-2xl") :
        get(sizes_theme, size_sym, "text-2xl")
    weight_class = get(weights_theme, weight_sym, get(weights_theme, :bold, "font-bold"))
    tracking_class =
        get(tracking_theme, tracking_sym, get(tracking_theme, :tight, "tracking-tight"))

    if gradient
        color_class = gradient_color
    else
        color_class = isnothing(color) ? default_color : color
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

    @<element {class = "$size_class $weight_class $color_class $tracking_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Heading end
