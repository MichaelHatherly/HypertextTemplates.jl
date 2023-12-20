const SLOT_TAG = "slot"
const UNNAMED_SLOT = "#unnamed_slot#"

struct Slot <: AbstractNode
    name::Union{String,Nothing}
    line::Int

    function Slot(name, line)
        return new(_restore_special_symbols(name), line)
    end
end

function Slot(ctx, n::EzXML.Node)
    attrs = attributes(n)
    if isempty(attrs)
        return Slot(nothing, nodeline(n))
    else
        if length(attrs) == 1
            (name, value), attrs... = attrs
            if isempty(value)
                return Slot(name, nodeline(n))
            else
                error("slot name attributes should be valueless, got: $value.")
            end
        else
            error("incorrect number of slot attributes, must be zero or one.")
        end
    end
end

function expression(c::BuilderContext, s::Slot)
    if isnothing(s.name)
        :($(c.slots).$(Symbol(UNNAMED_SLOT))($(c.io)))
    else
        name = Symbol(s.name)
        :($(c.slots).$(name)($(c.io)))
    end |> lln_replacer(c.file, s.line)
end

"""
    slots([unnamed]; named...)

Helper function to construct `NamedTuple`s to pass to templates as their slots.

This function is useful when composing template functions within Julia code
rather than within template files templates. For example when rendering a
markdown template with a specific wrapper layout.

```julia
base_layout(stdout, slots(markdown(; title = "My Title")))
```

The above does several things:

  - Delays the rendering of the `markdown` template until the `base_layout`
    template requests rendering within it's unnamed slot.
  - Creates the `slots` object to assign the delayed `markdown` template to the
    unnamed slot.
  - Renders the `base_layout` template to `stdout` with the `slots` object, which
    will render the `markdown` template within the unnamed slot.
"""
slots(unnamed = (io) -> nothing; named...) = (; named..., Symbol(UNNAMED_SLOT) => unnamed)
