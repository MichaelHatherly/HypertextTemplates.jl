"""
    @Input

A styled text input field.

# Props
- `type::String`: Input type (default: `"text"`)
- `size::Union{Symbol,String}`: Input size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `state::Union{Symbol,String}`: Input state (`:default`, `:error`, `:success`) (default: `:default`)
- `icon::Union{String,Nothing}`: Icon HTML to display (optional)
- `placeholder::Union{String,Nothing}`: Placeholder text (optional)
- `name::Union{String,Nothing}`: Input name attribute (optional)
- `value::Union{String,Nothing}`: Input value (optional)
- `required::Bool`: Whether input is required (default: `false`)
- `disabled::Bool`: Whether input is disabled (default: `false`)
"""
@component function Input(;
    type::String = "text",
    size::Union{Symbol,String} = :md,
    state::Union{Symbol,String} = :default,
    icon::Union{String,Nothing} = nothing,
    placeholder::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    state_sym = Symbol(state)

    size_classes = Dict(
        :sm => "px-3 py-1.5 text-sm",
        :md => "px-4 py-2 text-base",
        :lg => "px-4 py-3 text-lg",
    )

    state_classes = Dict(
        :default => "border-slate-300 focus:border-slate-900 focus:ring-slate-900/10",
        :error => "border-red-300 focus:border-red-500 focus:ring-red-500/10",
        :success => "border-green-300 focus:border-green-500 focus:ring-green-500/10",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    state_class = get(state_classes, state_sym, state_classes[:default])
    disabled_class = disabled ? "opacity-50 cursor-not-allowed" : ""

    base_classes = "w-full rounded-lg border bg-white dark:bg-slate-950 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none focus:ring-2 transition-colors $size_class $state_class $disabled_class"

    if !isnothing(icon)
        @div {class = "relative"} begin
            @div {
                class = "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3",
            } begin
                HypertextTemplates.SafeString(icon)
            end
            @input {
                type = type,
                class = "pl-10 $base_classes",
                placeholder = placeholder,
                name = name,
                value = value,
                required = required,
                disabled = disabled,
                attrs...,
            }
        end
    else
        @input {
            type = type,
            class = base_classes,
            placeholder = placeholder,
            name = name,
            value = value,
            required = required,
            disabled = disabled,
            attrs...,
        }
    end
end

@deftag macro Input end

"""
    @Textarea

A multi-line text input component.

# Props
- `rows::Int`: Number of visible rows (default: `4`)
- `resize::Union{Symbol,String}`: Resize behavior (`:none`, `:vertical`, `:horizontal`, `:both`) (default: `:vertical`)
- `state::Union{Symbol,String}`: Input state (`:default`, `:error`, `:success`) (default: `:default`)
- `placeholder::Union{String,Nothing}`: Placeholder text (optional)
- `name::Union{String,Nothing}`: Textarea name attribute (optional)
- `value::Union{String,Nothing}`: Textarea value (optional)
- `required::Bool`: Whether textarea is required (default: `false`)
- `disabled::Bool`: Whether textarea is disabled (default: `false`)
"""
@component function Textarea(;
    rows::Int = 4,
    resize::Union{Symbol,String} = :vertical,
    state::Union{Symbol,String} = :default,
    placeholder::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    attrs...,
)
    # Convert to symbols
    resize_sym = Symbol(resize)
    state_sym = Symbol(state)

    resize_classes = Dict(
        :none => "resize-none",
        :vertical => "resize-y",
        :horizontal => "resize-x",
        :both => "resize",
    )

    state_classes = Dict(
        :default => "border-slate-300 focus:border-slate-900 focus:ring-slate-900/10",
        :error => "border-red-300 focus:border-red-500 focus:ring-red-500/10",
        :success => "border-green-300 focus:border-green-500 focus:ring-green-500/10",
    )

    resize_class = get(resize_classes, resize_sym, "resize-y")
    state_class = get(state_classes, state_sym, state_classes[:default])
    disabled_class = disabled ? "opacity-50 cursor-not-allowed" : ""

    @textarea {
        rows = rows,
        class = "w-full px-4 py-2 text-base rounded-lg border bg-white dark:bg-slate-950 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none focus:ring-2 transition-colors $resize_class $state_class $disabled_class",
        placeholder = placeholder,
        name = name,
        required = required,
        disabled = disabled,
        attrs...,
    } begin
        if !isnothing(value)
            value
        end
    end
end

@deftag macro Textarea end

"""
    @Select

A dropdown select element.

# Props
- `size::Union{Symbol,String}`: Select size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `state::Union{Symbol,String}`: Select state (`:default`, `:error`, `:success`) (default: `:default`)
- `options::Vector{Tuple{String,String}}`: Options as (value, label) tuples
- `placeholder::Union{String,Nothing}`: Placeholder option text (optional)
- `name::Union{String,Nothing}`: Select name attribute (optional)
- `value::Union{String,Nothing}`: Selected value (optional)
- `required::Bool`: Whether select is required (default: `false`)
- `disabled::Bool`: Whether select is disabled (default: `false`)
"""
@component function Select(;
    size::Union{Symbol,String} = :md,
    state::Union{Symbol,String} = :default,
    options::Vector{Tuple{String,String}} = Tuple{String,String}[],
    placeholder::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    state_sym = Symbol(state)

    size_classes = Dict(
        :sm => "px-3 py-1.5 pr-8 text-sm",
        :md => "px-4 py-2 pr-10 text-base",
        :lg => "px-4 py-3 pr-10 text-lg",
    )

    state_classes = Dict(
        :default => "border-slate-300 focus:border-slate-900 focus:ring-slate-900/10",
        :error => "border-red-300 focus:border-red-500 focus:ring-red-500/10",
        :success => "border-green-300 focus:border-green-500 focus:ring-green-500/10",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    state_class = get(state_classes, state_sym, state_classes[:default])
    disabled_class = disabled ? "opacity-50 cursor-not-allowed" : ""

    @select {
        class = "w-full appearance-none rounded-lg border bg-white dark:bg-slate-950 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 transition-colors bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"%3e%3cpolyline points=\"6 9 12 15 18 9\"%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:1.5em_1.5em] bg-[right_0.5rem_center] bg-no-repeat $size_class $state_class $disabled_class",
        name = name,
        required = required,
        disabled = disabled,
        attrs...,
    } begin
        if !isnothing(placeholder)
            @option {value = "", selected = isnothing(value)} placeholder
        end
        for (opt_value, opt_label) in options
            @option {
                value = opt_value,
                selected = (!isnothing(value) && value == opt_value),
            } opt_label
        end
    end
end

@deftag macro Select end

"""
    @Checkbox

A styled checkbox input.

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

    size_classes = Dict(:sm => "h-3.5 w-3.5", :md => "h-4 w-4", :lg => "h-5 w-5")

    color_classes = Dict(
        :slate => "text-slate-600 focus:ring-slate-500",
        :primary => "text-slate-900 dark:text-slate-100 focus:ring-slate-900 dark:focus:ring-slate-100",
        :success => "text-green-600 focus:ring-green-500",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    color_class = get(color_classes, color_sym, color_classes[:primary])
    disabled_class = disabled ? "opacity-50 cursor-not-allowed" : ""

    if !isnothing(label)
        Elements.@label {class = "inline-flex items-center gap-2 $disabled_class"} begin
            @input {
                type = "checkbox",
                class = "rounded border-slate-300 bg-white dark:bg-slate-950 focus:ring-2 focus:ring-offset-0 transition-colors $size_class $color_class",
                name = name,
                value = value,
                checked = checked,
                required = required,
                disabled = disabled,
                attrs...,
            }
            @span {class = "text-sm text-slate-700 dark:text-slate-300"} label
        end
    else
        @input {
            type = "checkbox",
            class = "rounded border-slate-300 bg-white dark:bg-slate-950 focus:ring-2 focus:ring-offset-0 transition-colors $size_class $color_class $disabled_class",
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

"""
    @Radio

Radio button component for single selection.

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

    size_classes = Dict(:sm => "h-3.5 w-3.5", :md => "h-4 w-4", :lg => "h-5 w-5")

    color_classes = Dict(
        :slate => "text-slate-600 focus:ring-slate-500",
        :primary => "text-slate-900 dark:text-slate-100 focus:ring-slate-900 dark:focus:ring-slate-100",
        :success => "text-green-600 focus:ring-green-500",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    color_class = get(color_classes, color_sym, color_classes[:primary])
    disabled_class = disabled ? "opacity-50 cursor-not-allowed" : ""

    @div {class = "space-y-2", attrs...} begin
        for (opt_value, opt_label) in options
            Elements.@label {class = "inline-flex items-center gap-2 $disabled_class"} begin
                @input {
                    type = "radio",
                    class = "border-slate-300 bg-white dark:bg-slate-950 focus:ring-2 focus:ring-offset-0 transition-colors $size_class $color_class",
                    name = name,
                    value = opt_value,
                    checked = (!isnothing(value) && value == opt_value),
                    required = required,
                    disabled = disabled,
                }
                @span {class = "text-sm text-slate-700 dark:text-slate-300"} opt_label
            end
        end
    end
end

@deftag macro Radio end

"""
    @FormGroup

Form field wrapper with label and help text.

# Props
- `label::Union{String,Nothing}`: Field label (optional)
- `help::Union{String,Nothing}`: Help text (optional)
- `error::Union{String,Nothing}`: Error message (optional)
- `required::Bool`: Whether field is required (default: `false`)
"""
@component function FormGroup(;
    label::Union{String,Nothing} = nothing,
    help::Union{String,Nothing} = nothing,
    error::Union{String,Nothing} = nothing,
    required::Bool = false,
    attrs...,
)
    @div {class = "space-y-1", attrs...} begin
        if !isnothing(label)
            Elements.@label {
                class = "block text-sm font-medium text-slate-700 dark:text-slate-300",
            } begin
                label
                if required
                    @span {class = "text-red-500 ml-1"} "*"
                end
            end
        end

        @__slot__()

        if !isnothing(error)
            @p {class = "text-sm text-red-600 dark:text-red-400"} error
        elseif !isnothing(help)
            @p {class = "text-sm text-slate-500 dark:text-slate-400"} help
        end
    end
end

@deftag macro FormGroup end
