module HypertextTemplatesReviseExt

import HypertextTemplates as HTT
import Revise

HTT.__is_revise_loaded(::HTT.ReviseIsLoaded) = true

function _has_uuid(vec::Vector{Base.CodeInfo}, uuid::Symbol)
    for each in vec
        if uuid in each.slotnames
            return true
        end
    end
    return false
end

# Resolving one `@render` call site costs about 53us, nearly all of it in
# `CodeTracking.whereis`, and it used to run on every single render: a small
# render spent 97% of its time here. It goes stale for the two reasons every
# other source-derived answer does, so it is memoised the same way -- see
# `SourceCache` in `src/revise.jl` for the invalidation and the eviction.
#
# Keyed by the call site: the enclosing function's TYPE, the uuid the macro
# planted, and the source location.
#
# The type matters. Keying on the function *instance* looks equivalent and is
# not: a closure that captures anything is a fresh object on every call, so a
# `@render` inside one -- an HTTP handler built per request, say -- would add
# an entry per render and never reuse one. All instances of a closure share a
# type and therefore a method, so the resolved answer is the same for all of
# them, and keying on the type makes the entry count bounded by the number of
# call sites rather than the number of calls.
#
# The macro always pairs a given uuid with a single location, so the location
# is redundant for calls coming from `@render`, but leaving it out would hand a
# stale answer to any other caller resolving that uuid against a different
# line.
const SITES = HTT.SourceCache{Tuple{DataType,Symbol,LineNumberNode},Any}()

function _resolve_method_offset(f, uuid, __source__)
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
        try
            return Revise.CodeTracking.whereis(__source__, method)
        catch err
            @debug "CodeTracking.whereis failed, skipping source tracking." exception = err
            return nothing
        end
    end
end

function HTT._method_offset(::HTT.ReviseIsLoaded, f, uuid, __source__)
    if !isdefined(Revise, :CodeTracking)
        @debug "CodeTracking not available via Revise, skipping source tracking."
        return nothing
    end
    key = (typeof(f), uuid, __source__)
    # `mtime` returns 0.0 for anything that cannot be stat'ed, such as a call
    # site typed into the REPL. That is a stable value, which is correct here:
    # code that lives in no file never shifts within one. `string` rather than
    # `String`, since a `LineNumberNode` is allowed to carry no file at all.
    #
    # Negative results are memoised too, so a call site that cannot be resolved
    # does not repeat the search on every render.
    return HTT._cached(SITES, key, string(__source__.file)) do
        _resolve_method_offset(f, uuid, __source__)
    end
end

end
