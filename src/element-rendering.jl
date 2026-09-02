abstract type AbstractElement end

Base.show(io::IO, element::AbstractElement) = print(io, "<", _element_name(element), "/>")

_element_name(_) = error("Method not implemented.")

# `@deftag` splices the element or component itself into the `@<` call, so the
# name the template wrote is gone by expansion and only the value is left.
_tag_name(tag::AbstractElement) = _element_name(tag)
_tag_name(tag::Function) = nameof(tag)
_tag_name(tag) = tag

# Formatting here rather than at each `@<` site keeps a string per element out
# of every expansion.
@noinline function _outside_render(tag)
    name = _tag_name(tag)
    return error(
        "`@$(name)` and `@<$(name)` cannot be used outside of a `@render` or `@component` macro.",
    )
end

# A `Tuple` rather than a `Set` so that the membership test is a chain of
# pointer comparisons that constant-folds away entirely when the element name
# is statically known, which it is for every `@element`-defined tag. A `Set`
# literal here would instead be rebuilt on every single element that gets
# rendered.
const VOID_ELEMENTS = (
    :area,
    :base,
    :br,
    :col,
    :embed,
    :hr,
    :img,
    :input,
    :link,
    :meta,
    :param,
    :source,
    :track,
    :wbr,
)
_void_element(elem::Symbol) = elem in VOID_ELEMENTS
# Custom elements defined with a `String` name are never void elements.
_void_element(_) = false

# These two hold raw text, where entities are not decoded, so escaping the body
# changes the program that runs. `RawTextWriter` handles what cannot appear
# there, and needs to know which of the two it is writing.
#
# `textarea` and `title` are left out deliberately: their content is escapable
# raw text, where ordinary escaping is right.
const RAW_TEXT_ELEMENTS = (:script, :style)
_raw_text_element(elem::Symbol) = elem in RAW_TEXT_ELEMENTS
# A custom element declared with a `String` name is parsed as ordinary markup.
_raw_text_element(_) = false

# `@deftag` splices the element into the `@<` call, so `@script` and `@style`
# are known during expansion. `@<` over a variable is the exception: the
# element only arrives with the render, and the children are escaped.
_raw_text_children(tag::AbstractElement) = _raw_text_element(tag)
_raw_text_children(_) = false

# Only asked of a raw text element, and only a symbol name makes one.
_script_children(tag) = _raw_text_children(tag) && _element_name(tag) === :script

# `@element` precomputes these. The fallbacks cover any element type that was
# built by hand rather than through the macro; they allocate, so the macro is
# very much the preferred route.
_element_open(element) = string("<", _element_name(element))
_element_close(element) =
    _void_element(_element_name(element)) ? "" : string("</", _element_name(element), ">")
# The name in a type parameter, so that it can be merged with literal
# properties during compilation. See `_write_open`.
_element_symbol(element) = Val(Symbol(_element_name(element)))

# Inlined, which is worth more than it looks.
#
# An element's children reach this as a closure in `slots`, and no two elements
# in a template share a closure type. Left as a call, that means a separate
# specialisation of this function -- inferred and code-generated in full -- for
# every single element on the page. Inlined, the closure is created and called
# in the same block, so the compiler drops it and the per-element method
# instance never exists. That is most of what a template costs to compile: a
# hundred elements with children take 12 ms each to compile, against 1.4 ms for
# the same call with no children.
#
# So this buys both ends at once, measured by alternating between the two
# builds rather than running one after the other, which on a noisy machine
# reads as a difference that is not there:
#
#   400-card page          87.9 -> 78.0 us    (-11%)
#   50-element template     635 -> 476 ms     (-25%, compile)
#   200-element template   2847 -> 2186 ms    (-23%, compile)
@inline function _render_tag(
        io::IO,
        tag::AbstractElement,
        plan,
        props,
        slots,
        source,
        revise,
    )
    _render_prefix(io, tag)
    # Both conditions are compile-time constants, so only one branch survives.
    # A plan is a `Tuple` unless `@<` gave up on one, which splatted props and
    # a literal value carrying a NUL byte both do.
    if !_is_revise_loaded() && plan isa Tuple
        _write_open(io, _element_symbol(tag), plan, props)
    else
        print(io, _element_open(tag))
        _render_plan(io, plan, props)
        _is_revise_loaded() && _render_source_prop(io, source, revise)
        print(io, ">")
    end
    children = get(slots, S"default", nothing)
    # A raw text element builds its writer in the default slot itself, so the
    # closure gets the stream as it stands; every other element renders markup,
    # which inside a raw text one means a markup stream over that writer. Both
    # conditions are compile-time constants.
    if !isnothing(children)
        if _raw_text_children(tag)
            children(io)
        else
            _markup_scope(children, io)
        end
    end
    close_tag = _element_close(tag)
    # Empty for void elements, where the check folds away at compile time.
    isempty(close_tag) || print(io, close_tag)
    return nothing
