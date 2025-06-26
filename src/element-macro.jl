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
my_widget (generic function with 6 methods)

julia> # Use with @deftag for macro syntax
       @deftag macro my_widget end

julia> @render @my_widget {id = "w1", class = "custom"} "Widget content"
"<my-widget id=\"w1\" class=\"custom\">Widget content</my-widget>"
```

# Web Components
```jldoctest
julia> using HypertextTemplates

julia> # Define web component elements
       @element "ion-button" ion_button
ion_button (generic function with 6 methods)

julia> @element "ion-icon" ion_icon
ion_icon (generic function with 6 methods)

julia> @deftag macro ion_button end

julia> @deftag macro ion_icon end

julia> @render @ion_button {color = "primary", expand = "block"} begin
           @ion_icon {name = "save-outline", slot = "start"}
           "Save"
       end
"<ion-button color=\"primary\" expand=\"block\"><ion-icon name=\"save-outline\" slot=\"start\"></ion-icon>Save</ion-button>"
```

# Custom void elements
```jldoctest
julia> using HypertextTemplates

julia> # Define a self-closing custom element
       @element "custom-input" custom_input
custom_input (generic function with 6 methods)

julia> # Mark as void element
       HypertextTemplates._is_void_element(::HypertextTemplates.custom_inputType) = true

julia> @deftag macro custom_input end

julia> @render @custom_input {type = "text", value = "Hello"}
"<custom-input type=\"text\" value=\"Hello\">"
```

# Auto-generated names
```jldoctest
julia> using HypertextTemplates

julia> # Julia name is auto-generated from tag name
       @element "data-list"  # Creates data_list
data_list (generic function with 6 methods)

julia> @deftag macro data_list end

julia> @render @data_list {id = "mylist"} "Items"
"<data-list id=\"mylist\">Items</data-list>"
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
