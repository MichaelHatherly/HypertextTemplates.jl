abstract type AbstractElement end

Base.show(io::IO, element::AbstractElement) = print(io, "<", _element_name(element), "/>")

_element_name(_) = error("Method not implemented.")
_void_element(elem) = elem in Set([
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
])

function _render_tag(
    io::IO,
    tag::AbstractElement,
    static_props,
    props,
    slots,
    source,
    revise,
)
    _render_prefix(io, tag)
    name = _element_name(tag)
    print(io, "<", name)
    if isempty(static_props)
        _render_props(io, props)
    else
        print(io, static_props)
    end
    _is_revise_loaded() && _render_source_prop(io, source, revise)
    print(io, ">")
    children = get(slots, S"default", nothing)
    isnothing(children) || children()
    _void_element(name) || print(io, "</", name, ">")
    return nothing
end

function _render_props(io::IO, props)
    for (k, v) in props
        if v === false || v === nothing
            # Skip it entirely.
        else
            print(io, " ", k)
            if v === true
                # Don't print the value.
            else
                print(io, "=\"")
                escape_attr(io, v)
                print(io, "\"")
            end
        end
    end
end
_render_props(io::IO, props::NamedTuple) = _render_props(io, pairs(props))

function _render_props(props)
    io = IOBuffer()
    _render_props(io, props)
    return String(take!(io))
end

_render_prefix(io::IO, element) = nothing

_include_data_htloc() = :include_data_htloc

_should_render_data_htloc(io::IO) =
    _is_revise_loaded() && get(io, _include_data_htloc(), true) === true

function _render_source_prop(io::IO, source::Tuple{String,Int}, revise)
    if get(io, _include_data_htloc(), true) === true
        root = get(io, :__root__, nothing)
        if !isnothing(root)
            file, line = root
            print(io, " data-htroot=\"", "$(file):$(line)", "\"")
        end
        offset = _compute_dynamic_line_offset(revise)
        file, line = source
        print(io, " data-htloc=\"", "$(file):$(line + offset)", "\"")
    end
    return nothing
end
_render_source_prop(io::IO, source, revise) = nothing

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
    r_func, r_source = revise
    _, d_line = functionloc(r_func)
    _, r_line = r_source
    return d_line - r_line
end
_compute_dynamic_line_offset(::Nothing) = 0
