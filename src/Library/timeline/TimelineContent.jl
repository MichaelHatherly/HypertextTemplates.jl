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
        "bg-white dark:bg-slate-800 rounded-lg p-4 shadow-[0_1px_3px_rgba(0,0,0,0.06)] ring-1 ring-slate-200 dark:ring-slate-700" :
        ""

    @div {class = wrapper_class, attrs...} begin
        @div {class = "space-y-1"} begin
            if !isnothing(title)
                @h3 {class = "font-semibold text-slate-900 dark:text-slate-100"} title
            end

            @__slot__()

            if !isnothing(subtitle)
                @p {class = "text-sm text-slate-500 dark:text-slate-400 mt-1"} subtitle
            end
        end
    end
end

@deftag macro TimelineContent end
