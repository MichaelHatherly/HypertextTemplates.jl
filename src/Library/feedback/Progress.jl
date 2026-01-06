"""
    @Progress

A modern progress bar component that visually represents the completion status of a task or process. Progress bars provide essential feedback during operations like file uploads, form submissions, or multi-step workflows, helping users understand how much has been completed and how much remains. This component supports various visual styles including solid colors and gradients, optional striped patterns for visual interest, and smooth animations that bring the interface to life. Labels can be added to show exact percentages or descriptive text.

# Props
- `value::Int`: Current progress value (default: `0`)
- `max::Int`: Maximum progress value (default: `100`)
- `size::Union{Symbol,String}`: Progress bar size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Progress bar color (`:primary`, `:success`, `:warning`, `:danger`) (default: `:primary`)
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
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    size_classes = (sm = "h-2", md = "h-3", lg = "h-5")

    color_classes = (
        primary = "bg-indigo-500 dark:bg-indigo-400",
        success = "bg-emerald-500 dark:bg-emerald-400",
        warning = "bg-amber-500 dark:bg-amber-400",
        danger = "bg-rose-500 dark:bg-rose-400",
    )

    size_class = get(size_classes, size_sym, size_classes.md)
    color_class = get(color_classes, color_sym, color_classes.primary)
    percentage = Base.min(100, Base.max(0, round(Int, (value / max) * 100)))

    striped_class = if striped
        base_stripe = "bg-[length:0.75rem_0.75rem] bg-gradient-to-r from-transparent via-white/15 to-transparent"
        animated ? "$base_stripe animate-[stripes_1s_linear_infinite]" : base_stripe
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
            @div {
                class = "mb-1.5 flex justify-between text-sm font-medium text-slate-700 dark:text-slate-300",
            } begin
                @span $label
                if animated_fill
                    @span {
                        class = "text-slate-500 dark:text-slate-400",
                        "x-text" = SafeString("progress + '%'"),
                    }
                else
                    @span {class = "text-slate-500 dark:text-slate-400"} @text "$percentage%"
                end
            end
        end
        @div {
            class = "w-full bg-slate-200 dark:bg-slate-700 rounded-full overflow-hidden $size_class",
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
                class = "transition-all duration-500 ease-out rounded-full shadow-sm $color_class $striped_class $size_class",
                style = animated_fill ? nothing : "width: $percentage%",
                ":style" =
                    animated_fill ? SafeString("'width: ' + progress + '%'") : nothing,
            }
        end
    end
end

@deftag macro Progress end
