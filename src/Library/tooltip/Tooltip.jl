"""
    @Tooltip

A simple tooltip component that displays contextual information on hover or focus with intelligent positioning. Features customizable delays, smooth animations, and automatic positioning using Alpine Anchor with dark and light variants.

# Props
- `text::String`: The tooltip text to display (required)
- `placement::Union{Symbol,String}`: Tooltip placement (`:top`, `:bottom`, `:left`, `:right`) (default: `:top`)
- `delay::Int`: Show delay in milliseconds (default: `500`)
- `hide_delay::Int`: Hide delay in milliseconds (default: `0`)
- `offset::Int`: Distance from trigger in pixels (default: `8`)
- `variant::Union{Symbol,String}`: Visual style (`:dark`, `:light`) (default: `:dark`)
- `size::Union{Symbol,String}`: Text size (`:sm`, `:base`) (default: `:sm`)
- `max_width::String`: Maximum width of tooltip (default: `"250px"`)
- `class::String`: Additional CSS classes (optional)

# Slots
- Trigger element - the element that shows the tooltip on hover

# Example
```julia
# Icon with tooltip
@Tooltip {text = "Delete this item"} begin
    @Button {variant = :danger, size = :sm} begin
        @Icon {name = "trash"}
    end
end

# Text with tooltip
@Tooltip {text = "Click to learn more about this feature"} begin
    @Link {href = "/help"} "What's this?"
end

# Badge with light tooltip
@Tooltip {text = "Premium features included", variant = :light} begin
    @Badge {variant = :gradient} "PRO"
end
```

# Requirements
This component requires Alpine.js and Alpine Anchor for intelligent positioning:

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/anchor@latest/dist/cdn.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

**Browser Compatibility:** Modern browsers with ES6 support  
**Dependencies:** Tailwind CSS for styling classes

**Note:** JavaScript assets are automatically loaded via `@__once__` for optimal performance.

# Accessibility
**ARIA:** Uses `role="tooltip"` with `aria-describedby` relationship to trigger element.

**Keyboard:** Escape dismisses, Tab moves focus away. Appears on both hover and focus events.

**Focus Management:** Non-interactive tooltip keeps focus on trigger element.

# See also
- [`TooltipWrapper`](@ref) - For rich tooltip content
- [`Alert`](@ref) - For persistent help messages
- [`Badge`](@ref) - Common tooltip trigger
"""
@component function Tooltip(;
    text::String,
    placement::Union{Symbol,String} = :top,
    delay::Int = 500,
    hide_delay::Int = 0,
    offset::Int = 8,
    variant::Union{Symbol,String} = :dark,
    size::Union{Symbol,String} = :sm,
    max_width::String = "250px",
    class::String = "",
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())
    tooltip_theme = theme.tooltip

    # Get container and trigger wrapper classes
    container_class = tooltip_theme.container
    trigger_wrapper_class = tooltip_theme.trigger_wrapper

    # Get content theme
    content_theme = tooltip_theme.content
    content_base_class = content_theme.base
    content_padding_class = content_theme.padding

    # Get variants and sizes
    variants_theme = tooltip_theme.variants
    sizes_theme = tooltip_theme.sizes

    # Load JavaScript for tooltip functionality
    @__once__ begin
        @script @text SafeString(read(joinpath(@__DIR__, "../assets/tooltip.js"), String))
    end

    # Convert to symbols
    placement_sym = Symbol(placement)
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    # Build configuration
    config = SafeString("""{
        delay: $delay,
        hideDelay: $hide_delay,
        trigger: 'hover',
        placement: '$(string(placement_sym))',
        offset: $offset
    }""")

    # Get variant and size classes
    variant_class = get(variants_theme, variant_sym, variants_theme.dark)
    size_class = get(sizes_theme, size_sym, sizes_theme.sm)

    @div {var"x-data" = SafeString("tooltip($config)"), class = container_class, attrs...} begin
        # Trigger wrapper
        @div {var"x-ref" = "trigger", class = trigger_wrapper_class} begin
            @__slot__()
        end

        # Tooltip content
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
            class = "$content_base_class $variant_class $class",
            style = "max-width: $max_width; width: max-content;",
            role = "tooltip",
        } begin
            @div {class = "$content_padding_class $size_class"} begin
                @text text
            end
        end
    end
end

@deftag macro Tooltip end
