"""
    esc""

Perform HTML string escaping at macro expansion time rather than
runtime.
"""
macro esc_str(txt)
    return SafeString(sprint(escape_html, txt))
end

function escape_html(io::IO, value::AbstractString)
    for c in value
        if c == '&'
            print(io, "&amp;")
        elseif c == '<'
            print(io, "&lt;")
        elseif c == '>'
            print(io, "&gt;")
        else
            print(io, c)
        end
    end
end
escape_html(io::IO, ss::SafeString) = print(io, ss.str)
escape_html(io::IO, other) = escape_html(io, string(other))
escape_html(io::IO, value, revise) = escape_html(io, value)

function escape_attr(io::IO, value::AbstractString)
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
escape_attr(io::IO, ss::SafeString) = print(io, ss.str)
escape_attr(io::IO, other) = escape_attr(io, string(other))
