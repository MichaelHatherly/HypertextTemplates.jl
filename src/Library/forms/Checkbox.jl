"""
    @Checkbox

A styled checkbox input that allows users to toggle between checked and unchecked states. Checkboxes are fundamental form controls for binary choices, terms acceptance, or selecting multiple options from a list. This component enhances the native checkbox with custom styling that matches your design system while preserving full keyboard accessibility and screen reader support. It can be used standalone or with an integrated label, and supports different color schemes and sizes to fit various UI contexts.

# Props
- `size::Union{Symbol,String}`: Checkbox size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Checkbox color (`:slate`, `:primary`, `:success`) (default: `:primary`)
- `label::Union{String,Nothing}`: Label text (optional)
- `name::Union{String,Nothing}`: Checkbox name attribute (optional)
- `value::Union{String,Nothing}`: Checkbox value (optional)
- `checked::Bool`: Whether checkbox is checked (default: `false`)
- `required::Bool`: Whether checkbox is required (default: `false`)
- `disabled::Bool`: Whether checkbox is disabled (default: `false`)
"""
@component function Checkbox(;
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    label::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    checked::Bool = false,
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

    if !isnothing(label)
        Elements.@label {class = "inline-flex items-center gap-2 $disabled_class"} begin
            @input {
                type = "checkbox",
                class = "rounded-md border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-600 $size_class $color_class",
                name = name,
                value = value,
                checked = checked,
                required = required,
                disabled = disabled,
                attrs...,
            }
            @span {class = "text-sm text-gray-700 dark:text-gray-300 select-none"} $label
        end
    else
        @input {
            type = "checkbox",
            class = "rounded-md border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-600 $size_class $color_class $disabled_class",
            name = name,
            value = value,
            checked = checked,
            required = required,
            disabled = disabled,
            attrs...,
        }
    end
end

@deftag macro Checkbox end
