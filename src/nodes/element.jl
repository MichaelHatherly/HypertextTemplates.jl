struct Attribute
    name::String
    value::String
    dynamic::Bool
    interpolate::Bool

    function Attribute(name, value, dynamic)
        interpolate = startswith(name, "\$")
        name = lstrip(name, '\$')
        return new(name, value, dynamic, interpolate)
    end
end

function Attribute((name, value)::Pair{String,String})
    dynamic = startswith(name, ".")
    name = name == "..." ? name : lstrip(name, '.')
    return Attribute(name, dynamic ? (isempty(value) ? name : value) : value, dynamic)
end

function expression(c::BuilderContext, a::Attribute)
    name = Symbol(a.name)
    if name == :...
        return Expr(:..., Meta.parse(a.value))
    elseif a.dynamic
        return Expr(:kw, name, Meta.parse(a.value))
    elseif a.interpolate
        expr = Meta.parse("\"\"\"$(a.value)\"\"\"")
        # When we interpolate prop values into another prop via Julia string
        # interpolation with the `$prop=value` syntax, we want to perform HTML
        # escaping on each value interpolated into the string, but not perform
        # escaping on the hardcoded values that appear directly in the HTML
        # template. This is what `_escape_html_str_expr` does. The resulting
        # value is a `SafeString`, which will not be further HTML escaped it
        # itself is interpolated into another string.
        escaped_expr = _escape_html_attr_str_expr(expr)
        return Expr(:kw, name, escaped_expr)
    else
        return Expr(:kw, name, SafeString(a.value))
    end
end

function expression(c::BuilderContext, as::Vector{Attribute})
    return [expression(c, each) for each in as]
end

struct Element <: AbstractNode
    name::String
    attributes::Vector{Attribute}
    body::Vector{AbstractNode}
    slots::Vector{Pair{String,Vector{AbstractNode}}}
    line::Int

    function Element(ctx, name, attributes, body, slots, line)
        attributes, line = _translate_data_sourcepos(ctx, attributes, line)
        attributes, body = _translate_julia_attribute(ctx, attributes, body, line)
        return new(name, attributes, body, slots, line)
    end
end

function _translate_julia_attribute(ctx, attributes::Vector, body::Vector, line::Integer)
    filtered_attributes = Attribute[]
    for each in attributes
        if each.name == "julia"
            isempty(body) || error("`julia` attribute added to non-empty node.")
            value = each.interpolate ? "\"\"\"$(each.value)\"\"\"" : each.value
            body = [Julia(value, line)]
        else
            push!(filtered_attributes, each)
        end
    end
    return filtered_attributes, body
end

# CommonMark HTML output stores a `data-sourcepos` attribute on each element
# to track source position. We use a slightly different attribute name in
# HypertextTemplates and don't care about column information.
function _translate_data_sourcepos(ctx, attributes::Vector, line::Integer)
    attrs = Attribute[]
    sourcepos = nothing
    for each in attributes
        if each.name == "data-sourcepos"
            sourcepos = each.value
        else
            push!(attrs, each)
        end
    end
    if isnothing(sourcepos)
        return attrs, ctx.markdown ? 0 : line
    else
        m = match(r"(\d+):(\d+)-(\d+):(\d+)", sourcepos)
        if isnothing(m)
            return attrs, 0
        else
            line = something(tryparse(Int, m.captures[1]), 0)
            return attrs, line
        end
    end
end

function Element(ctx, n::Lexbor.Node)
    name = Lexbor.nodename(n)
    if name in RESERVED_ELEMENT_NAMES
        error("elements cannot be named after reserved node names: $name")
    end
    attrs = attributes(n)
    if name in VALID_HTML_ELEMENTS || name in VALID_SVG_ELEMENTS
        body = transform(ctx, Lexbor.nodes(n))
        return Element(ctx, name, Attribute.(attrs), body, [], nodeline(n))
    else
        slots = []
        nodes = Lexbor.nodes(n)
        for each in nodes
            if Lexbor.iselement(each)
                tag = Lexbor.nodename(each)
                if contains(tag, ':')
                    tag, slot = split(tag, ':'; limit = 2)
                    child = Element(
                        ctx,
                        tag,
                        [],
                        transform(ctx, Lexbor.nodes(each)),
                        [],
                        nodeline(each),
                    )
                    push!(slots, slot => [child])
                end
            end
        end
        if isempty(slots)
            push!(slots, UNNAMED_SLOT => transform(ctx, nodes))
        end
        return Element(ctx, name, Attribute.(attrs), [], slots, nodeline(n))
    end
