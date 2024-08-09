"""
    @<TAG
    @<TAG children...
    @<TAG {props...}
    @<TAG {props...} children...

Render the `TAG` component or element with the given children and props.
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

    static_prop_str, eprops, eslots = _process_args(args)
    quote
        if $(esc(Expr(:isdefined, io)))
            $(HypertextTemplates)._render_tag(
                $eio,
                $etag,
                $static_prop_str,
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
    static_props = ""
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
                static_props, prop_pairs = _process_props(arg.args)
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

    return static_props, something(props, :((;))), slots
end

function _process_props(args)
    props = []
    dynamic_props = []
    static_props = []
    for arg in args
        static, dynamic = _process_prop(arg)
        push!(props, dynamic)
        isnothing(static) ? push!(dynamic_props, dynamic) : push!(static_props, static)
    end
    if isempty(dynamic_props)
        return _render_props(static_props), props
    else
        return "", props
    end
end

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

function _sanitise(ex::Expr)
    fn(s::AbstractString) = sprint(escape_attr, s)
    fn(other) = :(sprint($(escape_attr), $(other)))
    if Meta.isexpr(ex, :string)
        return Expr(:call, SafeString, Expr(:string, fn.(ex.args)...))
    else
        return ex
    end
end
_sanitise(other) = other
