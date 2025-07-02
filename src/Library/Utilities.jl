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

A user profile image component that displays user avatars with automatic fallbacks and consistent styling. Avatars are essential for personalizing user interfaces, making them feel more human and helping users quickly identify accounts, authors, or participants in conversations. This component handles the common challenges of avatar display including missing images, different aspect ratios, and the need for fallback representations. It provides multiple size options and shape variants (circular or square) while ensuring images load smoothly and fallbacks appear gracefully when no image is available.

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

A theme toggle button component that enables users to switch between light, dark, and system-based color schemes with a single click. Theme toggles have become essential for modern web applications, respecting user preferences and improving accessibility for users who need specific contrast levels or reduced eye strain. This component provides a smooth cycling through theme options with visual feedback, remembers user preferences across sessions, and integrates with system-level theme settings. The button adapts its appearance to the current theme and provides clear indication of the active mode through both icons and optional text labels.

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
This component requires Alpine.js to be included in your page:

```html
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

**Browser Compatibility:** Modern browsers with ES6 support  
**Dependencies:** Tailwind CSS for styling classes

**Note:** JavaScript assets are automatically loaded via `@__once__` for optimal performance.

# Accessibility
This component implements comprehensive accessibility for theme switching:

**ARIA Patterns:**
- Uses semantic `<button>` element with descriptive `title` attribute
- Button text dynamically updates to reflect current theme state
- Screen readers announce theme changes when selection occurs
- Maintains button semantics while providing theme functionality

**Keyboard Navigation:**
- **Enter/Space**: Cycles through theme options (light → dark → system)
- **Tab**: Moves focus to theme toggle button
- **Shift+Tab**: Moves focus to previous element
- All theme switching is accessible via keyboard

**Screen Reader Support:**
- Current theme state is announced through button text
- Theme changes are communicated when they occur
- Button purpose is clear through descriptive labeling
- Icon-only mode includes screen reader text for context

**Visual Design:**
- Focus indicators are clearly visible with high contrast
- Button variants maintain sufficient color contrast (4.5:1 minimum)
- Theme icons provide visual feedback for current state
- Hover and active states give clear interactive feedback

**Theme Persistence:**
- Theme preference is stored in localStorage for consistency
- System theme preference is respected and monitored
- Theme changes are applied immediately for visual feedback
- Works across browser sessions and page refreshes

**Usage Guidelines:**
- Place theme toggle in consistent, discoverable location
- Consider using icon + text for maximum clarity
- Test with all three theme states (light, dark, system)
- Ensure theme toggle itself is visible in all themes
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

A simple tooltip component that displays contextual information when users hover over or focus on elements, with intelligent positioning to stay within viewport bounds. Tooltips are invaluable for providing additional context without cluttering the interface, perfect for explaining icons, showing keyboard shortcuts, or offering helpful hints. This component features customizable delays to prevent accidental triggers, smooth fade animations for polished interactions, and automatic positioning adjustments using Alpine Anchor. It supports both dark and light variants to ensure readability in different contexts while maintaining accessibility through proper ARIA attributes.

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
This component follows WAI-ARIA best practices for tooltip implementation:

**ARIA Patterns:**
- Tooltip content uses `role="tooltip"` for proper identification
- Trigger element maintains `aria-describedby` relationship with tooltip
- Tooltip visibility state is managed through show/hide rather than DOM manipulation

**Keyboard Navigation:**
- **Escape**: Dismisses tooltip when trigger is focused
- **Tab**: Moves focus away from trigger (hides tooltip)
- **Enter/Space**: Shows tooltip when trigger button is focused

**Screen Reader Support:**
- Tooltip text is announced when trigger receives focus
- Tooltip content is available to screen readers via `aria-describedby`
- Dismissal of tooltip is communicated to assistive technology
- Tooltip text is read in context with trigger element

**Focus Management:**
- Tooltip appears on both hover and focus events
- Focus remains on trigger element (tooltip is non-interactive)
- Tooltip dismisses when focus moves away from trigger
- Keyboard users get equivalent experience to mouse users

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

A wrapper component that enables rich, interactive tooltips with custom content through a flexible composition pattern. While simple tooltips handle text, many interfaces need tooltips that can display formatted content, multiple lines, icons, or even interactive elements. This wrapper component provides the infrastructure for such advanced tooltips, supporting different trigger types (hover, click, focus), optional interaction with the tooltip content itself, and smooth positioning behavior. It coordinates with child components to create sophisticated tooltip experiences while maintaining the ease of use and accessibility standards users expect.

# Props
- `placement::Union{Symbol,String}`: Tooltip placement (default: `:top`)
- `delay::Int`: Show delay in milliseconds (default: `500`)
- `hide_delay::Int`: Hide delay in milliseconds (default: `0`)
- `offset::Int`: Distance from trigger in pixels (default: `8`)
- `trigger::Union{Symbol,String}`: Trigger type (`:hover`, `:click`, `:focus`) (default: `:hover`)
- `interactive::Bool`: Keep open when hovering tooltip content (default: `false`)

# Slots
- Should contain exactly one @TooltipTrigger and one @TooltipContent component

# Example
```julia
# Interactive tooltip with rich content
@TooltipWrapper {interactive = true} begin
    @TooltipTrigger begin
        @Badge "PRO"
    end
    @TooltipContent {variant = :light} begin
        @Heading {level = 4, size = :sm} "Pro Feature"
        @Text {size = :sm} "Upgrade to access advanced features"
        @Button {size = :sm, variant = :primary} "Upgrade Now"
    end
