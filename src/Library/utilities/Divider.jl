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

    # Extract divider theme safely
    divider_theme = if isa(theme, NamedTuple) && haskey(theme, :divider)
        theme.divider
    else
        HypertextTemplates.Library.default_theme().divider
    end

    # Get default color
    default_color = get(
        divider_theme,
        :default_color,
        HypertextTemplates.Library.default_theme().divider.default_color,
    )

    # Get orientation themes
    horizontal_theme =
        if isa(divider_theme, NamedTuple) && haskey(divider_theme, :horizontal)
            divider_theme.horizontal
        else
            HypertextTemplates.Library.default_theme().divider.horizontal
        end

    vertical_theme = if isa(divider_theme, NamedTuple) && haskey(divider_theme, :vertical)
        divider_theme.vertical
    else
        HypertextTemplates.Library.default_theme().divider.vertical
    end

    # Convert to symbol
    orientation_sym = Symbol(orientation)

    if orientation_sym === :horizontal
        base_class = get(
            horizontal_theme,
            :base,
            HypertextTemplates.Library.default_theme().divider.horizontal.base,
        )
        default_spacing = get(
            horizontal_theme,
            :default_spacing,
            HypertextTemplates.Library.default_theme().divider.horizontal.default_spacing,
        )
        spacing_class = isnothing(spacing) ? default_spacing : spacing
        color_class = isnothing(color) ? default_color : color

        @hr {
            class = "$base_class $color_class $spacing_class",
            role = "separator",
            attrs...,
        }
    else
        base_class = get(
            vertical_theme,
            :base,
            HypertextTemplates.Library.default_theme().divider.vertical.base,
        )
        default_spacing = get(
            vertical_theme,
            :default_spacing,
            HypertextTemplates.Library.default_theme().divider.vertical.default_spacing,
        )
        default_bg = get(
            vertical_theme,
            :default_bg,
            HypertextTemplates.Library.default_theme().divider.vertical.default_bg,
        )
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
