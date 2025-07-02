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
        color_class = "bg-gradient-to-r from-blue-500 to-purple-600 bg-clip-text text-transparent"
    else
        color_class = isnothing(color) ? "text-gray-900 dark:text-gray-100" : color
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

# TODO: remove when dropping Julia 1.6 support.
if VERSION < v"1.7"
    _get(t::Tuple, i::Integer, default) = i in 1:length(t) ? getindex(t, i) : default
else
    _get(t::Tuple, i::Integer, default) = Base.get(t, i, default)
end

@deftag macro Heading end

function Text end

"""
    @Text

A paragraph text component that provides consistent typography styling for body content throughout your application. Text components form the foundation of readable interfaces, ensuring that body copy maintains appropriate line heights, spacing, and contrast across different contexts. This versatile component supports multiple variants from small supporting text to prominent lead paragraphs, with fine-grained control over size, weight, color, and alignment. It adapts seamlessly to different screen sizes and color schemes while maintaining optimal readability through carefully chosen typography defaults.

# Props
- `variant::Union{Symbol,String}`: Text variant (`:body`, `:lead`, `:small`) (default: `:body`)
- `size::Union{Symbol,String,Nothing}`: Override size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (optional)
- `weight::Union{Symbol,String}`: Font weight (`:normal`, `:medium`, `:semibold`, `:bold`) (default: `:normal`)
- `color::Union{String,Nothing}`: Text color class (optional)
- `align::Union{Symbol,String}`: Text alignment (`:left`, `:center`, `:right`, `:justify`) (default: `:left`)

# Slots
- Paragraph text content

# Example
```julia
# Basic paragraph
@Text "This is a regular paragraph of text."

# Lead paragraph
@Text {variant = :lead} "This is a larger, emphasized paragraph often used for introductions."

# Small text
@Text {variant = :small, color = "text-gray-600"} "This is smaller supporting text."

# Centered bold text
@Text {align = :center, weight = :bold} "Centered bold statement"

# Custom styled text
@Text {size = :lg, weight = :medium} "Custom sized medium weight text"
```

# See also
- [`Heading`](@ref) - For headings
- [`Link`](@ref) - For inline links
- [`Alert`](@ref) - For notification text
"""
@component function Text(;
    variant::Union{Symbol,String} = :body,
    size::Union{Symbol,String,Nothing} = nothing,
    weight::Union{Symbol,String} = :normal,
    color::Union{String,Nothing} = nothing,
    align::Union{Symbol,String} = :left,
    attrs...,
)
    variant_classes = (
        body = "text-base leading-relaxed",
        lead = "text-lg sm:text-xl leading-relaxed",
        small = "text-sm leading-normal",
    )

    size_classes =
        (xs = "text-xs", sm = "text-sm", base = "text-base", lg = "text-lg", xl = "text-xl")

    weight_classes = (
        normal = "font-normal",
        medium = "font-medium",
        semibold = "font-semibold",
        bold = "font-bold",
    )

    align_classes = (
        left = "text-left",
        center = "text-center",
        right = "text-right",
        justify = "text-justify",
    )

    # Convert to symbols
    size_sym = isnothing(size) ? size : Symbol(size)
    variant_sym = Symbol(variant)
    weight_sym = Symbol(weight)
    align_sym = Symbol(align)

    base_class = get(variant_classes, variant_sym, "text-base")
    size_class = isnothing(size_sym) ? "" : get(size_classes, size_sym, "")
    weight_class = get(weight_classes, weight_sym, "font-normal")
    color_class = isnothing(color) ? "text-slate-600 dark:text-slate-400" : color
    align_class = get(align_classes, align_sym, "text-left")

    @p {class = "$base_class $size_class $weight_class $color_class $align_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Text end

"""
    @Link

A styled anchor component that creates consistent, accessible hyperlinks with smooth hover effects and proper visual feedback. Links are critical navigation elements that connect pages and resources, requiring careful attention to usability, accessibility, and visual design. This component enhances standard HTML anchors with customizable styling variants, automatic handling of external links with security attributes, and smooth color transitions that provide clear interactive feedback. It maintains proper focus states for keyboard navigation and supports integration with icons for enhanced visual communication while ensuring links remain distinguishable and accessible to all users.

# Props
- `href::String`: Link destination (required)
- `variant::Union{Symbol,String}`: Link variant (`:default`, `:underline`, `:hover_underline`) (default: `:default`)
- `color::Union{String,Nothing}`: Text color class (optional)
- `external::Bool`: Whether this is an external link (adds target="_blank") (default: `false`)
- `aria_label::Union{String,Nothing}`: ARIA label for additional context (optional)

# Slots
- Link text or content

# Example
```julia
# Basic link
@Link {href = "/about"} "About Us"

# External link
@Link {href = "https://example.com", external = true} "Visit Example.com"

# Underlined link
@Link {href = "/contact", variant = :underline} "Contact Us"

# Custom colored link
@Link {href = "/products", color = "text-purple-600 hover:text-purple-700"} "Our Products"

# Link with icon
@Link {href = "/download"} begin
    @Icon {name = "download", size = :sm}
    @text " Download PDF"
end
```

# See also
- [`Button`](@ref) - For button-style links
- [`Text`](@ref) - For regular text
- [`Heading`](@ref) - For heading text
- [`Icon`](@ref) - For link icons
"""
@component function Link(;
    href::String,
    variant::Union{Symbol,String} = :default,
    color::Union{String,Nothing} = nothing,
    external::Bool = false,
    aria_label::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbol
    variant_sym = Symbol(variant)

    variant_classes = (
        default = "transition-colors",
        underline = "underline transition-colors",
        hover_underline = "hover:underline transition-all",
    )

    variant_class = get(variant_classes, variant_sym, "transition-colors")
    color_class =
        isnothing(color) ?
        "text-slate-900 hover:text-slate-700 dark:text-slate-100 dark:hover:text-slate-300" :
        color

    if external
        @a {
            href = href,
            target = "_blank",
            rel = "noopener noreferrer",
            class = "$variant_class $color_class",
            "aria-label" = aria_label,
            attrs...,
        } begin
            @__slot__()
        end
    else
        @a {
            href = href,
            class = "$variant_class $color_class",
            "aria-label" = aria_label,
            attrs...,
        } begin
            @__slot__()
        end
    end
end

@deftag macro Link end