end

# A name goes into the tag as it stands, since no encoding of it reads back as
# one attribute, so a name that can leave its attribute can only be refused:
# `{d...}` over a dictionary keyed on user input would otherwise write
# `x" onmouseover="alert(1)` and hand the page a second attribute.
#
# The forbidden set is HTML's own. Bytes above ASCII belong to a multi-byte
# character and are left to the parser. A literal name is checked while `@<`
# serialises it, so a bad one fails to compile; a name arriving with the render
# is checked here.
@inline _valid_attribute_byte(byte::UInt8) =
    byte > UInt8(' ') &&
    byte != UInt8('"') &&
    byte != UInt8('\'') &&
    byte != UInt8('>') &&
    byte != UInt8('/') &&
    byte != UInt8('=') &&
    byte != 0x7f

# Symbols are interned for the life of the session, so the name their pointer
# refers to cannot be collected while it is being read.
function _check_attribute_name(name::Symbol)
    bytes = Base.unsafe_convert(Ptr{UInt8}, name)
    index = 1
    while true
        byte = unsafe_load(bytes, index)
        iszero(byte) && return nothing
        _valid_attribute_byte(byte) || _invalid_attribute_name(name)
        index += 1
    end
    return
end

function _check_attribute_name(name::AbstractString)
    for index in 1:ncodeunits(name)
        _valid_attribute_byte(codeunit(name, index)) || _invalid_attribute_name(name)
    end
    return nothing
end

_check_attribute_name(name) = _check_attribute_name(string(name))

@noinline _invalid_attribute_name(name) = throw(
    ArgumentError(
        "invalid HTML attribute name `$(name)`: a name cannot contain a control character, a space, or any of `\"`, `'`, `>`, `/`, `=`.",
    ),
)

@inline function _render_prop(io::IO, k, v)
    if v === false
        # Skip it entirely.
    else
        _check_attribute_name(k)
        print(io, " ", k)
        if v === true
            # Don't print the value.
        else
            print(io, "=\"")
            escape_attr(io, v)
            print(io, "\"")
        end
    end
    return nothing
end

function _render_props(io::IO, props)
    for (k, v) in props
        _render_prop(io, k, v)
    end
    return
end

# `NamedTuple` props are unrolled rather than iterated so that each property is
# rendered with its own concrete value type. Iterating `pairs(props)` widens the
# values to their union, which costs a dynamic dispatch per property once more
# than a handful of distinct types are involved.
_render_props(io::IO, ::NamedTuple{(), Tuple{}}) = nothing
@inline function _render_props(io::IO, props::NamedTuple{names}) where {names}
    _render_prop(io, names[1], getfield(props, 1))
    _render_props(io, NamedTuple{Base.tail(names)}(Base.tail(Tuple(props))))
    return nothing
end

# The attribute text a run of literal properties renders to. `@<` calls this
# during expansion and puts the result in a `StaticProps` type parameter, so
# nothing here runs while a page is being rendered.
function _attribute_text(props)
    io = RenderBuffer()
    _render_props(io, props)
    return String(take!(io))
end

"""
    InterpolatedAttribute(parts::Tuple)

The unjoined pieces of an interpolated attribute value, such as the `"/item/"`
and `id` of `{href = "/item/\$id"}`.

Elements write the pieces straight to the stream, so nothing is built to be
thrown away. Only a component needs the value as a string, and `_render_tag`
joins it there, immediately before the component is called -- so a component
still receives the `SafeString` it has always received, and this type never
escapes into user code.

Literal pieces arrive already escaped and wrapped in [`SafeString`](@ref);
everything else is escaped as it is written.
"""
struct InterpolatedAttribute{P <: Tuple}
    parts::P
end

@inline _write_parts(io::IO, ::Tuple{}) = nothing
@inline function _write_parts(io::IO, parts::Tuple)
    escape_attr(io, first(parts))
    _write_parts(io, Base.tail(parts))
    return nothing
end

escape_attr(io::IO, value::InterpolatedAttribute) = _write_parts(io, value.parts)

