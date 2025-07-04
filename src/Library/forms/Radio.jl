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

    # Extract radio theme safely
    radio_theme = if isa(theme, NamedTuple) && haskey(theme, :radio)
        theme.radio
    else
        HypertextTemplates.Library.default_theme().radio
    end

    # Get classes
    wrapper_class =
        get(radio_theme, :wrapper, HypertextTemplates.Library.default_theme().radio.wrapper)
    base_classes =
        get(radio_theme, :base, HypertextTemplates.Library.default_theme().radio.base)

    # Get size class with fallback
    size_class = if haskey(radio_theme, :sizes) && haskey(radio_theme.sizes, size_sym)
        radio_theme.sizes[size_sym]
    else
        HypertextTemplates.Library.default_theme().radio.sizes[size_sym]
    end

    # Get color class with fallback
    color_class = if haskey(radio_theme, :colors) && haskey(radio_theme.colors, color_sym)
        radio_theme.colors[color_sym]
    else
        HypertextTemplates.Library.default_theme().radio.colors[color_sym]
    end

    # Get disabled class
    disabled_class =
        disabled ?
        get(
            radio_theme,
            :disabled,
            HypertextTemplates.Library.default_theme().radio.disabled,
        ) : ""

    # Get label classes
    label_wrapper = get(
        radio_theme,
        :label_wrapper,
        HypertextTemplates.Library.default_theme().radio.label_wrapper,
    )
    label_class =
        get(radio_theme, :label, HypertextTemplates.Library.default_theme().radio.label)

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
