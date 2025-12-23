"""
    @Progress

A modern progress bar component that visually represents the completion status of a task or process. Progress bars provide essential feedback during operations like file uploads, form submissions, or multi-step workflows, helping users understand how much has been completed and how much remains. This component supports various visual styles including solid colors and gradients, optional striped patterns for visual interest, and smooth animations that bring the interface to life. Labels can be added to show exact percentages or descriptive text.

# Props
- `value::Int`: Current progress value (default: `0`)
- `max::Int`: Maximum progress value (default: `100`)
- `size::Union{Symbol,String}`: Progress bar size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Progress bar color (`:primary`, `:success`, `:warning`, `:danger`, `:gradient`) (default: `:primary`)
- `striped::Bool`: Whether to show striped pattern (default: `false`)
- `animated::Bool`: Whether to animate the stripes (default: `false`)
- `animated_fill::Bool`: Whether to animate the progress fill on load (default: `false`)
- `label::Union{String,Nothing}`: Label to display (optional)
- `aria_label::Union{String,Nothing}`: ARIA label for screen readers (optional)

# Interactive Features
When `animated_fill=true`, this component uses Alpine.js for smooth fill animation on load.
To enable interactivity, include Alpine.js in your page:

```julia
@script {defer=true, src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"}
```

Without Alpine.js, the progress bar will display at its final value without animation.
"""
@component function Progress(;
    value::Int = 0,
    max::Int = 100,
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    striped::Bool = false,
    animated::Bool = false,
    animated_fill::Bool = false,
    label::Union{String,Nothing} = nothing,
    aria_label::Union{String,Nothing} = nothing,
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    # Direct theme access
    container_class = theme.progress.container
    bar_class = theme.progress.bar
    size_class = theme.progress.sizes[size_sym]
    color_class = theme.progress.colors[color_sym]
    striped_base = theme.progress.striped
    animated_stripe = theme.progress.animated_stripe
    label_class = theme.progress.label
    label_value_class = theme.progress.label_value

    percentage = Base.min(100, Base.max(0, round(Int, (value / max) * 100)))

    striped_class = if striped
        animated ? "$striped_base $animated_stripe" : striped_base
    else
        ""
    end

    # Build component attributes
    component_attrs = if animated_fill
        (
            var"x-data" = SafeString("{ progress: 0 }"),
            var"x-init" = SafeString("\$nextTick(() => { progress = $percentage })"),
        )
    else
        NamedTuple()
    end

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        if !isnothing(label)
            @div {class = label_class} begin
                @span $label
                if animated_fill
                    @span {
                        class = label_value_class,
                        "x-text" = SafeString("progress + '%'"),
                    }
                else
                    @span {class = label_value_class} @text "$percentage%"
                end
            end
        end
        @div {
            class = "$container_class $size_class",
            role = "progressbar",
            "aria-valuenow" = animated_fill ? nothing : value,
            ":aria-valuenow" =
                animated_fill ? SafeString("Math.round(progress * $max / 100)") : nothing,
            "aria-valuemin" = "0",
            "aria-valuemax" = max,
            "aria-label" =
                isnothing(aria_label) && isnothing(label) ?
                (animated_fill ? nothing : "Progress: $percentage%") : aria_label,
            ":aria-label" =
                animated_fill && isnothing(aria_label) && isnothing(label) ?
                SafeString("'Progress: ' + progress + '%'") : nothing,
        } begin
            @div {
                class = "$bar_class $color_class $striped_class $size_class",
                style = animated_fill ? nothing : "width: $percentage%",
                ":style" =
                    animated_fill ? SafeString("'width: ' + progress + '%'") : nothing,
            }
        end
    end
end

@deftag macro Progress end
