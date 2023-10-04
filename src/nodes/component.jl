const COMPONENT_TAG = "component"

struct Prop
    name::String
    value::String

    function Prop(name, value)
        return new(_restore_special_symbols(name), _restore_special_symbols(value))
    end
end

function Prop((name, value)::Pair)
    return Prop(name, isempty(value) ? name : value)
end

function expression(c::BuilderContext, p::Prop)
    name = Symbol(p.name)
    return p.name == p.value ? name : Expr(:(::), name, Meta.parse(p.value))
end

function expression(c::BuilderContext, ps::Vector{Prop})
    return [expression(c, each) for each in ps]
end

Base.show(io::IO, p::Prop) = print(io, "$(p.name)=$(repr(p.value))")

const VALID_HTML_ELEMENTS = Set([
    "a",
    "abbr",
    "address",
    "area",
    "article",
    "aside",
    "audio",
    "b",
    "base",
    "bdi",
    "bdo",
    "blockquote",
    "body",
    "br",
    "button",
    "canvas",
    "caption",
    "cite",
    "code",
    "col",
    "colgroup",
    "data",
    "datalist",
    "dd",
    "del",
    "details",
    "dfn",
    "dialog",
    "div",
    "dl",
    "dt",
    "em",
    "embed",
    "fieldset",
    "figcaption",
    "figure",
    "footer",
    "form",
    "h1",
    "h2",
    "h3",
    "h4",
    "h5",
    "h6",
    "head",
    "header",
    "hgroup",
    "hr",
    "html",
    "i",
    "iframe",
    "img",
    "input",
    "ins",
    "kbd",
    "keygen",
    "label",
    "legend",
    "li",
    "link",
    "main",
    "map",
    "mark",
    "math",
    "menu",
    "menuitem",
    "meta",
    "meter",
    "nav",
    "noscript",
    "object",
    "ol",
    "optgroup",
    "option",
    "output",
    "p",
    "param",
    "picture",
    "pre",
    "progress",
    "q",
    "rb",
    "rp",
    "rt",
    "rtc",
    "ruby",
    "s",
    "samp",
    "script",
    "section",
    "select",
    "slot",
    "small",
    "source",
    "span",
    "strong",
    "style",
    "sub",
    "summary",
    "sup",
    "svg",
    "table",
    "tbody",
    "td",
    "template",
    "textarea",
    "tfoot",
    "th",
    "thead",
    "time",
    "title",
    "tr",
    "track",
    "u",
    "ul",
    "var",
    "video",
    "wbr",
])

const VALID_SVG_ELEMENTS = Set([
    "svg",
    "a",
    "circle",
    "ellipse",
    "g",
    "line",
    "path",
    "polygon",
    "polyline",
    "rect",
    "text",
    "tspan",
    "defs",
    "symbol",
    "use",
    "image",
    "marker",
    "pattern",
    "mask",
    "linearGradient",
    "radialGradient",
    "stop",
    "clipPath",
    "filter",
    "feBlend",
    "feColorMatrix",
    "feComponentTransfer",
    "feComposite",
    "feConvolveMatrix",
    "feDiffuseLighting",
    "feDisplacementMap",
    "feFlood",
    "feGaussianBlur",
    "feImage",
    "feMerge",
    "feMergeNode",
    "feMorphology",
    "feOffset",
    "feSpecularLighting",
    "feTile",
    "feTurbulence",
    "animate",
    "animateColor",
    "animateMotion",
    "animateTransform",
    "set",
    "animateTransform",
    "animateMotion",
    "animateColor",
    "animate",
    "view",
    "script",
    "style",
    "desc",
    "title",
])
struct Component
    name::String
    html::Bool # Wraps an HTML document?
    props::Vector{Prop}
    body::Vector{AbstractNode}
    file::String
    mod::Module

    function Component(name, html, props, body, file, mod)
        if name in VALID_HTML_ELEMENTS
            error("cannot name a component the same as a valid HTML element name: $name")
        end
        if name in VALID_SVG_ELEMENTS
            error("cannot name a component the same as a valid SVG element name: $name")
        end
        if name in RESERVED_ELEMENT_NAMES
            error("cannot name a component the same as a reserved element name: $name")
        end
        return new(_restore_special_symbols(name), html, props, body, file, mod)
    end
