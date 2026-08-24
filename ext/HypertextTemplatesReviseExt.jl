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
# render spent 97% of its time here.
#
# The result can only change in two ways, and both are cheap to detect:
#
#   * the enclosing method is redefined, which advances the world counter, or
#   * the file is edited so that the method keeps its definition but moves,
#     which is the case this whole mechanism exists to handle, and which
#     changes the file's modification time.
#
# So the answer is memoised against both. A stale entry is impossible without
# one of the two changing, and checking them costs about 0.6us rather than 53.
const CACHE_LOCK = ReentrantLock()
# Keyed by the call site in full. The macro always pairs a given uuid with a
# single location, so the location is redundant for calls coming from `@render`
# -- but leaving it out would hand a stale answer to any other caller that
# resolves the same uuid against a different line, which is a sharp edge not
# worth keeping to save a field.
const CACHE = Dict{Tuple{UInt,Symbol,LineNumberNode},Tuple{UInt,Float64,Any}}()

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
    key = (objectid(f), uuid, __source__)
    world = Base.get_world_counter()
    # `mtime` returns 0.0 for anything that cannot be stat'ed, such as a call
    # site typed into the REPL. That is a stable value, which is correct here:
    # code that lives in no file never shifts within one.
    stamp = mtime(String(__source__.file))
    # The lock is held across the computation as well as the lookup, so that
    # concurrent first renders resolve a given call site once between them
    # rather than each paying the full cost.
    lock(CACHE_LOCK)
    try
        cached = get(CACHE, key, nothing)
        if !isnothing(cached) && cached[1] == world && cached[2] == stamp
            return cached[3]
        end
        # Negative results are cached too, so a call site that cannot be
        # resolved does not repeat the search on every render.
        result = _resolve_method_offset(f, uuid, __source__)
        CACHE[key] = (world, stamp, result)
        return result
    finally
        unlock(CACHE_LOCK)
    end
end

end