# Joining is only ever reached through the component branch below.
function _materialise(value::InterpolatedAttribute)
    io = RenderBuffer(_sizehint(value.parts))
    _write_parts(io, value.parts)
    return SafeString(String(take!(io)))
end
_materialise(value) = value

# The already-escaped literal pieces give an exact lower bound on the result.
@inline _sizehint(::Tuple{}) = 0
@inline _sizehint(parts::Tuple) = _partsize(first(parts)) + _sizehint(Base.tail(parts))
@inline _partsize(part::SafeString) = ncodeunits(part)
@inline _partsize(part) = 8

# Rebuilding the property `NamedTuple` is only worth doing when something in it
# actually needs joining, and whether that is so is visible in its type. When
# nothing does -- the common case, including every component that takes no
# interpolated attribute -- the properties are passed through untouched.
@generated function _materialise(props::NamedTuple{names, T}) where {names, T}
    # A field needs joining if its type does not rule the lazy form out. Asking
    # whether the type intersects rather than whether it is a subtype matters
    # for a field typed loosely enough to hold either, which a subtype test
    # would wave through and leave unjoined.
    types = T.parameters
    lazy(S) = typeintersect(S, InterpolatedAttribute) !== Union{}
    any(lazy, types) || return :(props)
    values = map(eachindex(types)) do index
        field = :(getfield(props, $index))
        lazy(types[index]) ? :(_materialise($field)) : field
    end
    return :(NamedTuple{names}(($(values...),)))
end

# A "props plan" is the compile-time description of how an element's attributes
# are rendered. It is a tuple of segments, each either a run of attribute text
# that `@<` already escaped and serialised during macro expansion, or a
# reference to a property whose value is only known at runtime.
#
# Both segment kinds carry their payload in a type parameter, so the plan is a
# zero-size singleton: it costs nothing to pass and the recursion below unrolls
# into a straight line of writes. Storing the text in the tuple *values*
# instead would make the plan a heap-allocated object on every element.
struct StaticProps{text} end

# A generator runs in the world age its own method was defined in, so this has
# to sit above the one that reads it.
_static_text(::Type{StaticProps{text}}) where {text} = text

# A `print` call costs about as much as the bytes it writes, so the parts of an
# opening tag known at compile time are merged into one constant. The tag name
# takes the literal run leading the plan with it, and the closing `>` too when
# that run is the whole plan. Nothing after the first dynamic property can
# merge, since where it starts depends on that property's value.
#
# None of this applies under Revise, whose source location goes between the
# properties and the `>`.
@generated function _write_open(io::IO, ::Val{name}, plan::Tuple, props) where {name}
    segments = plan.parameters
    leading = !isempty(segments) && segments[1] <: StaticProps
    open = leading ? string("<", name, _static_text(segments[1])) : string("<", name)
    length(segments) == (leading ? 1 : 0) && return :(print(io, $(string(open, ">"))))
    rest = leading ? :($(Base.tail)(plan)) : :(plan)
    return quote
        print(io, $(open))
        _render_plan(io, $(rest), props)
        print(io, ">")
    end
end

# `bare` is `" name"`, used when the value turns out to be `true`, and `quoted`
# is `" name=\""`. Both are built during macro expansion for the same reason
# the open and close tags are: emitting the whole prefix in one write beats
# assembling it from the separator, the name and `="` on every render.
struct DynamicProp{name, bare, quoted} end

@inline _render_segment(io::IO, ::StaticProps{text}, props) where {text} =
    (print(io, text); nothing)

@inline function _render_segment(
        io::IO,
        ::DynamicProp{name, bare, quoted},
        props,
    ) where {name, bare, quoted}
    v = getfield(props, name)
    if v === false
        # Skip it entirely.
    elseif v === true
        # Don't print the value.
        print(io, bare)
    else
        print(io, quoted)
        escape_attr(io, v)
        print(io, "\"")
    end
    return nothing
end

_render_plan(io::IO, ::Tuple{}, props) = nothing
@inline function _render_plan(io::IO, plan::Tuple, props)
    _render_segment(io, first(plan), props)
    _render_plan(io, Base.tail(plan), props)
    return nothing
end

# Splatted props contribute names that are not known until runtime, so there is
# nothing to interleave static runs against, and a literal value carrying a NUL
# byte cannot be put in a type parameter at all. `@<` signals either by passing
# no plan, and the merged `NamedTuple` is rendered wholesale instead.
_render_plan(io::IO, ::Nothing, props) = _render_props(io, props)