end

# Click-triggered tooltip
@TooltipWrapper {trigger = :click} begin
    @TooltipTrigger begin
        @Icon {name = "info-circle"}
    end
    @TooltipContent begin
        @Text "Click anywhere to close"
    end
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
This component enables rich, accessible tooltip experiences:

**ARIA Patterns:**
- Maintains proper tooltip role and ARIA relationships
- Supports interactive tooltip content when configured appropriately
- Manages focus and tooltip visibility states correctly

**Keyboard Navigation:**
- **Escape**: Dismisses tooltip and returns focus to trigger
- **Tab**: Navigates through tooltip content when interactive
- **Enter/Space**: Activates trigger to show/hide tooltip
- Supports both hover and focus-based tooltip display

**Screen Reader Support:**
- Rich tooltip content is properly announced
- Interactive elements within tooltips are keyboard accessible
- Tooltip dismissal is communicated to assistive technology
- Content structure (headings, lists) is preserved for screen readers

**Focus Management:**
- Interactive tooltips can receive and maintain focus
- Focus returns to trigger when tooltip is dismissed
- Keyboard navigation works within complex tooltip content
- Non-interactive tooltips don't interfere with tab order

**Usage Guidelines:**
- Use interactive tooltips sparingly for essential actions only
- Ensure tooltip content is also available via other means
- Consider mobile users who may not have hover capabilities

# See also
- [`Tooltip`](@ref) - Simple text tooltips
- [`TooltipTrigger`](@ref) - Trigger component
- [`TooltipContent`](@ref) - Content component
- [`DropdownMenu`](@ref) - Alternative for complex interactions
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

The trigger element within TooltipWrapper that designates which element should activate the tooltip display. This component acts as a transparent wrapper that can encompass any element—from simple text to complex components—transforming it into an interactive trigger. It handles all the necessary event bindings and ARIA attributes automatically, ensuring that the wrapped element maintains its original functionality while gaining tooltip capabilities. The trigger component coordinates with its parent wrapper to manage tooltip visibility and positioning without interfering with the wrapped element's behavior.

# Props
- `class::String`: Additional CSS classes (optional)
- `attrs...`: Additional attributes

# Slots
- Trigger element - any element that should show the tooltip when interacted with

# Example
```julia
@TooltipTrigger begin
    @Button {variant = :ghost} "Hover me"
end
```

# Accessibility
**ARIA Patterns:**
- Maintains semantic relationship with tooltip content
- Preserves trigger element's original accessibility properties
- Adds tooltip-specific ARIA attributes without overriding existing ones

**Keyboard Navigation:**
- **Enter/Space**: Shows tooltip when trigger is button-like
- **Escape**: Dismisses tooltip (handled by parent wrapper)
- **Tab**: Normal tab behavior; tooltip shows/hides based on focus

**Screen Reader Support:**
- Trigger element's role and label are preserved
- Tooltip relationship is announced to screen readers
- Original element functionality remains intact
- Works with any trigger element type (button, link, span, etc.)

**Integration Guidelines:**
- Wrap any element that should trigger tooltips
- Maintain original element's accessibility properties
- Ensure trigger has sufficient color contrast and focus indicators

# See also
- [`TooltipWrapper`](@ref) - Parent wrapper component
- [`TooltipContent`](@ref) - Tooltip content component
"""
@component function TooltipTrigger(; class::String = "", attrs...)
    @div {var"x-ref" = "trigger", class = "inline-block $class", attrs...} begin
        @__slot__()
    end
end

@deftag macro TooltipTrigger end

"""
    @TooltipContent

The content component within TooltipWrapper that defines what appears in the tooltip popup, supporting rich formatting and complex layouts. Unlike simple text tooltips, this component can contain any valid HTML content including headings, paragraphs, lists, images, or even interactive elements when used with appropriate trigger settings. It provides consistent styling with customizable variants (dark or light), manages its appearance with smooth transitions, and positions itself intelligently relative to the trigger. The content component ensures that rich tooltips maintain visual coherence with the rest of the interface while providing the flexibility needed for advanced use cases.

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
**ARIA Patterns:**
- Uses `role="tooltip"` for proper identification
- Supports rich content while maintaining tooltip semantics
- Preserves content structure for assistive technology

**Keyboard Navigation:**
- Content is keyboard accessible when tooltip is interactive
- **Escape**: Dismisses tooltip and returns focus to trigger
- **Tab**: Navigates through interactive elements within tooltip

**Screen Reader Support:**
- Rich content (headings, links, buttons) is properly announced
- Content structure is preserved and navigable
- Interactive elements within tooltip are accessible
- Tooltip content is associated with trigger element

**Content Guidelines:**
- Use headings to structure complex tooltip content
- Ensure interactive elements have proper labels
- Maintain sufficient color contrast for all content
- Consider content length and readability

**Visual Design:**
- Light and dark variants ensure proper contrast
- Content is clearly separated from page background
- Focus indicators work within tooltip content
- Responsive design adapts to different screen sizes

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
