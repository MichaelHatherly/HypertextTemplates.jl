const JULIA_TAG = "julia"

struct Julia <: AbstractNode
    value::String
    line::Int

    function Julia(value::AbstractString, line::Integer)
        return new(value, line)
    end
end

function Julia(ctx, n::Lexbor.Node)
    attrs = attributes(n)
    if length(attrs) == 1
        (name, value), = attrs
        if name == "value"
            return Julia(isempty(value) ? name : value, nodeline(n))
        else
            error("expected a 'value' attribute for a julia node.")
        end
    else
        error("expected a single attribute for a julia node.")
    end
end

function expression(c::BuilderContext, j::Julia)
    expr = Meta.parse(j.value)
    quote
        $(escape_html)($(c.io), $(expr))
    end |> lln_replacer(c.file, j.line)
end

function escape_html(io::IO, value)
    if showable("text/html", value)
        show(io, "text/html", value)
    else
        escape_html(io, string(value))
    end
end

function escape_html(io::IO, value::AbstractString)
    for c in value
        if c == '&'
            print(io, "&amp;")
        elseif c == '<'
            print(io, "&lt;")
        elseif c == '>'
            print(io, "&gt;")
        elseif c == '"'
            print(io, "&quot;")
        elseif c == '\''
            print(io, "&#x27;")
        elseif c == '/'
            print(io, "&#x2F;")
        elseif c == '`'
            print(io, "&grave;")
        elseif c == '='
            print(io, "&#x3D;")
        else
            print(io, c)
        end
    end
end
