"""
    @Alert

Modern notification message component with animations.

# Props
- `variant::Union{Symbol,String}`: Alert variant (`:info`, `:success`, `:warning`, `:error`) (default: `:info`)
- `dismissible::Bool`: Whether alert can be dismissed (shows close button) (default: `false`)
- `icon::Bool`: Whether to show icon (default: `true`)
- `animated::Bool`: Whether to show fade-in animation (default: `true`)
"""
@component function Alert(;
    variant::Union{Symbol,String} = :info,
    dismissible::Bool = false,
    icon::Bool = true,
    animated::Bool = true,
    attrs...,
)
    # Convert to symbol
    variant_sym = Symbol(variant)

    variant_classes = Dict(
        :info => "bg-blue-50 border-blue-300 text-blue-800 dark:bg-blue-950/30 dark:border-blue-700 dark:text-blue-300",
        :success => "bg-emerald-50 border-emerald-300 text-emerald-800 dark:bg-emerald-950/30 dark:border-emerald-700 dark:text-emerald-300",
        :warning => "bg-amber-50 border-amber-300 text-amber-800 dark:bg-amber-950/30 dark:border-amber-700 dark:text-amber-300",
        :error => "bg-rose-50 border-rose-300 text-rose-800 dark:bg-rose-950/30 dark:border-rose-700 dark:text-rose-300",
    )

    icon_svgs = Dict(
        :info => """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" /></svg>""",
        :success => """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" /></svg>""",
        :warning => """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" /></svg>""",
        :error => """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" /></svg>""",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes[:info])
    icon_svg = get(icon_svgs, variant_sym, icon_svgs[:info])
    animation_class = animated ? "animate-[fadeIn_0.3s_ease-in-out]" : ""

    @div {
        class = "rounded-xl border-l-4 border-t border-r border-b p-4 shadow-sm $variant_class $animation_class transition-all duration-300",
        role = "alert",
        attrs...,
    } begin
        @div {class = "flex"} begin
            if icon
                @div {class = "flex-shrink-0"} begin
                    @text HypertextTemplates.SafeString(icon_svg)
                end
            end
            @div {class = icon ? "ml-3 flex-1" : "flex-1"} begin
                @__slot__()
            end
            if dismissible
                @button {
                    type = "button",
                    class = "ml-3 inline-flex flex-shrink-0 rounded-lg p-1.5 hover:bg-black/10 dark:hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-transparent focus:ring-current transition-all duration-200",
                    "aria-label" = "Dismiss",
                } begin
                    @text HypertextTemplates.SafeString(
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

Modern progress bar component with animations.

# Props
- `value::Int`: Current progress value (default: `0`)
- `max::Int`: Maximum progress value (default: `100`)
- `size::Union{Symbol,String}`: Progress bar size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Progress bar color (`:primary`, `:success`, `:warning`, `:danger`, `:gradient`) (default: `:primary`)
- `striped::Bool`: Whether to show striped pattern (default: `false`)
- `animated::Bool`: Whether to animate the stripes (default: `false`)
- `label::Union{String,Nothing}`: Label to display (optional)
- `aria_label::Union{String,Nothing}`: ARIA label for screen readers (optional)
"""
@component function Progress(;
    value::Int = 0,
    max::Int = 100,
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    striped::Bool = false,
    animated::Bool = false,
    label::Union{String,Nothing} = nothing,
    aria_label::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    size_classes = Dict(:sm => "h-2", :md => "h-3", :lg => "h-5")

    color_classes = Dict(
        :primary => "bg-blue-500 dark:bg-blue-400",
        :success => "bg-emerald-500 dark:bg-emerald-400",
        :warning => "bg-amber-500 dark:bg-amber-400",
        :danger => "bg-rose-500 dark:bg-rose-400",
        :gradient => "bg-gradient-to-r from-blue-500 to-purple-600",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    color_class = get(color_classes, color_sym, color_classes[:primary])
    percentage = Base.min(100, Base.max(0, round(Int, (value / max) * 100)))

    striped_class = if striped
        base_stripe = "bg-[length:1rem_1rem] bg-gradient-to-r from-transparent via-white/20 to-transparent"
        animated ? "$base_stripe animate-[stripes_1s_linear_infinite]" : base_stripe
    else
        ""
    end

    @div {attrs...} begin
        if !isnothing(label)
            @div {
                class = "mb-2 flex justify-between text-sm font-medium text-gray-700 dark:text-gray-300",
            } begin
                @span $label
                @span {class = "font-semibold"} @text "$percentage%"
            end
        end
        @div {
            class = "w-full bg-gray-200 dark:bg-gray-800 rounded-full overflow-hidden shadow-inner $size_class",
            role = "progressbar",
            "aria-valuenow" = value,
            "aria-valuemin" = "0",
            "aria-valuemax" = max,
            "aria-label" =
                isnothing(aria_label) && isnothing(label) ? "Progress: $percentage%" :
                aria_label,
        } begin
            @div {
                class = "transition-all duration-500 ease-out rounded-full shadow-sm $color_class $striped_class $size_class",
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
        @text HypertextTemplates.SafeString(
            """<svg class="animate-spin $size_class $color_class" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" aria-hidden="true">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
</svg>""",
        )
    end
end

@deftag macro Spinner end
