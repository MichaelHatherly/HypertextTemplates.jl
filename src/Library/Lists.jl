"""
    @Timeline

A timeline component for displaying chronological events with connecting lines.

# Props
- `variant::Union{Symbol,String}`: Timeline variant (`:vertical`, `:horizontal`) (default: `:vertical`)
- `connector::Bool`: Whether to show connecting lines between items (default: `true`)
- `alternate::Bool`: Whether to alternate items on left/right sides (horizontal only) (default: `false`)
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

An individual item in a timeline.

# Props
- `icon::Union{String,Nothing}`: Content for the timeline marker (optional)
- `icon_bg::Union{String,Nothing}`: Background color class for the icon (default: `"bg-blue-500"`)
- `connector::Bool`: Whether to show connector line to next item (default: `true`)
- `last::Bool`: Whether this is the last item (disables connector) (default: `false`)
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

Content wrapper for timeline items with consistent styling.

# Props
- `title::Union{String,Nothing}`: Title text (optional)
- `subtitle::Union{String,Nothing}`: Subtitle or timestamp (optional)
- `card::Bool`: Whether to wrap content in a card (default: `true`)
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
