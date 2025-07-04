"""
    @Select

A dropdown select element that allows users to choose from a predefined list of options. Select components are essential for forms where users need to pick from a constrained set of choices, providing a cleaner interface than radio buttons when dealing with many options. This implementation features a custom-styled dropdown arrow for consistency across browsers, support for placeholder text, and full integration with form validation states. The component maintains accessibility standards while offering a modern appearance.

# Props
- `size::Union{Symbol,String}`: Select size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `state::Union{Symbol,String}`: Select state (`:default`, `:error`, `:success`) (default: `:default`)
- `options::Vector{Tuple{String,String}}`: Options as (value, label) tuples
- `placeholder::Union{String,Nothing}`: Placeholder option text (optional)
- `name::Union{String,Nothing}`: Select name attribute (optional)
- `value::Union{String,Nothing}`: Selected value (optional)
- `required::Bool`: Whether select is required (default: `false`)
- `disabled::Bool`: Whether select is disabled (default: `false`)
- `id::Union{String,Nothing}`: Select ID for label association (optional)
- `aria_describedby::Union{String,Nothing}`: ID of element describing the select (optional)
"""
@component function Select(;
    size::Union{Symbol,String} = :base,
    state::Union{Symbol,String} = :default,
    options::Vector{Tuple{String,String}} = Tuple{String,String}[],
    placeholder::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    id::Union{String,Nothing} = nothing,
    aria_describedby::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    state_sym = Symbol(state)

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    base_classes = theme.select.base
    size_class = theme.select.sizes[size_sym]
    state_class = theme.select.states[state_sym]
    disabled_class = disabled ? theme.select.disabled : ""

    aria_invalid = state_sym === :error ? "true" : nothing

    @select {
        class = "$base_classes $size_class $state_class $disabled_class",
        name = name,
        required = required,
        disabled = disabled,
        id = id,
        "aria-invalid" := aria_invalid,
        "aria-describedby" := aria_describedby,
        attrs...,
    } begin
        if !isnothing(placeholder)
            @option {value = "", selected = isnothing(value)} $placeholder
        end
        for (opt_value, opt_label) in options
            @option {
                value = opt_value,
                selected = (!isnothing(value) && value == opt_value),
            } $opt_label
        end
    end
end

@deftag macro Select end
