struct Attribute
    name::String
    value::String
    dynamic::Bool
    interpolate::Bool

    function Attribute(name, value, dynamic)
        name = _restore_special_symbols(name)
        interpolate = startswith(name, "\$")
        name = lstrip(name, '\$')
        value = _restore_special_symbols(value)
        return new(name, value, dynamic, interpolate)
    end
end

function Attribute((name, value)::Pair{String,String})
    dynamic = startswith(name, ".")
    name = lstrip(name, '.')
    return Attribute(name, dynamic ? (isempty(value) ? name : value) : value, dynamic)
end

function expression(c::BuilderContext, a::Attribute)
    name = Symbol(a.name)
    if a.dynamic
        return Expr(:(kw), name, Meta.parse(a.value))
    elseif a.interpolate
        return Expr(:(kw), name, Meta.parse("\"\"\"$(a.value)\"\"\""))
    else
        return Expr(:kw, name, a.value)
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

    function Element(name, attributes, body, slots, line)
        return new(_restore_special_symbols(name), attributes, body, slots, line)
    end
end

function Element(n::EzXML.Node)
    name = EzXML.nodename(n)
    if name in RESERVED_ELEMENT_NAMES
        error("elements cannot be named after reserved node names: $name")
    end
    attrs = attributes(n)
    if name in VALID_HTML_ELEMENTS
        body = transform(EzXML.nodes(n))
        return Element(name, Attribute.(attrs), body, [], nodeline(n))
    else
        slots = []
        nodes = EzXML.nodes(n)
        for each in nodes
            if EzXML.iselement(each)
                tag = EzXML.nodename(each)
                if contains(tag, ':')
                    tag, slot = split(tag, ':'; limit = 2)
                    child =
                        Element(tag, [], transform(EzXML.nodes(each)), [], nodeline(each))
                    push!(slots, slot => [child])
                end
            end
        end
        if isempty(slots)
            push!(slots, UNNAMED_SLOT => transform(nodes))
        end
        return Element(name, Attribute.(attrs), [], slots, nodeline(n))
    end
end

Base.show(io::IO, e::Element) = print(io, "$(Element)($(e.name), $(join(e.props, " ")))")
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
        if e.name in VOID_ELEMENTS
            quote
                print($(c.io), "<", $(e.name))
                $(print_attributes)(
                    $(c.io);
                    $(_data_filename_attr)($(c.file), $(e.line))...,
                    $(attrs...),
                )
                print($(c.io), "/>")
            end |> lln_replacer(c.file, e.line)
        else
            name = Symbol(e.name)
            body = expression(c, e.body)
            quote
                print($(c.io), "<", $(e.name))
                $(print_attributes)(
                    $(c.io);
                    $(_data_filename_attr)($(c.file), $(e.line))...,
                    $(attrs...),
                )
                print($(c.io), ">")
                $(body)
                print($(c.io), "</", $(e.name), ">")
            end |> lln_replacer(c.file, e.line)
        end
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

# Used in `HypertextTemplatesReviseExt` to toggle the `data-htloc` attribute
# on and off during tests. Not a public API, do not rely on this.
const _DATA_FILENAME_ATTR = Ref(true)
_data_filename_attr(::Any, line) = (;)

function print_attributes(io::IO; attrs...)
    for (k, v) in attrs
        if v isa AbstractString && k === Symbol(v)
            print(io, " ", k)
        else
            print(io, " ", k, "=", '"', v, '"')
        end
    end
    return nothing
end
