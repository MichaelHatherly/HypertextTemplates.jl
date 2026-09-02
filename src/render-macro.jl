"""
    @render [destination] dom

Render a template to the given destination.

If no destination is provided, renders to a `String` and returns it. The destination 
can be any IO object (e.g., `stdout`, `IOBuffer`, file handle) or a type like 
`String` or `Vector{UInt8}`.

This macro is only needed for rendering the root of the DOM tree, not for the
output of each individual component that is defined.

# Arguments
- `destination`: Optional IO object or type to render to (default: `String`)
- `dom`: The template expression to render

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @render @div "Hello, World!"
"<div>Hello, World!</div>"

julia> buffer = IOBuffer();

julia> @render buffer @span {class = "greeting"} "Hi!";

julia> String(take!(buffer))
"<span class=\\"greeting\\">Hi!</span>"

julia> @render Vector{UInt8} @p "Binary output"
20-element Vector{UInt8}:
 0x3c
 0x70
 0x3e
 0x42
 0x69
 0x6e
 0x61
 0x72
 0x79
 0x20
 0x6f
 0x75
 0x74
 0x70
 0x75
 0x74
 0x3c
 0x2f
 0x70
 0x3e
```

# Rendering to files
```julia
open("output.html", "w") do file
    @render file @html begin
        @head @title "My Page"
        @body @h1 "Hello!"
    end
end
```

See also: [`StreamingRender`](@ref), [`@component`](@ref)
"""
macro render(destination, dom)
    thunk = Expr(:->, Expr(:tuple, S"io", S"revise"), dom)
    source = _source_info(__source__)
    return :($(HypertextTemplates)._render($(esc(destination)), $(esc(thunk)), $(source)))
end

macro render(dom)
    thunk = Expr(:->, Expr(:tuple, S"io", S"revise"), dom)
    source = _source_info(__source__)
    return :($(HypertextTemplates)._render(String, $(esc(thunk)), $(source)))
end

function _source_info(__source__)
    self = Symbol("#self#")
    uuid = gensym("@render")
    euuid = esc(uuid)
    quuid = QuoteNode(Symbol(lstrip(String(uuid), '#')))
    return quote
        let $(euuid) = $(esc(Expr(:isdefined, self))) ? $(esc(Symbol("#self#"))) : nothing
            $(HypertextTemplates)._method_offset(
                $(HypertextTemplates).ReviseIsLoaded(),
                $(euuid),
                $(quuid),
                $(QuoteNode(__source__)),
            )
        end
    end
end

_method_offset(::Any, f, uuid, __source__) = nothing

function _render(dst, dom_thunk::Function, source::Tuple{String, Int})
    io = _render_dst(dst)
    ctx = _render_context(IOContext(io, :__root__ => source, _once_ref()))
    dom_thunk(ctx, nothing)
    return _render_return(io, dst)
end
function _render(dst, dom_thunk::Function, source::Nothing)
    io = _render_dst(dst)
    ctx = _render_context(IOContext(io, _once_ref()))
    dom_thunk(ctx, nothing)
    return _render_return(io, dst)
end

# The source-location cache is only ever read when Revise is loaded, and
# `_is_revise_loaded` is a compile-time constant, so a plain render carries
# neither the extra context entry nor the `Ref` that backs it.
_render_context(ctx::IOContext) =
    _is_revise_loaded() ? IOContext(ctx, _line_offsets_ref()) : ctx

_once_ref() = :__once__ => Ref{Set{Symbol}}()

_render_dst(io::IO) = io
_render_dst(::Type{String}) = RenderBuffer()
_render_dst(::Type{Vector{UInt8}}) = RenderBuffer()
_render_dst(other) = error("unsupported `@render` destination `$(other)`.")

_render_return(io::IO, ::IO) = io
_render_return(io::IO, ::Type{String}) = String(take!(io))
_render_return(io::IO, ::Type{Vector{UInt8}}) = take!(io)
_render_return(::IO, other::Any) = error("unsupported `@render` destination `$(other)`.")

# Components take their properties as keywords, so the props plan that `@<`
# builds for elements has nothing to do here. Neither does the call site's
# location: a component writes no tag of its own, and the elements it renders
# each report their own location for `data-htloc`.
#
# This is also the one place a component can be reached, and so the one place
# an interpolated attribute has to become a string. `_materialise` is a no-op
# unless the property types say otherwise, so a component with no interpolated
# attribute pays nothing for the check.
_render_tag(io::IO, tag, plan, props, slots, source, revise) =
    tag(; _materialise(props)..., V"io" = io, V"slots" = slots)
