"""
    @Divider

Horizontal or vertical separator component.

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
    # Convert to symbol
    orientation_sym = Symbol(orientation)

    default_spacing = orientation_sym === :horizontal ? "my-4" : "mx-4"
    spacing_class = isnothing(spacing) ? default_spacing : spacing
    color_class = isnothing(color) ? "border-slate-200 dark:border-slate-800" : color

    if orientation_sym === :horizontal
        @hr {class = "border-t $color_class $spacing_class", role = "separator", attrs...}
    else
        @div {
            class = "inline-block min-h-[1em] w-0.5 self-stretch bg-slate-200 dark:bg-slate-800 $spacing_class",
            role = "separator",
            "aria-orientation" = "vertical",
            attrs...,
        }
    end
end

@deftag macro Divider end

"""
    @Avatar

User profile image component.

# Props
- `src::Union{String,Nothing}`: Image source URL (optional)
- `alt::String`: Alternative text (required when src is provided, ignored otherwise)
- `size::Union{Symbol,String}`: Avatar size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `shape::Union{Symbol,String}`: Avatar shape (`:circle`, `:square`) (default: `:circle`)
- `fallback::Union{String,Nothing}`: Fallback content when no src provided (optional)
"""
@component function Avatar(;
    src::Union{AbstractString,Nothing} = nothing,
    alt::Union{AbstractString,Nothing} = nothing,
    size::Union{Symbol,String} = :md,
    shape::Union{Symbol,String} = :circle,
    fallback::Union{AbstractString,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    shape_sym = Symbol(shape)

    size_classes = (
        xs = "h-6 w-6 text-xs",
        sm = "h-8 w-8 text-sm",
        md = "h-10 w-10 text-base",
        lg = "h-12 w-12 text-lg",
        xl = "h-16 w-16 text-xl",
    )

    size_class = get(size_classes, size_sym, size_classes.md)
    shape_class = shape_sym === :circle ? "rounded-full" : "rounded-lg"

    # Default background color for fallback avatars
    default_bg = if !isnothing(src)
        "bg-slate-100 dark:bg-slate-800"
    else
        "bg-blue-500 dark:bg-blue-600"
    end

    # Build component default attributes
    component_attrs = (
        class = "relative inline-flex $size_class $shape_class overflow-hidden $default_bg",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        if !isnothing(src)
            # Require meaningful alt text for images
            if isnothing(alt)
                error("Avatar: alt text is required when src is provided")
            end
            @img {src = src, alt = alt, class = "h-full w-full object-cover"}
        else
            # Fallback content
            @div {
                class = "flex h-full w-full items-center justify-center font-medium text-white",
            } begin
                if !isnothing(fallback)
                    @text fallback
                else
                    # Default user icon
                    @text HypertextTemplates.SafeString(
                        """<svg class="h-1/2 w-1/2" fill="currentColor" viewBox="0 0 24 24"><path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" /></svg>""",
                    )
                end
            end
        end
    end
end

@deftag macro Avatar end

