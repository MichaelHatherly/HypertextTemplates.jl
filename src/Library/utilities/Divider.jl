"""
    @Divider

A horizontal or vertical separator component that creates visual boundaries between sections of content. Dividers are subtle yet important design elements that help organize interfaces by creating clear visual separation without adding clutter. They guide the eye through layouts, group related content, and provide breathing room between different sections. This component supports both horizontal and vertical orientations with customizable spacing and colors, adapting seamlessly to light and dark themes while maintaining appropriate visual weight for non-intrusive content separation.

# Props
- `orientation::Union{Symbol,String}`: Divider orientation (`:horizontal`, `:vertical`) (default: `:horizontal`)
- `spacing::Union{String,Nothing}`: Custom spacing class (optional)
- `color::Union{String,Nothing}`: Border color class (optional)
"""
@component function Divider(;
    orientation::Union{Symbol,String} = :horizontal,
    spacing::Union{String,Nothing} = nothing,
    color::Union{String,Nothing} = nothing,
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbol
    orientation_sym = Symbol(orientation)

    # Direct theme access
    default_color = theme.divider.default_color
    
    if orientation_sym === :horizontal
        base_class = theme.divider.horizontal.base
        default_spacing = theme.divider.horizontal.default_spacing
        spacing_class = isnothing(spacing) ? default_spacing : spacing
        color_class = isnothing(color) ? default_color : color

        @hr {
            class = "$base_class $color_class $spacing_class",
            role = "separator",
            attrs...,
        }
    else
        base_class = theme.divider.vertical.base
        default_spacing = theme.divider.vertical.default_spacing
        default_bg = theme.divider.vertical.default_bg
        spacing_class = isnothing(spacing) ? default_spacing : spacing
        color_class = isnothing(color) ? default_bg : color

        @div {
            class = "$base_class $color_class $spacing_class",
            role = "separator",
            "aria-orientation" = "vertical",
            attrs...,
        }
    end
end

@deftag macro Divider end
