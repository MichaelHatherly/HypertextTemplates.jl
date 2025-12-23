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
    icon_bg::Union{AbstractString,Nothing} = nothing,
    connector::Bool = true,
    last::Bool = false,
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    container_class = theme.timeline_item.container
    connector_line_class = theme.timeline_item.connector_line
    content_wrapper_class = theme.timeline_item.content_wrapper
    icon_wrapper_class = theme.timeline_item.icon_wrapper
    default_icon_bg = theme.timeline_item.default_icon_bg
    empty_icon_class = theme.timeline_item.empty_icon
    content_container_class = theme.timeline_item.content_container

    # Use provided icon_bg or fallback to theme default
    final_icon_bg = something(icon_bg, default_icon_bg)

    show_connector = connector && !last

    @li {class = container_class, attrs...} begin
        # Vertical connector line
        if show_connector
            @div {class = connector_line_class}
        end

        @div {class = content_wrapper_class} begin
            # Timeline marker/icon
            @div {class = "$icon_wrapper_class $final_icon_bg"} begin
                if !isnothing(icon)
                    @text icon
                else
                    @div {class = empty_icon_class}
                end
            end

            # Content
            @div {class = content_container_class} begin
                @__slot__()
            end
        end
    end
end

@deftag macro TimelineItem end
