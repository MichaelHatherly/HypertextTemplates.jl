"""
    @TooltipContent

The content component within TooltipWrapper that defines tooltip popup content with rich formatting support. Can contain any HTML content including headings, lists, images, or interactive elements with consistent styling and smooth transitions.

# Props
- `variant::Union{Symbol,String}`: Visual style (`:dark`, `:light`) (default: `:dark`)
- `arrow::Bool`: Show arrow pointing to trigger (default: `true`)
- `max_width::String`: Maximum width (default: `"300px"`)
- `class::String`: Additional CSS classes (optional)
- `attrs...`: Additional attributes

# Slots
- Tooltip content - can contain any components or rich formatting

# Example
```julia
@TooltipContent {variant = :light} begin
    @Stack {gap = :sm} begin
        @Heading {level = 5} "Tooltip Title"
        @Text {size = :sm} "This tooltip can contain any content."
        @Stack {direction = :horizontal, gap = :xs} begin
            @Badge "Tag 1"
            @Badge "Tag 2"
        end
    end
end
```

# Accessibility
**ARIA:** Uses `role="tooltip"` while preserving rich content structure for assistive technology.

**Keyboard:** Interactive content is accessible with Tab navigation, Escape dismisses.

**Guidelines:** Use headings for structure, ensure proper labels, maintain color contrast.

# See also
- [`TooltipWrapper`](@ref) - Parent wrapper component
- [`TooltipTrigger`](@ref) - Trigger component
- [`Card`](@ref) - For similar content styling
"""
@component function TooltipContent(;
    variant::Union{Symbol,String} = :dark,
    arrow::Bool = true,
    max_width::String = "300px",
    class::String = "",
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    tooltip_content_theme = theme.tooltip_content
    base_class = tooltip_content_theme.base
    padding_class = tooltip_content_theme.padding
    variants_theme = tooltip_content_theme.variants
    arrow_variants_theme = tooltip_content_theme.arrow_variants

    # Convert to symbol
    variant_sym = Symbol(variant)

    # Get variant classes
    variant_class = get(variants_theme, variant_sym, variants_theme.dark)
    arrow_class = get(arrow_variants_theme, variant_sym, arrow_variants_theme.dark)

    @div {
        var"x-ref" = "content",
        var"x-show" = "open",
        var"x-anchor" = SafeString("anchorDirective"),
        var"x-anchor:element" = SafeString("\$refs.trigger"),
        var"x-transition:enter" = "transition ease-out duration-200",
        var"x-transition:enter-start" = "opacity-0 scale-95",
        var"x-transition:enter-end" = "opacity-100 scale-100",
        var"x-transition:leave" = "transition ease-in duration-150",
        var"x-transition:leave-start" = "opacity-100 scale-100",
        var"x-transition:leave-end" = "opacity-0 scale-95",
        class = "$base_class $variant_class $class",
        style = "max-width: $max_width; width: max-content;",
        role = "tooltip",
        attrs...,
    } begin
        # Arrow (if enabled)
        if arrow
            # Note: Arrow positioning with Alpine Anchor is complex
            # For now, we'll skip the visual arrow but keep the prop for future enhancement
        end

        @div {class = padding_class} begin
            @__slot__()
        end
    end
end

@deftag macro TooltipContent end
