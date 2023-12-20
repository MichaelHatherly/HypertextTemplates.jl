const FALLBACK_TAG = "fallback"

abstract type AbstractNode end

transform(ctx, ns::Vector{EzXML.Node}) = [transform(ctx, n) for n in ns]

function transform(ctx, n::EzXML.Node)
    if EzXML.istext(n)
        return Text(ctx, n)
    else
        if EzXML.iselement(n)
            tag = EzXML.nodename(n)
            if tag == FOR_TAG
                return For(ctx, n)
            elseif tag == JULIA_TAG
                return Julia(ctx, n)
            elseif tag == SHOW_TAG
                return Show(ctx, n)
            elseif tag == MATCH_TAG
                return Match(ctx, n)
            elseif tag == SLOT_TAG
                return Slot(ctx, n)
            else
                return Element(ctx, n)
            end
        else
            return Text(cdata(n), 0)
        end
    end
end

function nodeline(node::EzXML.Node)
    node_ptr = node.ptr
    @assert node_ptr != C_NULL
    @assert unsafe_load(node_ptr).typ in (EzXML.ELEMENT_NODE, EzXML.TEXT_NODE)
    return unsafe_load(convert(Ptr{EzXML._Element}, node_ptr)).line
end

# TODO: is this hack sufficient, or required?
function cdata(n::EzXML.Node)
    buffer = IOBuffer()
    EzXML.prettyprint(buffer, n)
    text = String(take!(buffer))
    return replace(text, "<![CDATA[" => "", "]]>" => "")
end

struct BuilderContext
    io::Symbol
    slots::Symbol
    file::String

    function BuilderContext(file::AbstractString)
        return new(Symbol("#io#"), Symbol("#slots#"), file)
    end
end

function expression(c::BuilderContext, v::Vector{AbstractNode})
    return Expr(:block, (expression(c, each) for each in v)...)
end
