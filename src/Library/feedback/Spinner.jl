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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())
    
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)
    
    # Direct theme access
    container_class = theme.spinner.container
    svg_base = theme.spinner.svg_base
    size_class = theme.spinner.sizes[size_sym]
    color_class = theme.spinner.colors[color_sym]
    svg_template = theme.spinner.svg

    # Replace :classes placeholder with actual classes
    svg_content = replace(svg_template, ":classes" => "$svg_base $size_class $color_class")

    @div {class = container_class, role = "status", "aria-label" = "Loading", attrs...} begin
        @text HypertextTemplates.SafeString(svg_content)
    end
end

@deftag macro Spinner end
