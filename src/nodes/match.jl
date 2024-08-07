const CASE_TAG = "case"

struct Case
    when::String
    body::Vector{AbstractNode}
    line::Int

    function Case(when, body, line)
        return new(when, body, line)
    end
end

Base.show(io::IO, m::Case) = print(io, "$(Case)($(m.when))")
AbstractTrees.children(m::Case) = m.body

const MATCH_TAG = "match"

struct Match <: AbstractNode
    value::String
    cases::Vector{Case}
    line::Int

    function Match(ctx, n::Lexbor.Node)
        tag = Lexbor.nodename(n)
        if tag == MATCH_TAG
            nodes, fallback = split_fallback(n)
            attrs = Dict(attributes(n))
            value = key_default(attrs, "value")
            cases = []
            for each in nodes
                if Lexbor.nodename(each) == CASE_TAG
                    attrs = Dict(attributes(each))
                    if length(attrs) == 1
                        when = key_default(attrs, "when")
                        body = transform(ctx, Lexbor.nodes(each))
                        push!(cases, Case(when, body, nodeline(each)))
                    else
                        error("'match' nodes require a single attribute.")
                    end
                else
                    if Lexbor.iselement(each)
                        error("only 'case' nodes are allowed in 'match' nodes.")
                    end
                    # Silently drops text nodes found in the match block.
                end
            end
            return new(value, cases, nodeline(n))
        else
            error("expected a '<match>' tag, found: $tag")
        end
    end
end

Base.show(io::IO, ::Match) = print(io, "$(Match)()")
AbstractTrees.children(s::Match) = s.cases

function expression(c::BuilderContext, s::Match)
    cases = []
    for m in s.cases
        when = Meta.parse(m.when)
        body = expression(c, m.body)
        push!(cases, :($(when) => $body))
    end
    value = Meta.parse(s.value)
    quote
        $(Deps.Match).@match $(value) begin
            $(cases...)
        end
    end |> lln_replacer(c.file, s.line)
end
