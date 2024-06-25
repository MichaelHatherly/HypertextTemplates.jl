const FOR_TAG = "for"

struct For <: AbstractNode
    iter::String
    item::String
    index::Union{String,Nothing}
    body::Vector{AbstractNode}
    line::Int

    function For(iter, item, index, body, line)
        return new(iter, item, index, body, line)
    end
end

function For(ctx, n::Lexbor.Node)
    tag = Lexbor.nodename(n)
    if tag == FOR_TAG
        attrs = Dict(attributes(n))
        haskey(attrs, "iter") || error("expected a 'iter' attribute for a 'for' node.")
        haskey(attrs, "item") || error("expected a 'item' attribute for a 'for' node.")
        iter = key_default(attrs, "iter")
        item = key_default(attrs, "item")
        index = key_default(attrs, "index")
        return For(iter, item, index, transform(ctx, Lexbor.nodes(n)), nodeline(n))
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
    end |> lln_replacer(c.file, f.line)
end
