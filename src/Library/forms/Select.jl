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

    size_classes = (
        xs = "px-2.5 py-1.5 pr-8 text-xs",
        sm = "px-3 py-2 pr-9 text-sm",
        base = "px-4 py-2.5 pr-10 text-base",
        md = "px-4 py-2.5 pr-10 text-base",  # For backward compatibility
        lg = "px-5 py-3 pr-11 text-lg",
        xl = "px-6 py-3.5 pr-12 text-xl",
    )

    state_classes = (
        default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
        error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
        success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
    )

    size_class = get(size_classes, size_sym, size_classes.base)
    state_class = get(state_classes, state_sym, state_classes.default)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""
    aria_invalid = state_sym === :error ? "true" : nothing

    @select {
        class = "w-full appearance-none rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600 bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"%3e%3cpolyline points=\"6 9 12 15 18 9\"%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:1.5em_1.5em] bg-[right_0.5rem_center] bg-no-repeat $size_class $state_class $disabled_class",
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
