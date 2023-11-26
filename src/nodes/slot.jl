const SLOT_TAG = "slot"
const UNNAMED_SLOT = "#unnamed_slot#"

struct Slot <: AbstractNode
    name::Union{String,Nothing}
    line::Int

    function Slot(name, line)
        return new(_restore_special_symbols(name), line)
    end
end

function Slot(n::EzXML.Node)
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
