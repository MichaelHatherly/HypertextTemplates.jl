"""
    @__once__ expr

Evaluate `expr` only once per `@render` call.
"""
macro __once__(expr)
    key = QuoteNode(gensym(string(__module__)))
    io = esc(S"io")
    return quote
        if $(@__MODULE__)._missing_once_key($io, $key)
            $(esc(expr))
            $(@__MODULE__)._add_once_key!($io, $key)
        end
        nothing
    end
end

function _get_once(io::IO)
    once_ref = get(io, :__once__, nothing)
    isassigned(once_ref) || (once_ref[] = Set{Symbol}())
    once = once_ref[]
    return isnothing(once) ? error("missing `once` object.") : once
end

_missing_once_key(io::IO, key::Symbol) = !(key in _get_once(io))
_add_once_key!(io::IO, key::Symbol) = push!(_get_once(io), key)