"""
    @ThemeToggle

Theme toggle button component that cycles through light, dark, and system themes.

# Props
- `id::String`: HTML id for the button (default: `"theme-toggle"`)
- `variant::Union{Symbol,String}`: Button variant style (`:default`, `:ghost`, `:outline`) (default: `:default`)
- `size::Union{Symbol,String}`: Button size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `show_label::Bool`: Whether to show text label alongside icon (default: `true`)
- `class::String`: Additional CSS classes (optional)

# Example
```julia
@ThemeToggle {}
@ThemeToggle {variant = :ghost, size = :sm, show_label = false}
```

# Requirements
This component requires Alpine.js to be included in your page.
"""
@component function ThemeToggle(;
    id::String = "theme-toggle",
    variant::Union{Symbol,String} = :default,
    size::Union{Symbol,String} = :md,
    show_label::Bool = true,
    class::String = "",
    attrs...,
)
    # Load JavaScript for theme functionality
    @__once__ begin
        @script @text SafeString(
            read(joinpath(@__DIR__, "assets", "theme-toggle.js"), String),
        )
    end

    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    # Base classes
    base_classes = "inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-slate-400 dark:focus:ring-slate-600"

    # Variant classes
    variant_classes = (
        default = "bg-slate-100 dark:bg-slate-700 hover:bg-slate-200 dark:hover:bg-slate-600 text-slate-700 dark:text-slate-300",
        ghost = "hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300",
        outline = "border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300",
    )

    # Size classes
    size_classes = (
        sm = "px-2.5 py-1.5 text-sm rounded",
        md = "px-3 py-2 text-sm rounded-lg",
        lg = "px-4 py-2.5 text-base rounded-lg",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes.default)
    size_class = get(size_classes, size_sym, size_classes.md)

    # Build component attributes with Alpine.js
    component_attrs = (
        id = id,
        type = "button",
        var"x-data" = "themeToggle()",
        var"@click" = "toggle()",
        class = "$base_classes $variant_class $size_class $class",
        title = "Toggle theme",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @button {merged_attrs...} begin
        if show_label
            @span {var"x-text" = "`\${currentIcon} \${currentLabel}`"} "💻 System"
        else
            # Icon only - still needs text for screen readers
            @span {"aria-hidden" = "true", var"x-text" = "currentIcon"} "💻"
            @span {class = "sr-only"} "Toggle theme"
        end
    end
end

@deftag macro ThemeToggle end

"""
    @Tooltip

Simple tooltip component that shows text on hover.

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

# Example
```julia
@Tooltip {text = "Delete this item"} begin
    @Button {variant = :danger, size = :sm} begin
        @Icon {name = "trash"}
    end
end
```
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
    # Load JavaScript for tooltip functionality
    @__once__ begin
        @script @text SafeString(read(joinpath(@__DIR__, "assets/tooltip.js"), String))
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

    # Variant styles
    variant_classes = (
        dark = "bg-gray-900 text-white",
        light = "bg-white text-gray-900 border border-gray-200",
    )

    # Size classes
    size_classes = (sm = "text-sm", base = "text-base")

    variant_class = get(variant_classes, variant_sym, variant_classes.dark)
    size_class = get(size_classes, size_sym, size_classes.sm)

    @div {
        var"x-data" = SafeString("tooltip($config)"),
        class = "relative inline-block",
        attrs...,
    } begin
        # Trigger wrapper
        @div {var"x-ref" = "trigger", class = "inline-block"} begin
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
            class = "absolute z-[9999] rounded-lg shadow-lg $variant_class $class",
            style = "max-width: $max_width; width: max-content;",
            role = "tooltip",
        } begin
            @div {class = "px-3 py-2 $size_class"} begin
                @text text
            end
        end
    end
end

@deftag macro Tooltip end

"""
    @TooltipWrapper

Wrapper component for rich tooltip content using composition pattern.

# Props
- `placement::Union{Symbol,String}`: Tooltip placement (default: `:top`)
- `delay::Int`: Show delay in milliseconds (default: `500`)
- `hide_delay::Int`: Hide delay in milliseconds (default: `0`)
- `offset::Int`: Distance from trigger in pixels (default: `8`)
- `trigger::Union{Symbol,String}`: Trigger type (`:hover`, `:click`, `:focus`) (default: `:hover`)
- `interactive::Bool`: Keep open when hovering tooltip content (default: `false`)

# Example
```julia
@TooltipWrapper {interactive = true} begin
    @TooltipTrigger begin
        @Badge "PRO"
    end
    @TooltipContent {variant = :light, arrow = true} begin
        @Heading {level = 4, size = :sm} "Pro Feature"
        @Text {size = :sm} "Upgrade to access advanced features"
    end
end
```
"""
@component function TooltipWrapper(;
    placement::Union{Symbol,String} = :top,
    delay::Int = 500,
    hide_delay::Int = 0,
    offset::Int = 8,
    trigger::Union{Symbol,String} = :hover,
    interactive::Bool = false,
    attrs...,
)
    # Load JavaScript for tooltip functionality
    @__once__ begin
        @script @text SafeString(read(joinpath(@__DIR__, "assets/tooltip.js"), String))
    end

    # Convert to symbols
    placement_sym = Symbol(placement)
    trigger_sym = Symbol(trigger)

    # Build configuration
    config = SafeString("""{
        delay: $delay,
        hideDelay: $hide_delay,
        trigger: '$(string(trigger_sym))',
        placement: '$(string(placement_sym))',
        offset: $offset,
        interactive: $(interactive ? "true" : "false")
    }""")

    @div {
        var"x-data" = SafeString("tooltip($config)"),
        class = "relative inline-block",
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro TooltipWrapper end

"""
    @TooltipTrigger

Trigger element for TooltipWrapper. Wraps the element that triggers the tooltip.

# Props
- `class::String`: Additional CSS classes (optional)
- `attrs...`: Additional attributes
"""
@component function TooltipTrigger(; class::String = "", attrs...)
    @div {var"x-ref" = "trigger", class = "inline-block $class", attrs...} begin
        @__slot__()
    end
end

@deftag macro TooltipTrigger end

"""
    @TooltipContent

Content component for TooltipWrapper. Contains the rich tooltip content.

# Props
- `variant::Union{Symbol,String}`: Visual style (`:dark`, `:light`) (default: `:dark`)
- `arrow::Bool`: Show arrow pointing to trigger (default: `true`)
- `max_width::String`: Maximum width (default: `"300px"`)
- `class::String`: Additional CSS classes (optional)
- `attrs...`: Additional attributes
"""
@component function TooltipContent(;
    variant::Union{Symbol,String} = :dark,
    arrow::Bool = true,
    max_width::String = "300px",
    class::String = "",
    attrs...,
)
    # Convert to symbol
    variant_sym = Symbol(variant)

    # Variant styles
    variant_classes = (
        dark = "bg-gray-900 text-white",
        light = "bg-white text-gray-900 border border-gray-200",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes.dark)

    # Arrow classes based on variant
    arrow_classes = (dark = "bg-gray-900", light = "bg-white border-gray-200")

    arrow_class = get(arrow_classes, variant_sym, arrow_classes.dark)

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
        class = "absolute z-[9999] rounded-lg shadow-lg $variant_class $class",
        style = "max-width: $max_width; width: max-content;",
        role = "tooltip",
        attrs...,
    } begin
        # Arrow (if enabled)
        if arrow
            # Note: Arrow positioning with Alpine Anchor is complex
            # For now, we'll skip the visual arrow but keep the prop for future enhancement
        end

        @div {class = "px-4 py-3"} begin
            @__slot__()
        end
    end
end

@deftag macro TooltipContent end
