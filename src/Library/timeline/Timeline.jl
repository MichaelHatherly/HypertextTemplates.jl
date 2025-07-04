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
