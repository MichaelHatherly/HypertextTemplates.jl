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

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    wrapper_class = theme.radio.wrapper
    base_classes = theme.radio.base
    size_class = theme.radio.sizes[size_sym]
    color_class = theme.radio.colors[color_sym]
    disabled_class = disabled ? theme.radio.disabled : ""
    label_wrapper = theme.radio.label_wrapper
    label_class = theme.radio.label

    # Note: WebKit/Safari may clip the right edge of radio buttons in some cases.
    # This is a known rendering issue with Safari's implementation of form controls.
    @div {class = wrapper_class, role = "radiogroup", attrs...} begin
        for (opt_value, opt_label) in options
            Elements.@label {class = "$label_wrapper $disabled_class"} begin
                @input {
                    type = "radio",
                    class = "$base_classes $size_class $color_class",
                    name = name,
                    value = opt_value,
                    checked = (!isnothing(value) && value == opt_value),
                    required = required,
                    disabled = disabled,
                }
                @span {class = label_class} $opt_label
            end
        end
    end
end

@deftag macro Radio end
