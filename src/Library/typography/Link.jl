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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract link theme safely
    link_theme = if isa(theme, NamedTuple) && haskey(theme, :link)
        theme.link
    else
        HypertextTemplates.Library.default_theme().link
    end

    # Get default color
    default_color = get(
        link_theme,
        :default_color,
        HypertextTemplates.Library.default_theme().link.default_color,
    )

    # Get variants
    variants_theme = if isa(link_theme, NamedTuple) && haskey(link_theme, :variants)
        link_theme.variants
    else
        HypertextTemplates.Library.default_theme().link.variants
    end

    # Convert to symbol
    variant_sym = Symbol(variant)

    variant_class = get(
        variants_theme,
        variant_sym,
        get(
            variants_theme,
            :default,
            HypertextTemplates.Library.default_theme().link.variants.default,
        ),
    )
    color_class = isnothing(color) ? default_color : color

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
