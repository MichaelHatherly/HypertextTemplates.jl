const JULIA_TAG = "julia"

struct Julia <: AbstractNode
    value::String

    function Julia(value)
        return new(_restore_special_symbols(value))
    end
end

function Julia(n::EzXML.Node)
    attrs = attributes(n)
    if length(attrs) == 1
        (name, value), = attrs
        if name == "value"
            return Julia(value)
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
    end
end

function escape_html(io::IO, value)
    if showable("text/html", value)
        show(io, "text/html", value)
    else
        escape_string(io, string(value))
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
            print(io, "&#39;")
        else
            print(io, c)
        end
    end
end
