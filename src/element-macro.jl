"""
    @element name [html_name]

Define an HTML element `name` that prints to HTML as `html_name`, which defaults to
`name` itself.
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
