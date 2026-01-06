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
    icon_bg::Union{AbstractString,Nothing} = "bg-indigo-500",
    connector::Bool = true,
    last::Bool = false,
    attrs...,
)
    show_connector = connector && !last

    @li {class = "relative list-none", attrs...} begin
        # Vertical connector line
        if show_connector
            @div {
                class = "absolute left-4 top-8 bottom-0 w-0.5 bg-slate-200 dark:bg-slate-700",
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
