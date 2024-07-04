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

function _escape_html_attr_str_expr(expr::Expr)
    Meta.isexpr(expr, :string) || return expr
    # When we encounter an interpolated string we wrap each interpolated
    # value with a call to `_escape_html_attribute` which will escape the
    # contents of the string. Strings that have already been escaped that
    # are then interpolated into nested element attributes will be wrapped
    # in a `SafeString` and will not be escaped again.
    escaped_expr = Expr(:string, _escape_html_str_expr_part.(expr.args)...)
    return Expr(:call, SafeString, escaped_expr)
end
_escape_html_attr_str_expr(other) = other

_escape_html_str_expr_part(string::String) = string
_escape_html_str_expr_part(other) = Expr(:call, _escape_html_attribute, other)

_escape_html_attribute(value) = sprint(escape_html, string(value))
# Strings marked as "safe" will not be escaped.
_escape_html_attribute(ss::SafeString) = ss

"""
    escape_html(io::IO, value::T)

Provide a custom implementation of HTML escaping for a given type `T`. This is
useful if you have specific types within your application that you would like to
have handle their own HTML escaping rather than the default behavior where all
values are stringified and escaped.

You should only ever use this on types that you know are safe to be rendered
directly into HTML without escaping. Never pass user-generated content into
types that implement this method without first verifying and escaping content
manually.
"""
function escape_html end

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
escape_html(io::IO, value) = escape_html(io, string(value))
