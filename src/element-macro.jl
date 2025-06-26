"""
    @element html_tag_name [julia_name]

Define a custom HTML element.

Creates a new HTML element that can be used with HypertextTemplates' macro syntax.
This is useful for custom elements, web components, or HTML elements not included
in the default set.

# Arguments
- `html_tag_name`: The HTML tag name as it will appear in output (e.g., "my-element")
- `julia_name`: Optional Julia identifier name (defaults to `html_tag_name` with invalid characters replaced)

# Examples
```jldoctest
julia> using HypertextTemplates

julia> # Define a custom element
       @element "my-widget" my_widget

julia> # Use with @deftag for macro syntax
       @deftag macro my_widget end
@my_widget (macro with 1 method)

julia> @render @my_widget {id = "w1", class = "custom"} "Widget content"
"<my-widget id=\\"w1\\" class=\\"custom\\">Widget content</my-widget>"
```

# Web Components
```jldoctest
julia> using HypertextTemplates

julia> # Define web component elements
       @element "ion-button" ion_button

julia> @element "ion-icon" ion_icon

julia> @deftag macro ion_button end
@ion_button (macro with 1 method)

julia> @deftag macro ion_icon end
@ion_icon (macro with 1 method)

julia> @render @ion_button {color = "primary", expand = "block"} begin
           @ion_icon {name = "save-outline", slot = "start"}
           "Save"
       end
"<ion-button color=\\"primary\\" expand=\\"block\\"><ion-icon name=\\"save-outline\\" slot=\\"start\\"></ion-icon>Save</ion-button>"
```

See also: [`@deftag`](@ref), [`@component`](@ref)
"""
macro element(name, binding = name)
    binding = Symbol(binding)
    if !Base.is_valid_identifier(binding)
        error(
            "binding name for element `$name` must be a valid Julia identifier. It is `$binding`.",
        )
    end
    type = Symbol("$(binding)Type")
    quote
        struct $(esc(type)) <: $(HypertextTemplates).AbstractElement end
        const $(esc(binding)) = $(esc(type))()

        $(HypertextTemplates)._element_name(::$(esc(type))) = $(QuoteNode(name))

        export $(esc(binding))
    end
end
