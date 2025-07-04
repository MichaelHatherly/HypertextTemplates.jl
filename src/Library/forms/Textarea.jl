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

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    base_classes = theme.textarea.base
    resize_class = theme.textarea.resize[resize_sym]
    state_class = theme.textarea.states[state_sym]
    disabled_class = disabled ? theme.textarea.disabled : ""
    aria_invalid = state_sym === :error ? "true" : nothing

    @textarea {
        rows = rows,
        class = "$base_classes $resize_class $state_class $disabled_class",
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
