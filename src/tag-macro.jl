"""
    @<component_or_element
    @<component_or_element children...
    @<component_or_element {props...}
    @<component_or_element {props...} children...

Dynamically render a component or element from a variable.

The `@<` macro enables dynamic component selection, where the component or element
to render is determined at runtime. This is useful for polymorphic rendering,
component mappings, and conditional component selection.

# Arguments
- `component_or_element`: A variable containing a component function or element
- `props...`: Optional properties in `{}` syntax
- `children...`: Optional child content

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> # Dynamic element selection
       tag = Elements.div
       @render @<tag {class = "dynamic"} "Content"
"<div class=\\"dynamic\\">Content</div>"

julia> # Change element at runtime
       tag = span
       @render @<tag {class = "dynamic"} "Content"
"<span class=\\"dynamic\\">Content</span>"
```

# Dynamic component selection
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> # Define components
       @component function info_box(; message)
           @div {class = "info"} @p \$message
       end;

julia> @component function error_box(; message)
           @div {class = "error"} @strong \$message
       end;

julia> # Select component based on condition
       function render_message(type, message)
           component = type == :error ? error_box : info_box
           @render @<component {message}
       end
render_message (generic function with 1 method)

julia> render_message(:info, "All good!")
"<div class=\\"info\\"><p>All good!</p></div>"

julia> render_message(:error, "Something went wrong!")
"<div class=\\"error\\"><strong>Something went wrong!</strong></div>"
```

# With slots
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function wrapper(; variant = "default")
           @div {class = "wrapper-\$variant"} @__slot__
       end;

julia> # Dynamic wrapper
       w = wrapper
       @render @<w {variant = "special"} begin
           @h1 "Wrapped content"
       end
"<div class=\\"wrapper-special\\"><h1>Wrapped content</h1></div>"
```

See also: [`@component`](@ref), [`@deftag`](@ref)
"""
macro (<)(tag, args...)
    # Include source info if the file exists. This skips source info that
    # points to the REPL and other non-file environments.
    file = String(__source__.file)
    line = Int(__source__.line)
    source = isfile(file) ? (file, line) : nothing

    io = S"io"
    eio = esc(io)
    revise = S"revise"
    erevise = esc(revise)
    etag = esc(tag)

    props_plan, eprops, eslots = _process_args(args)
    quote
        if $(esc(Expr(:isdefined, io)))
            $(HypertextTemplates)._render_tag(
                $eio,
                $etag,
                $props_plan,
                $eprops,
                $eslots,
                $source,
                $(esc(Expr(:isdefined, revise))) ? $(erevise) : nothing,
            )
        else
            error(
                $(
                    "`@$tag` and `<$tag` cannot be used outside of a `@render` or `@component` macro."
                ),
            )
        end
    end
end

function _process_args(args)
    props_plan = :(())
    props = nothing
    slot_args = []
    slot_names = Set{Symbol}([])
    default_slot_contents = Expr(:block)

    function slot_fn(arg)
        if Meta.isexpr(arg, :(:=), 2)
            name, content = arg.args
            if name in slot_names
                error("cannot include duplicate slot names: `$name`.")
            else
                push!(slot_names, name)
                if isa(content, String) || Meta.isexpr(content, :string)
                    content = :($(HypertextTemplates).@text $content)
                end
                push!(slot_args, Expr(:(=), esc(name), :(() -> $(esc(content)))))
            end
        else
            if isa(arg, String) || Meta.isexpr(arg, :string)
                arg = :($(HypertextTemplates).@text $arg)
            elseif Meta.isexpr(arg, :$, 1)
                arg = :($(HypertextTemplates).@text $(arg.args[1]))
            end
            push!(default_slot_contents.args, esc(arg))
        end
    end

    for arg in args
        if Meta.isexpr(arg, :braces)
            if isnothing(props)
                props_plan, prop_pairs = _process_props(arg.args)
                props = :((; $(esc.(prop_pairs)...)))
            else
                error("duplicate `{}` props.")
            end
        elseif Meta.isexpr(arg, :block)
            for each in arg.args
                slot_fn(each)
            end
        else
            slot_fn(arg)
        end
    end

    slots = :((; $(slot_args...), V"default" = () -> $(default_slot_contents)))

    return props_plan, something(props, :((;))), slots
end

