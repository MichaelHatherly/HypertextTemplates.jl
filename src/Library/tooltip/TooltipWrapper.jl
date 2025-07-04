"""
    @TooltipWrapper

A wrapper component for rich, interactive tooltips with custom content. Supports different trigger types (hover, click, focus) and interactive tooltip content with proper positioning and accessibility.

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
**ARIA & Focus:** Proper tooltip roles and ARIA relationships. Interactive tooltips support keyboard navigation with Escape to dismiss.

**Content:** Rich content (headings, links, buttons) is announced and navigable by screen readers.

**Guidelines:** Use interactive tooltips sparingly; ensure content is available via other means for mobile users.

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
        @script @text SafeString(read(joinpath(@__DIR__, "../assets/tooltip.js"), String))
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
