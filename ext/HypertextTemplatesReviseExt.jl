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
const CACHE = Dict{Tuple{DataType,Symbol,LineNumberNode},Tuple{UInt,Float64,Any}}()

# Re-expanding a template hands out a fresh uuid, so a long editing session
# leaves behind an entry per revision per call site, never referenced again.
# The table is kept under a size no real template set reaches.
const CACHE_LIMIT = 8192

# What to throw away when it gets there.
#
# An entry is only ever returned when its world matches the current one, so an
# entry stamped with an older world is already guaranteed to miss and be
# recomputed the next time its call site renders. Dropping those costs nothing
# that was not lost anyway -- and after an edit, which is when this table grows
# in the first place, they are exactly the abandoned revisions.
#
# This used to be `empty!`, which met the bound by throwing away every live
# entry alongside the dead ones and making the next render of every active call
# site pay the full 53us again. It is kept below only as a floor, for the shape
# where a single world really does hold more live call sites than the limit.
function _evict!(world::UInt)
    filter!(entry -> entry.second[1] == world, CACHE)
    length(CACHE) >= CACHE_LIMIT && empty!(CACHE)
    return nothing
end

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
    world = Base.get_world_counter()
    # `mtime` returns 0.0 for anything that cannot be stat'ed, such as a call
    # site typed into the REPL. That is a stable value, which is correct here:
    # code that lives in no file never shifts within one. `string` rather than
    # `String`, since a `LineNumberNode` is allowed to carry no file at all.
    stamp = mtime(string(__source__.file))
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
        length(CACHE) >= CACHE_LIMIT && _evict!(world)
        CACHE[key] = (world, stamp, result)
        return result
    finally
        unlock(CACHE_LOCK)
    end
end

end
