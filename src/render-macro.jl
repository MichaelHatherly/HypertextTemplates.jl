"""
    @render [destination] dom

Renders the `dom` tree to the `destination` object.
When no `destination` is provided then the `dom` is rendered
directly to `String` and returned as the value of the expression.

This is only needed for rendering the root of the DOM tree, not for the
output of each individual component that is defined.
"""
macro render(destination, dom)
    thunk = Expr(:->, Expr(:tuple, S"io", S"revise"), dom)
    source = _source_info(__source__)
    :($(HypertextTemplates)._render($(esc(destination)), $(esc(thunk)), $(source)))
end

macro render(dom)
    thunk = Expr(:->, Expr(:tuple, S"io", S"revise"), dom)
    source = _source_info(__source__)
    :($(HypertextTemplates)._render(String, $(esc(thunk)), $(source)))
end

function _source_info(__source__)
    self = Symbol("#self#")
    uuid = gensym("@render")
    euuid = esc(uuid)
    quuid = QuoteNode(Symbol(lstrip(String(uuid), '#')))
    return quote
        if $(HypertextTemplates)._is_revise_loaded()
            let $(euuid) =
                    $(esc(Expr(:isdefined, self))) ? $(esc(Symbol("#self#"))) : nothing
                $(HypertextTemplates)._method_offset(
                    $(euuid),
                    $(quuid),
                    $(QuoteNode(__source__)),
                )
            end
        else
            nothing
        end
    end
end

function _has_uuid(vec::Vector{Base.CodeInfo}, uuid::Symbol)
    for each in vec
        if uuid in each.slotnames
            return true
        end
    end
    return false
end

function _method_offset(f, uuid, __source__)
    method = nothing
    for candidate in methods(f)
        lowered = Base.code_lowered(f, Base.tuple_type_tail(candidate.sig))
        if _has_uuid(lowered, uuid)
            method = candidate
            break
        end
    end
    if isnothing(method)
        @debug "could not detect method, giving up."
        return nothing
    else
        return CodeTracking.whereis(__source__, method)
    end
end

function _render(dst, dom_thunk::Function, source::Tuple{String,Integer})
    io = _render_dst(dst)
    ctx = IOContext(io, :__root__ => source, _once_ref())
    dom_thunk(ctx, nothing)
    return _render_return(io, dst)
end
function _render(dst, dom_thunk::Function, source::Nothing)
    io = _render_dst(dst)
    ctx = IOContext(io, _once_ref())
    dom_thunk(ctx, nothing)
    return _render_return(io, dst)
end

_once_ref() = :__once__ => Ref{Set{Symbol}}()

_render_dst(io::IO) = io
_render_dst(::Type{String}) = IOBuffer()
_render_dst(::Type{Vector{UInt8}}) = IOBuffer()
_render_dst(other) = error("unsupported `@render` destination `$(other)`.")

_render_return(io::IO, ::IO) = io
_render_return(io::IO, ::Type{String}) = String(take!(io))
_render_return(io::IO, ::Type{Vector{UInt8}}) = take!(io)
_render_return(::IO, other::Any) = error("unsupported `@render` destination `$(other)`.")

_render_tag(io::IO, tag, static_props, props, slots, source, revise) =
    tag(; props..., V"source" = source, V"io" = io, V"slots" = slots)
