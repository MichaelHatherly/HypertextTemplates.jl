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

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract checkbox theme safely
    checkbox_theme = if isa(theme, NamedTuple) && haskey(theme, :checkbox)
        theme.checkbox
    else
        HypertextTemplates.Library.default_theme().checkbox
    end

    # Get base classes
    base_classes =
        get(checkbox_theme, :base, HypertextTemplates.Library.default_theme().checkbox.base)

    # Get size class with fallback
    size_class = if haskey(checkbox_theme, :sizes) && haskey(checkbox_theme.sizes, size_sym)
        checkbox_theme.sizes[size_sym]
    else
        HypertextTemplates.Library.default_theme().checkbox.sizes[size_sym]
    end

    # Get color class with fallback
    color_class =
        if haskey(checkbox_theme, :colors) && haskey(checkbox_theme.colors, color_sym)
            checkbox_theme.colors[color_sym]
        else
            HypertextTemplates.Library.default_theme().checkbox.colors[color_sym]
        end

    # Get disabled class
    disabled_class =
        disabled ?
        get(
            checkbox_theme,
            :disabled,
            HypertextTemplates.Library.default_theme().checkbox.disabled,
        ) : ""

    # Get label classes
    label_wrapper = get(
        checkbox_theme,
        :label_wrapper,
        HypertextTemplates.Library.default_theme().checkbox.label_wrapper,
    )
    label_class = get(
        checkbox_theme,
        :label,
        HypertextTemplates.Library.default_theme().checkbox.label,
    )

    if !isnothing(label)
        Elements.@label {class = "$label_wrapper $disabled_class"} begin
            @input {
                type = "checkbox",
                class = "$base_classes $size_class $color_class",
                name = name,
                value = value,
                checked = checked,
                required = required,
                disabled = disabled,
                attrs...,
            }
            @span {class = label_class} $label
        end
    else
        @input {
            type = "checkbox",
            class = "$base_classes $size_class $color_class $disabled_class",
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
