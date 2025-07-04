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
