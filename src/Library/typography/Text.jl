# Required for Julia 1.12+
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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract text theme safely
    text_theme = if isa(theme, NamedTuple) && haskey(theme, :text)
        theme.text
    else
        HypertextTemplates.Library.default_theme().text
    end

    # Get default color
    default_color = get(
        text_theme,
        :default_color,
        HypertextTemplates.Library.default_theme().text.default_color,
    )

    # Get nested themes
    variants_theme = if isa(text_theme, NamedTuple) && haskey(text_theme, :variants)
        text_theme.variants
    else
        HypertextTemplates.Library.default_theme().text.variants
    end

    sizes_theme = if isa(text_theme, NamedTuple) && haskey(text_theme, :sizes)
        text_theme.sizes
    else
        HypertextTemplates.Library.default_theme().text.sizes
    end

    weights_theme = if isa(text_theme, NamedTuple) && haskey(text_theme, :weights)
        text_theme.weights
    else
        HypertextTemplates.Library.default_theme().text.weights
    end

    align_theme = if isa(text_theme, NamedTuple) && haskey(text_theme, :align)
        text_theme.align
    else
        HypertextTemplates.Library.default_theme().text.align
    end

    # Convert to symbols
    size_sym = isnothing(size) ? size : Symbol(size)
    variant_sym = Symbol(variant)
    weight_sym = Symbol(weight)
    align_sym = Symbol(align)

    base_class = get(
        variants_theme,
        variant_sym,
        get(
            variants_theme,
            :body,
            HypertextTemplates.Library.default_theme().text.variants.body,
        ),
    )
    size_class = isnothing(size_sym) ? "" : get(sizes_theme, size_sym, "")
    weight_class = get(
        weights_theme,
        weight_sym,
        get(
            weights_theme,
            :normal,
            HypertextTemplates.Library.default_theme().text.weights.normal,
        ),
    )
    color_class = isnothing(color) ? default_color : color
    align_class = get(
        align_theme,
        align_sym,
        get(align_theme, :left, HypertextTemplates.Library.default_theme().text.align.left),
    )

    @p {class = "$base_class $size_class $weight_class $color_class $align_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Text end