end

Base.show(io::IO, e::Element) =
    print(io, "$(Element)($(e.name), $(join(e.attributes, " ")))")
AbstractTrees.children(e::Element) = e.body

const VOID_ELEMENTS = [
    "area",
    "base",
    "br",
    "col",
    "embed",
    "hr",
    "img",
    "input",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr",
]

function expression(c::BuilderContext, e::Element)
    attrs = expression(c, e.attributes)
    if e.name in VALID_HTML_ELEMENTS || e.name in VALID_SVG_ELEMENTS
        attrs, static_attrs = _split_attributes(attrs)
        opening_tag = "<$(e.name)"
        opening_expr = quote
            print($(c.io), $(opening_tag))
            $(print_attributes)(
                $(c.io),
                $(static_attrs);
                $(_data_filename_attr)($(c.file), $(e.line))...,
                $(attrs...),
            )
        end
        if e.name in VOID_ELEMENTS
            quote
                $(opening_expr)
                print($(c.io), "/>")
            end
        else
            closing_tag = "</$(e.name)>"
            body = expression(c, e.body)
            quote
                $(opening_expr)
                print($(c.io), ">")
                $(body)
                print($(c.io), $(closing_tag))
            end
        end |> lln_replacer(c.file, e.line)
    else
        name = Symbol(e.name)
        function builder(slot, body)
            return Expr(:kw, slot, quote
                function ($(c.io)::IO,)
                    $(body)
                    return nothing
                end
            end) |> lln_replacer(c.file, e.line)
        end
        slots = Expr(
            :tuple,
            Expr(
                :parameters,
                (builder(Symbol(k), expression(c, v)) for (k, v) in e.slots)...,
            ),
        )
        :($(name)($(c.io), $(slots); $(attrs...))) |> lln_replacer(c.file, e.line)
    end
end

# Optimised printing of attributes that we know are "static" within the template
# functions, e.g. they are just strings. We print them all to a single `String`
# during macro expansion time and then just interpolate that string into the
# template function. This avoids runtime overhead of printing the attributes one
# by one every single time the template function is called.
function _split_attributes(attrs::Vector{Expr})
    dynamic_attrs = Expr[]
    static_attrs = Pair{Symbol,String}[]
    for each in attrs
        if _is_static_attribute(each)
            push!(static_attrs, each.args[1] => each.args[2])
        else
            push!(dynamic_attrs, each)
        end
    end
    if isempty(static_attrs)
        return dynamic_attrs, ""
    else
        buffer = IOBuffer()
        print_attributes(buffer; static_attrs...)
        return dynamic_attrs, String(take!(buffer))
    end
end

_is_static_attribute(ex::Expr) =
    Meta.isexpr(ex, :kw, 2) && isa(ex.args[1], Symbol) && isa(ex.args[2], String)

# Used in `HypertextTemplatesReviseExt` to toggle the `data-htloc` attribute
# on and off during tests. Not a public API, do not rely on this.
const _DATA_FILENAME_ATTR = Ref(true)
_data_filename_attr(::Any, line) = (;)

function print_attributes(io::IO, static_attrs::String = ""; attrs...)
    if !isempty(static_attrs)
        print(io, static_attrs)
    end
    for (k, v) in attrs
        if v isa AbstractString && (k === Symbol(v) || isempty(v))
            print(io, " ", k)
        else
            print(io, " ", k, "=", '"', v, '"')
        end
    end
    return nothing
end
