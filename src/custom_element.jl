"""
    @custom_element "custom-element-name"

Define a name for a custom element. This is a tag in the HTML templates that
simply prints itself back out rather than calling a defined template function,
or printing a valid HTML tag.

The `@custom_element` macro does not provide the definition of the custom
element itself, and is only used to allow rendering the tag of the custom
element in a rendered template.

See [Web Components](https://developer.mozilla.org/en-US/docs/Web/API/Web_components)
documentation for more information on custom elements and how they are used.
"""
macro custom_element(name)
    file = String(__source__.file)
    line = __source__.line
    quote
        function $(esc(Symbol(name)))(io::IO, slots::NamedTuple = (;); attributes...)
            $(custom_element)(
                io,
                $(String(name)),
                slots;
                $(_data_filename_attr)($(file), $(line))...,
                attributes...,
            )
        end
    end |> lln_replacer(file, line)
end

function custom_element(io::IO, name::String, slots::NamedTuple; attributes...)
    print(io, "<", name)
    print_attributes(io; attributes...)
    print(io, ">")
    print_slot(io, slots)
    print(io, "</", name, ">")
    return nothing
end

function print_slot(io::IO, slots::NamedTuple)
    unnamed_slot = Symbol(HypertextTemplates.UNNAMED_SLOT)
    haskey(slots, unnamed_slot) && getfield(slots, unnamed_slot)(io)
    return nothing
end