_render_prefix(io::IO, element) = nothing

_include_data_htloc() = :include_data_htloc

_should_render_data_htloc(io::IO) =
    _is_revise_loaded() && get(io, _include_data_htloc(), true) === true

function _render_source_prop(io::IO, source::Tuple{String, Int}, revise)
    if get(io, _include_data_htloc(), true) === true
        root = get(io, :__root__, nothing)
        # `:__root__` may come from the caller's own `IOContext`, so any shape
        # other than ours is treated as no root.
        if root isa Tuple{String, Int}
            file, line = root
            print(io, " data-htroot=\"")
            escape_attr(io, file)
            print(io, ":")
            _write_integer(io, line)
            print(io, "\"")
        end
        offset = _dynamic_line_offset(io, revise)
        file, line = source
        print(io, " data-htloc=\"")
        escape_attr(io, file)
        print(io, ":")
        _write_integer(io, line + offset)
        print(io, "\"")
    end
    return nothing
end
_render_source_prop(io::IO, source, revise) = nothing

_line_offsets() = :__htloc_offsets__
_line_offsets_ref() = _line_offsets() => Ref{IdDict{Any, Tuple{Int, Int}}}()

# The offset below costs a `functionloc`, which walks the method table and goes
# through CodeTracking: about 5us a call. It used to run once per rendered
# element, which made a 200 row page a hundred times slower under Revise than
# without it.
#
# The answer only changes when Revise reloads code, and code cannot be reloaded
# part way through a render, so it is memoised for the duration of one
# `@render` and recomputed on the next. That keeps every edit visible on the
# following render while collapsing a page's worth of lookups into one per
# component. The cache lives on the render's `IOContext`, so concurrent renders
# do not share it.
_dynamic_line_offset(io::IO, ::Nothing) = 0
function _dynamic_line_offset(io::IO, revise)
    stored = get(io, _line_offsets(), nothing)
    # No cache on this stream: fall back to computing it every time.
    isnothing(stored) && return _compute_dynamic_line_offset(revise)
    # An `IOContext` hands properties back as `Any`, so this is narrowed rather
    # than looked up dynamically. A foreign ref is uncached, not cached against.
    stored isa Base.RefValue{IdDict{Any, Tuple{Int, Int}}} ||
        return _compute_dynamic_line_offset(revise)
    isassigned(stored) || (stored[] = IdDict{Any, Tuple{Int, Int}}())
    offsets = stored[]
    func, source = revise
    line = Int(source[2])
    # The line is checked against the entry rather than keyed, since a
    # `(func, line)` key would be boxed into the `IdDict` per element.
    cached = get(offsets, func, nothing)
    isnothing(cached) || (cached[1] == line && return cached[2])
    offset = _compute_dynamic_line_offset(revise)
    offsets[func] = (line, offset)
    return offset
end

# Keyed by the component's type rather than the function object: `@component`
# defines a named function, so the type is a singleton and the two are
# interchangeable, but the type is what stays stable if the same definition is
# reached through different bindings.
# The recorded line is part of the key here: this is only reached once per
# component per render, so building one costs nothing.
const LINE_OFFSETS = SourceCache{Tuple{DataType, Int}, Int}()

function _compute_dynamic_line_offset(revise)
    # This calculates the line offset caused by running `Revise` and editing a
    # source file in such a way that a definition is not re-evaluated, but it's
    # position within the source file changes, e.g. shifting a method up or
    # down due to edits elsewhere.
    #
    # We store the original location of the method when the `@component` macro
    # has expanded as well as the `Function` object itself. We then dynamically
    # lookup the function location (which `Revise` does update) and compare
    # that to the original, returning the calculated offset.
    #
    # `functionloc` walks the method table and goes through CodeTracking, and at
    # about 13us a call it was the single most expensive thing left in a render
    # under Revise -- a quarter of one. The per-render memo above collapses a
    # page's worth of elements into one call per component, but the next render
    # paid it again, and the render after that. It is the same answer until
    # Revise reloads the code, which is exactly what `SourceCache` is validated
    # against, so it is now worked out once per edit instead of once per render.
    r_func, r_source = revise
    file, r_line = r_source
    return _cached(LINE_OFFSETS, (typeof(r_func), Int(r_line)), file) do
        _, d_line = functionloc(r_func)
        return Int(d_line) - Int(r_line), true
    end
end
_compute_dynamic_line_offset(::Nothing) = 0
