"""
    @Timeline

A container component for displaying chronological events in an elegant timeline layout. Timelines are powerful visualization tools for presenting sequences of events, project milestones, or historical progressions in an intuitive, linear format. This component provides the structural foundation for timeline displays, supporting both vertical and horizontal orientations with optional connecting lines between events. It handles the complex positioning and alignment requirements while maintaining a clean, scannable interface that helps users understand temporal relationships and progress at a glance.

# Props
- `variant::Union{Symbol,String}`: Timeline variant (`:vertical`, `:horizontal`) (default: `:vertical`)
- `connector::Bool`: Whether to show connecting lines between items (default: `true`)
- `alternate::Bool`: Whether to alternate items on left/right sides (horizontal only) (default: `false`)

# Slots
- Timeline items - should contain @TimelineItem components

# Example
```julia
@Timeline begin
    @TimelineItem {icon = "1", icon_bg = "bg-blue-500"} begin
        @TimelineContent {title = "Project Started", subtitle = "January 2024"} begin
            @Text "Initial planning and setup phase."
        end
    end
    @TimelineItem {icon = "2", icon_bg = "bg-green-500"} begin
        @TimelineContent {title = "Development Phase", subtitle = "March 2024"} begin
            @Text "Core features implemented."
        end
    end
    @TimelineItem {icon = "✓", icon_bg = "bg-purple-500", last = true} begin
        @TimelineContent {title = "Launch", subtitle = "June 2024"} begin
            @Text "Product successfully launched!"
        end
    end
end
```

# See also
- [`TimelineItem`](@ref) - Individual timeline entries
- [`TimelineContent`](@ref) - Content wrapper for timeline items
"""
@component function Timeline(;
    variant::Union{Symbol,AbstractString} = :vertical,
    connector::Bool = true,
    alternate::Bool = false,
    attrs...,
)
    variant_sym = Symbol(variant)

    # Build component default attributes
    component_attrs = if variant_sym == :horizontal
        (class = "flex flex-row items-start gap-4 overflow-x-auto",)
    else
        (class = "relative list-none",)
    end

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @ul {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro Timeline end

"""
    @TimelineItem

An individual event or milestone in a timeline that represents a specific point in time or achievement. Timeline items are the building blocks of any timeline display, each marking a significant moment with optional visual indicators and connecting lines to adjacent events. This component provides flexible customization through icon markers with customizable backgrounds, automatic connector lines for visual continuity, and proper spacing to maintain timeline flow. Items can represent anything from project phases to historical events, with the visual design emphasizing both the discrete nature of each event and its relationship to the whole sequence.

# Props
- `icon::Union{String,Nothing}`: Content for the timeline marker (optional)
- `icon_bg::Union{String,Nothing}`: Background color class for the icon (default: `"bg-blue-500"`)
- `connector::Bool`: Whether to show connector line to next item (default: `true`)
- `last::Bool`: Whether this is the last item (disables connector) (default: `false`)

# Slots
- Timeline item content - typically contains @TimelineContent component

# Example
```julia
@TimelineItem {icon = "🚀"} begin
    @TimelineContent {title = "Launch Day"} begin
        @Text "We're going live!"
    end
end
```

# See also
- [`Timeline`](@ref) - Parent timeline container
- [`TimelineContent`](@ref) - Content wrapper component
"""
@component function TimelineItem(;
    icon::Union{AbstractString,Nothing} = nothing,
    icon_bg::Union{AbstractString,Nothing} = "bg-blue-500",
    connector::Bool = true,
    last::Bool = false,
    attrs...,
)
    show_connector = connector && !last

    @li {class = "relative list-none", attrs...} begin
        # Vertical connector line
        if show_connector
            @div {
                class = "absolute left-4 top-8 bottom-0 w-0.5 bg-gray-200 dark:bg-gray-700",
            }
        end

        @div {class = "flex items-start gap-3"} begin
            # Timeline marker/icon
            @div {
                class = "relative z-10 flex-shrink-0 w-8 h-8 rounded-full $icon_bg flex items-center justify-center text-white font-medium",
            } begin
                if !isnothing(icon)
                    @text icon
                else
                    @div {class = "w-2 h-2 bg-white rounded-full"}
                end
            end

            # Content
            @div {class = "flex-1 pb-8"} begin
                @__slot__()
            end
        end
    end
end

@deftag macro TimelineItem end

"""
    @TimelineContent

A content wrapper for timeline items that provides consistent styling and structure for the information associated with each timeline event. This component ensures that timeline content maintains visual coherence whether displaying simple text updates or rich media content. It offers optional card styling for enhanced visual separation, built-in support for titles and timestamps, and flexible content areas that can accommodate various types of information. The wrapper handles responsive behavior and maintains proper alignment with timeline markers, creating a polished presentation that guides users through chronological narratives.

# Props
- `title::Union{String,Nothing}`: Title text (optional)
- `subtitle::Union{String,Nothing}`: Subtitle or timestamp (optional)
- `card::Bool`: Whether to wrap content in a card (default: `true`)

# Slots
- Content body - the main content of the timeline entry

# Example
```julia
@TimelineContent {title = "Milestone Achieved", subtitle = "Q2 2024"} begin
    @Text "Successfully completed the first phase of the project."
    @Stack {direction = :horizontal, gap = :sm} begin
        @Badge {variant = :success} "On Time"
        @Badge {variant = :primary} "Under Budget"
    end
end

# Without card styling
@TimelineContent {card = false} begin
    @Text {variant = :small} "Quick update: Everything is on track."
end
```

# See also
- [`Timeline`](@ref) - Parent timeline container
- [`TimelineItem`](@ref) - Timeline entry wrapper
- [`Card`](@ref) - Related card styling
"""
@component function TimelineContent(;
    title::Union{AbstractString,Nothing} = nothing,
    subtitle::Union{AbstractString,Nothing} = nothing,
    card::Bool = true,
    attrs...,
)
    wrapper_class =
        card ?
        "bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm ring-1 ring-gray-200 dark:ring-gray-700" :
        ""

    @div {class = wrapper_class, attrs...} begin
        @div {class = "space-y-1"} begin
            if !isnothing(title)
                @h3 {class = "font-semibold text-gray-900 dark:text-gray-100"} title
            end

            @__slot__()

            if !isnothing(subtitle)
                @p {class = "text-sm text-gray-500 dark:text-gray-400 mt-1"} subtitle
            end
        end
    end
end

@deftag macro TimelineContent end
