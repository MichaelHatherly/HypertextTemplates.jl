const FALLBACK_TAG = "fallback"

abstract type AbstractNode end

transform(ctx, ns::Vector{Union{String,Lexbor.Node}}) = [transform(ctx, n) for n in ns]

function transform(ctx, n::Union{String,Lexbor.Node})
    if Lexbor.istext(n)
        return Text(ctx, n)
    else
        if Lexbor.iselement(n)
            tag = Lexbor.nodename(n)
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

function nodeline(node::Lexbor.Node)
    return something(node.source, (1, 1))[1]
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
