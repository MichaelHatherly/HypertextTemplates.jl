const FOR_TAG = "for"

struct For <: AbstractNode
    iter::String
    item::String
    index::Union{String,Nothing}
    body::Vector{AbstractNode}

    function For(iter, item, index, body)
        return new(
            _restore_special_symbols(iter),
            _restore_special_symbols(item),
            _restore_special_symbols(index),
            body,
        )
    end
end

function For(n::EzXML.Node)
    tag = EzXML.nodename(n)
    if tag == FOR_TAG
        attrs = Dict(attributes(n))
        haskey(attrs, "iter") || error("expected a 'iter' attribute for a 'for' node.")
        haskey(attrs, "item") || error("expected a 'item' attribute for a 'for' node.")
        iter = key_default(attrs, "iter")
        item = key_default(attrs, "item")
        index = key_default(attrs, "index")
        return For(iter, item, index, transform(EzXML.nodes(n)))
    else
        error("expected a '<for>' tag, found: $tag")
    end
end

Base.show(io::IO, f::For) = print(io, "$For($(f.iter), $(f.item), $(f.index))")
AbstractTrees.children(f::For) = f.body

function expression(c::BuilderContext, f::For)
    item = Symbol(f.item)
    iter = Meta.parse(f.iter)

    item = isnothing(f.index) ? item : Expr(:tuple, Symbol(f.index), item)
    iter = isnothing(f.index) ? iter : Expr(:call, enumerate, iter)

    body = expression(c, f.body)
    quote
        for $(item) in $(iter)
            $(body)
        end
    end
end
