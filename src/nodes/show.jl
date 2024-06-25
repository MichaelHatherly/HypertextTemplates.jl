const SHOW_TAG = "show"

struct Show <: AbstractNode
    when::String
    body::Vector{AbstractNode}
    fallback::Vector{AbstractNode}
    line::Int

    function Show(when, body, fallback, line)
        return new(when, body, fallback, line)
    end
end

function Show(ctx, n::Lexbor.Node)
    tag = Lexbor.nodename(n)
    if tag == SHOW_TAG
        attrs = Dict(attributes(n))
        haskey(attrs, "when") || error("expected a 'when' attribute for a 'show' node.")
        when = key_default(attrs, "when")
        nodes, fallback = split_fallback(n)
        return Show(
            when,
            transform(ctx, nodes),
            isnothing(fallback) ? [] : transform(ctx, Lexbor.nodes(fallback)),
            nodeline(n),
        )
    else
        error("expected a '<show>' tag, found: $tag")
    end
end

Base.show(io::IO, s::Show) = print(io, "$(Show)($(s.when))")
AbstractTrees.children(s::Show) = [s.body, s.fallback]

function expression(c::BuilderContext, s::Show)
    when = Meta.parse(s.when)
    body = expression(c, s.body)
    fallback = expression(c, s.fallback)
    quote
        if $(when)
            $(body)
        else
            $(fallback)
        end
    end |> lln_replacer(c.file, s.line)
end
