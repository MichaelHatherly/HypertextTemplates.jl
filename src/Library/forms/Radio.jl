"""
    @Radio

A radio button component that enables users to select a single option from a group of mutually exclusive choices. Radio buttons are ideal when you want to present all available options upfront and ensure users can only select one. This component renders a complete radio group with proper ARIA attributes and keyboard navigation support. Each option can include a label, and the entire group maintains visual consistency with other form elements while providing clear feedback about the selected state.

# Props
- `size::Union{Symbol,String}`: Radio size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Radio color (`:slate`, `:primary`, `:success`) (default: `:primary`)
- `options::Vector{Tuple{String,String}}`: Options as (value, label) tuples
- `name::String`: Radio group name (required)
- `value::Union{String,Nothing}`: Selected value (optional)
- `required::Bool`: Whether radio group is required (default: `false`)
- `disabled::Bool`: Whether radio group is disabled (default: `false`)
"""
@component function Radio(;
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    options::Vector{Tuple{String,String}} = Tuple{String,String}[],
    name::String,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    size_classes = (sm = "h-3.5 w-3.5", md = "h-4 w-4", lg = "h-5 w-5")

    color_classes = (
        slate = "text-gray-600 focus:ring-gray-500",
        primary = "text-blue-600 focus:ring-blue-500 dark:text-blue-500 dark:focus:ring-blue-400",
        success = "text-emerald-600 focus:ring-emerald-500 dark:text-emerald-500 dark:focus:ring-emerald-400",
    )

    size_class = get(size_classes, size_sym, size_classes.md)
    color_class = get(color_classes, color_sym, color_classes.primary)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""

    # Note: WebKit/Safari may clip the right edge of radio buttons in some cases.
    # This is a known rendering issue with Safari's implementation of form controls.
    @div {class = "space-y-2", role = "radiogroup", attrs...} begin
        for (opt_value, opt_label) in options
            Elements.@label {
                class = "flex items-center gap-2 cursor-pointer $disabled_class",
            } begin
                @input {
                    type = "radio",
                    class = "shrink-0 border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-colors hover:border-gray-400 dark:hover:border-gray-600 $size_class $color_class",
                    name = name,
                    value = opt_value,
                    checked = (!isnothing(value) && value == opt_value),
                    required = required,
                    disabled = disabled,
                }
                @span {class = "text-sm text-gray-700 dark:text-gray-300 select-none"} $opt_label
            end
        end
    end
end

@deftag macro Radio end
