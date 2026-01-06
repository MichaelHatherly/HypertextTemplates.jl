"""
    @Textarea

A multi-line text input component designed for longer form content like comments, descriptions, or messages. Textareas expand on the functionality of regular inputs by allowing multiple lines of text and providing resize controls for user convenience. They maintain visual consistency with other form elements while offering additional features like customizable row counts and resize behavior. The component includes the same state management and theming capabilities as other form inputs, ensuring a seamless form experience.

# Props
- `rows::Int`: Number of visible rows (default: `4`)
- `resize::Union{Symbol,String}`: Resize behavior (`:none`, `:vertical`, `:horizontal`, `:both`) (default: `:vertical`)
- `state::Union{Symbol,String}`: Input state (`:default`, `:error`, `:success`) (default: `:default`)
- `placeholder::Union{String,Nothing}`: Placeholder text (optional)
- `name::Union{String,Nothing}`: Textarea name attribute (optional)
- `value::Union{String,Nothing}`: Textarea value (optional)
- `required::Bool`: Whether textarea is required (default: `false`)
- `disabled::Bool`: Whether textarea is disabled (default: `false`)
- `id::Union{String,Nothing}`: Textarea ID for label association (optional)
- `aria_describedby::Union{String,Nothing}`: ID of element describing the textarea (optional)
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
    id::Union{String,Nothing} = nothing,
    aria_describedby::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    resize_sym = Symbol(resize)
    state_sym = Symbol(state)

    resize_classes = (
        none = "resize-none",
        vertical = "resize-y",
        horizontal = "resize-x",
        both = "resize",
    )

    state_classes = (
        default = "border-slate-300 focus:border-indigo-500 focus:ring-indigo-500/20 dark:border-slate-600 dark:focus:border-indigo-400",
        error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500/20 dark:border-rose-600 dark:focus:border-rose-400",
        success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500/20 dark:border-emerald-600 dark:focus:border-emerald-400",
    )

    resize_class = get(resize_classes, resize_sym, "resize-y")
    state_class = get(state_classes, state_sym, state_classes.default)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""
    aria_invalid = state_sym === :error ? "true" : nothing

    @textarea {
        rows = rows,
        class = "w-full px-3.5 py-2 text-sm rounded-md border bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-colors duration-150 hover:border-slate-400 dark:hover:border-slate-500 $resize_class $state_class $disabled_class",
        placeholder = placeholder,
        name = name,
        required = required,
        disabled = disabled,
        id = id,
        "aria-invalid" := aria_invalid,
        "aria-describedby" := aria_describedby,
        attrs...,
    } begin
        if !isnothing(value)
            @text value
        end
    end
end

@deftag macro Textarea end
