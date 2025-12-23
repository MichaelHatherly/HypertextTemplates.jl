"""
    @FormGroup

A form field wrapper that provides consistent layout for form controls with labels, help text, and error messages. Automatically generates unique IDs and establishes proper accessibility relationships between elements.

# Props
- `label::Union{String,Nothing}`: Field label (optional)
- `help::Union{String,Nothing}`: Help text (optional)
- `error::Union{String,Nothing}`: Error message (optional)
- `required::Bool`: Whether field is required (default: `false`)
- `id::Union{String,Nothing}`: ID for the form field (will be auto-generated if not provided) (optional)

# Slots
- Form control element(s) - typically Input, Textarea, Select, Checkbox, or Radio components

# Example
```julia
# Basic form field
@FormGroup {label = "Email", help = "We'll never share your email."} begin
    @Input {type = "email", placeholder = "name@example.com"}
end

# Required field with error
@FormGroup {label = "Password", required = true, error = "Password must be at least 8 characters"} begin
    @Input {type = "password", state = :error}
end

# Checkbox group
@FormGroup {label = "Preferences"} begin
    @Checkbox {label = "Send me updates"}
end
```

# See also
- [`Input`](@ref) - Text input component
- [`Textarea`](@ref) - Multi-line text input
- [`Select`](@ref) - Dropdown select component
- [`Checkbox`](@ref) - Checkbox input
- [`Radio`](@ref) - Radio button group
"""
@component function FormGroup(;
    label::Union{String,Nothing} = nothing,
    help::Union{String,Nothing} = nothing,
    error::Union{String,Nothing} = nothing,
    required::Bool = false,
    id::Union{String,Nothing} = nothing,
    _hash = hash(time_ns()),
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    wrapper_class = theme.form_group.wrapper
    label_class = theme.form_group.label
    required_class = theme.form_group.required_indicator
    error_class = theme.form_group.error_text
    help_class = theme.form_group.help_text

    # Generate unique ID if not provided
    field_id = isnothing(id) ? "form-field-$(_hash)" : id
    error_id = !isnothing(error) ? "$(field_id)-error" : nothing
    help_id = !isnothing(help) && isnothing(error) ? "$(field_id)-help" : nothing
    describedby_id = !isnothing(error_id) ? error_id : help_id

    @div {class = wrapper_class, attrs...} begin
        if !isnothing(label)
            Elements.@label {class = label_class, "for" := field_id} begin
                @text label
                if required
                    @span {class = required_class} "*"
                end
            end
        end

        # TODO:
        # Pass the generated IDs to child components
        @__slot__ #(field_id, describedby_id)

        if !isnothing(error)
            @p {class = error_class, id = error_id} error
        elseif !isnothing(help)
            @p {class = help_class, id = help_id} help
        end
    end
end

@deftag macro FormGroup end
