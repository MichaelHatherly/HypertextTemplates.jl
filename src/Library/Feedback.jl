"""
    @Alert

Notification message component.

# Props
- `variant::Union{Symbol,String}`: Alert variant (`:info`, `:success`, `:warning`, `:error`) (default: `:info`)
- `dismissible::Bool`: Whether alert can be dismissed (shows close button) (default: `false`)
"""
@component function Alert(;
    variant::Union{Symbol,String} = :info,
    dismissible::Bool = false,
    attrs...,
)
    # Convert to symbol
    variant_sym = Symbol(variant)

    variant_classes = Dict(
        :info => "bg-blue-50 border-blue-200 text-blue-800 dark:bg-blue-950 dark:border-blue-800 dark:text-blue-200",
        :success => "bg-green-50 border-green-200 text-green-800 dark:bg-green-950 dark:border-green-800 dark:text-green-200",
        :warning => "bg-amber-50 border-amber-200 text-amber-800 dark:bg-amber-950 dark:border-amber-800 dark:text-amber-200",
        :error => "bg-red-50 border-red-200 text-red-800 dark:bg-red-950 dark:border-red-800 dark:text-red-200",
    )

    icon_svgs = Dict(
        :info => """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" /></svg>""",
        :success => """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" /></svg>""",
        :warning => """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" /></svg>""",
        :error => """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" /></svg>""",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes[:info])
    icon_svg = get(icon_svgs, variant_sym, icon_svgs[:info])

    @div {class = "rounded-lg border p-4 $variant_class", role = "alert", attrs...} begin
        @div {class = "flex"} begin
            @div {class = "flex-shrink-0"} begin
                HypertextTemplates.SafeString(icon_svg)
            end
            @div {class = "ml-3 flex-1"} begin
                @__slot__()
            end
            if dismissible
                @button {
                    type = "button",
                    class = "ml-3 inline-flex flex-shrink-0 rounded-md p-1.5 hover:bg-black/10 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-transparent focus:ring-current",
                    "aria-label" = "Dismiss",
                } begin
                    HypertextTemplates.SafeString(
                        """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" /></svg>""",
                    )
                end
            end
        end
    end
end

@deftag macro Alert end

"""
    @Progress

Progress bar component.

# Props
- `value::Int`: Current progress value (default: `0`)
- `max::Int`: Maximum progress value (default: `100`)
- `size::Union{Symbol,String}`: Progress bar size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Progress bar color (`:slate`, `:primary`, `:success`) (default: `:primary`)
- `striped::Bool`: Whether to show striped pattern (default: `false`)
- `label::Union{String,Nothing}`: Label to display (optional)
- `aria_label::Union{String,Nothing}`: ARIA label for screen readers (optional)
"""
@component function Progress(;
    value::Int = 0,
    max::Int = 100,
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    striped::Bool = false,
    label::Union{String,Nothing} = nothing,
    aria_label::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    size_classes = Dict(:sm => "h-2", :md => "h-3", :lg => "h-4")

    color_classes = Dict(
        :slate => "bg-slate-600 dark:bg-slate-400",
        :primary => "bg-slate-900 dark:bg-slate-100",
        :success => "bg-green-600 dark:bg-green-400",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    color_class = get(color_classes, color_sym, color_classes[:primary])
    percentage = Base.min(100, Base.max(0, round(Int, (value / max) * 100)))

    striped_class =
        striped ?
        "bg-[length:1rem_1rem] bg-gradient-to-r from-transparent via-white/20 to-transparent animate-[progress-stripes_1s_linear_infinite]" :
        ""

    @div {attrs...} begin
        if !isnothing(label)
            @div {
                class = "mb-1 flex justify-between text-sm text-slate-600 dark:text-slate-400",
            } begin
                @span label
                @span "$percentage%"
            end
        end
        @div {
            class = "w-full bg-slate-200 dark:bg-slate-800 rounded-full overflow-hidden $size_class",
            role = "progressbar",
            "aria-valuenow" = value,
            "aria-valuemin" = "0",
            "aria-valuemax" = max,
            "aria-label" =
                isnothing(aria_label) && isnothing(label) ? "Progress: $percentage%" :
                aria_label,
        } begin
            @div {
                class = "transition-all duration-300 ease-out rounded-full $color_class $striped_class $size_class",
                style = "width: $percentage%",
            }
        end
    end
end

@deftag macro Progress end

"""
    @Spinner

Loading spinner component.

# Props
- `size::Union{Symbol,String}`: Spinner size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Spinner color (`:slate`, `:primary`, `:white`) (default: `:primary`)
"""
@component function Spinner(;
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    size_classes = Dict(:sm => "h-4 w-4", :md => "h-6 w-6", :lg => "h-8 w-8")

    color_classes = Dict(
        :slate => "text-slate-600 dark:text-slate-400",
        :primary => "text-slate-900 dark:text-slate-100",
        :white => "text-white",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    color_class = get(color_classes, color_sym, color_classes[:primary])

    @div {
        class = "inline-flex items-center",
        role = "status",
        "aria-label" = "Loading",
        attrs...,
    } begin
        HypertextTemplates.SafeString(
            """<svg class="animate-spin $size_class $color_class" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" aria-hidden="true">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
</svg>""",
        )
    end
end

@deftag macro Spinner end
