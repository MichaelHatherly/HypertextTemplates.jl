"""
    @Spinner

A loading spinner component that provides visual feedback during asynchronous operations. Spinners are crucial for maintaining user engagement during loading states, preventing users from thinking the application has frozen or crashed. This simple yet effective component uses smooth rotation animation and comes in multiple sizes and colors to fit various contexts, from small inline loading indicators to full-page loading states. The spinner automatically includes proper ARIA attributes for accessibility.

# Props
- `size::Union{Symbol,String}`: Spinner size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Spinner color (`:slate`, `:primary`, `:white`) (default: `:primary`)
"""
@component function Spinner(;
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract spinner theme safely
    spinner_theme = if isa(theme, NamedTuple) && haskey(theme, :spinner)
        theme.spinner
    else
        HypertextTemplates.Library.default_theme().spinner
    end

    # Get container class
    container_class = get(
        spinner_theme,
        :container,
        HypertextTemplates.Library.default_theme().spinner.container,
    )
    svg_base = get(
        spinner_theme,
        :svg_base,
        HypertextTemplates.Library.default_theme().spinner.svg_base,
    )

    # Get size class with fallback
    size_class = if haskey(spinner_theme, :sizes) && haskey(spinner_theme.sizes, size_sym)
        spinner_theme.sizes[size_sym]
    else
        HypertextTemplates.Library.default_theme().spinner.sizes[size_sym]
    end

    # Get color class with fallback
    color_class =
        if haskey(spinner_theme, :colors) && haskey(spinner_theme.colors, color_sym)
            spinner_theme.colors[color_sym]
        else
            HypertextTemplates.Library.default_theme().spinner.colors[color_sym]
        end

    # Get SVG template
    svg_template =
        get(spinner_theme, :svg, HypertextTemplates.Library.default_theme().spinner.svg)

    # Replace :classes placeholder with actual classes
    svg_content = replace(svg_template, ":classes" => "$svg_base $size_class $color_class")

    @div {class = container_class, role = "status", "aria-label" = "Loading", attrs...} begin
        @text HypertextTemplates.SafeString(svg_content)
    end
end

@deftag macro Spinner end