# Build the "props plan" described in `element-rendering.jl`: consecutive
# literal properties are escaped and serialised here, at macro expansion time,
# and only the properties whose values are genuinely dynamic are left to be
# rendered per call. Segments are emitted in source order, so the attribute
# order the user wrote is preserved.
#
# Previously this was all-or-nothing: a single dynamic property sent every
# other property on the element back through the runtime path.
function _process_props(args)
    props = []
    segments = []
    static_run = []
    splatted = false
    for arg in args
        static, dynamic = _process_prop(arg)
        # `props` must be built from every argument, splats included, since it
        # is what a component receives as keywords.
        push!(props, dynamic)
        if Meta.isexpr(dynamic, :...)
            # A splat contributes property names that are not known until
            # runtime, so there is nothing to interleave against. Give up on
            # the plan and let the merged `NamedTuple` be rendered wholesale.
            splatted = true
        elseif isnothing(static)
            _flush_static_run!(segments, static_run)
            push!(segments, _dynamic_segment(_prop_name(dynamic)))
        else
            push!(static_run, static)
        end
    end
    splatted && return nothing, props
    _flush_static_run!(segments, static_run)
    return Expr(:tuple, segments...), props
end

# The attribute prefixes never vary, so bake them into the segment's type
# rather than reassembling them from the name on every render.
function _dynamic_segment(name::Symbol)
    return :($(DynamicProp){
        $(QuoteNode(name)),
        $(QuoteNode(Symbol(" ", name))),
        $(QuoteNode(Symbol(" ", name, "=\""))),
    }())
end

function _flush_static_run!(segments, static_run)
    isempty(static_run) && return nothing
    text = _render_props(static_run)
    empty!(static_run)
    # A run of only `false` valued properties renders nothing at all.
    isempty(text) && return nothing
    push!(segments, :($(StaticProps){$(QuoteNode(Symbol(text)))}()))
    return nothing
end

_prop_name(ex::Expr) = __process_prop(ex.args[1])
_prop_name(name::Symbol) = name

function _process_prop(ex::Expr)
    if Meta.isexpr(ex, [:(=), :(:=)], 2)
        k, v = ex.args
        if isa(k, Union{String,Symbol}) || (isa(k, QuoteNode) && isa(k.value, Symbol))
            if isa(v, Union{AbstractString,Bool,Integer})
                return (
                    __process_prop(k) => _sanitise(v),
                    Expr(:(=), __process_prop(k), _sanitise(v)),
                )
            else
                return nothing, Expr(:(=), __process_prop(k), _sanitise(v))
            end
        end
    elseif Meta.isexpr(ex, :(...), 1)
        arg = ex.args[1]
        return nothing, Expr(:(...), __process_prop(arg))
    end
    error("unsupported prop expression: `$(ex)`")
end
_process_prop(s::AbstractString) = nothing, Symbol(s)
_process_prop(s::Symbol) = nothing, s

__process_prop(s::AbstractString) = Symbol(s)
__process_prop(s::Symbol) = s
__process_prop(s::QuoteNode) = s.value

# An interpolated attribute value such as `{href = "/item/$id"}` still has to
# be materialised, because a component receives it as a keyword and expects a
# string. It used to be built with one `sprint` per interpolated part plus a
# concatenation over the results, which meant several throwaway buffers and
# strings per attribute. The parts are now escaped straight into a single
# buffer instead.
#
# Each part is still escaped individually, exactly as before, so a `SafeString`
# interpolated into an attribute continues to pass through unescaped.
function _sanitise(ex::Expr)
    if Meta.isexpr(ex, :string)
        buffer = gensym("attribute")
        # Every referenced function is spliced as a value rather than named,
        # because the result is escaped into the caller's module.
        body = Expr(:block)
        for arg in ex.args
            push!(body.args, if isa(arg, AbstractString)
                # Literal segments are escaped here, during expansion.
                Expr(:call, print, buffer, sprint(escape_attr, arg))
            else
                Expr(:call, escape_attr, buffer, arg)
            end)
        end
        push!(
            body.args,
            Expr(:call, SafeString, Expr(:call, String, Expr(:call, take!, buffer))),
        )
        # The literal segments give an exact lower bound on the result, so size
        # the buffer up front rather than letting it grow.
        sizehint =
            sum(
                (sizeof(sprint(escape_attr, a)) for a in ex.args if isa(a, AbstractString));
                init = 0,
            ) + 8 * count(a -> !isa(a, AbstractString), ex.args)
        allocate = Expr(:call, IOBuffer, Expr(:parameters, Expr(:kw, :sizehint, sizehint)))
        return Expr(:let, Expr(:(=), buffer, allocate), body)
    else
        return ex
    end
end
_sanitise(other) = other