end

function Component(n::EzXML.Node, file::String, mod::Module)
    if isabspath(file)
        if EzXML.iselement(n)
            tag = EzXML.nodename(n)
            if tag == COMPONENT_TAG
                attrs = attributes(n)
                if length(attrs) > 0
                    (name, value), props... = attrs
                    if isempty(value)
                        return Component(
                            name,
                            false,
                            Prop.(props),
                            transform(EzXML.nodes(n)),
                            file,
                            mod,
                        )
                    else
                        error("name (first attribute) of a component must have no value")
                    end
                else
                    error("expected a 'name' attribute for a component definition.")
                end
            elseif tag == "html"
                name = basename(first(splitext(file)))
                return Component(name, true, [], transform(EzXML.nodes(n)), file, mod)
            else
                error("expected a '<component>' or '<html>' tag, found: $tag")
            end
        else
            error("expected an element node for a component definition.")
        end
    else
        error("file path must be absolute: $file")
    end
end

Base.show(io::IO, c::Component) =
    print(io, "$Component($(c.name), $(join(c.props, " ")), $(basename(c.file)))")
AbstractTrees.children(c::Component) = c.body

function components(file::String, mod::Module)::Vector{Component}
    if endswith(file, ".html")
        content = _swap_special_symbols(read(file, String))
        if isempty(content)
            error("template file is empty: $file")
        else
            html = _with_filtered_logging() do
                return EzXML.parsehtml(content)
            end
            roots = findall("//$COMPONENT_TAG", html)
            roots = isempty(roots) ? findall("//html", html) : roots
            if isempty(roots)
                error("no '<component>' or '<html>' found in file: $file.")
            else
                return Component.(roots, Ref(file), Ref(mod))
            end
        end
    else
        error("template file must have an '.html' extension: $file")
    end
end

struct PropsAccessor{N<:NamedTuple}
    nt::N
end
PropsAccessor(keywords) = PropsAccessor(NamedTuple(keywords))

function Base.getproperty(p::PropsAccessor, name::Symbol)
    nt = getfield(p, :nt)
    if hasproperty(nt, name)
        return getproperty(nt, name)
    else
        error("no properly named '$name' found.")
    end
end

# Generates a function expression for a component. Handles both cases of a component:
# wrapping an HTML document or not. Also includes a check to see if the template file
# has been modified since the last time it was compiled. If so, it recompiles the
# template first before invoking the function again to ensure that the latest version
# of the template is used. Note that this functionality only works when Revise is
# loaded within the session.
function expression(c::Component)::Expr
    context = BuilderContext()
    body = expression(context, c.body)
    name = Symbol(c.name)
    expr = if c.html
        quote
            function $(name)($(context.io)::IO, $(context.slots)::NamedTuple = (;); props...)
                if $(_recompile_template)($(c.mod), $(c.file), $(mtime(c.file)))
                    Base.invokelatest($(name), $(context.io), $(context.slots); props...)
                else
                    props = $(PropsAccessor)(props)
                    print($(context.io), "<html lang='en'>")
                    $(body)
                    print($(context.io), "</html>")
                end
                return nothing
            end
        end
    else
        props = expression(context, c.props)
        # The actual component definition gets wrapped so that we can handle
        # potential keyword argument name changes prior to invoking the real
        # function.
        wrapped = gensym(name)
        quote
            function $(wrapped)(
                $(context.io)::IO,
                $(context.slots)::NamedTuple = (;);
                $(props...),
            )
                $(body)
                return nothing
            end
            function $(name)(
                $(context.io)::IO,
                $(context.slots)::NamedTuple = (;);
                props...,
            )
                if $(_recompile_template)($(c.mod), $(c.file), $(mtime(c.file)))
                    Base.invokelatest($(name), $(context.io), $(context.slots); props...)
                else
                    $(wrapped)($(context.io), $(context.slots); props...)
                end
                return nothing
            end
        end
    end
    return Base.remove_linenums!(expr)
end

# Decide whether to recompile the template or not.
function _recompile_template(mod::Module, file::String, mtime::Float64)
    if is_stale_template(file, mtime)
        Core.eval(mod, :(@template_str $file))
        @debug "Template file has been recompiled." mod file mtime
        return true
    else
        return false
    end
end
