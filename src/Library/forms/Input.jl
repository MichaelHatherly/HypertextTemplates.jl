"""
    @Input

A styled text input field for collecting user input with support for various types (text, email, password, number). Features different states (default, error, success), optional icons, and full accessibility with smooth focus transitions.

# Props
- `type::String`: Input type (default: `"text"`)
- `size::Union{Symbol,String}`: Input size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `state::Union{Symbol,String}`: Input state (`:default`, `:error`, `:success`) (default: `:default`)
- `icon::Union{String,Nothing}`: Icon HTML to display (optional)
- `placeholder::Union{String,Nothing}`: Placeholder text (optional)
- `name::Union{String,Nothing}`: Input name attribute (optional)
- `value::Union{String,Nothing}`: Input value (optional)
- `required::Bool`: Whether input is required (default: `false`)
- `disabled::Bool`: Whether input is disabled (default: `false`)
- `id::Union{String,Nothing}`: Input ID for label association (optional)
- `aria_describedby::Union{String,Nothing}`: ID of element describing the input (optional)

# Accessibility
This component implements comprehensive form accessibility standards:

**ARIA Patterns:**
- Uses `aria-invalid="true"` for error states to communicate validation status
- Supports `aria-describedby` for associating help text or error messages
- Maintains proper input semantics with appropriate `type` attributes
- Required fields are marked with HTML `required` attribute

**Keyboard Navigation:**
- **Tab**: Moves focus to input field
- **Shift+Tab**: Moves focus to previous element
- **Enter**: Submits form (for most input types)
- All keyboard input works as expected for each input type

**Screen Reader Support:**
- Input purpose is communicated through `type`, `name`, and `placeholder`
- Error states are announced through `aria-invalid` and associated descriptions
- Required status is communicated to assistive technology
- Icon content is properly marked as decorative or informative

**Form Integration:**
- Inputs should be associated with labels using `for`/`id` relationships
- Error messages should be linked via `aria-describedby`
- Help text should be associated with input for context
- Fieldsets and legends should group related inputs

**Visual Design:**
- Focus indicators are clearly visible with high contrast
- Error states use both color and other visual indicators
- Sufficient color contrast maintained across all states (4.5:1 minimum)
- Icons and decorative elements don't interfere with screen readers
"""
@component function Input(;
    type::String = "text",
    size::Union{Symbol,String} = :base,
    state::Union{Symbol,String} = :default,
    icon::Union{String,Nothing} = nothing,
    placeholder::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    id::Union{String,Nothing} = nothing,
    aria_describedby::Union{String,Nothing} = nothing,
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbols
    size_sym = Symbol(size)
    state_sym = Symbol(state)

    # Direct theme access
    base_classes = theme.input.base
    size_class = theme.input.sizes[size_sym]
    state_class = theme.input.states[state_sym]
    disabled_class = disabled ? theme.input.disabled : ""

    final_classes = "$base_classes $size_class $state_class $disabled_class"
    aria_invalid = state_sym === :error ? "true" : nothing

    if !isnothing(icon)
        # Get icon styling from theme
        icon_wrapper = theme.input.icon_wrapper
        icon_container = theme.input.icon_container
        icon_padding = theme.input.icon_input_padding

        @div {class = icon_wrapper} begin
            @div {class = icon_container} begin
                @text HypertextTemplates.SafeString(icon)
            end
            @input {
                type = type,
                class = "$icon_padding $final_classes",
                placeholder = placeholder,
                name = name,
                value = value,
                required = required,
                disabled = disabled,
                id = id,
                "aria-invalid" := aria_invalid,
                "aria-describedby" := aria_describedby,
                attrs...,
            }
        end
    else
        @input {
            type = type,
            class = final_classes,
            placeholder = placeholder,
            name = name,
            value = value,
            required = required,
            disabled = disabled,
            id = id,
            "aria-invalid" := aria_invalid,
            "aria-describedby" := aria_describedby,
            attrs...,
        }
    end
end

@deftag macro Input end
