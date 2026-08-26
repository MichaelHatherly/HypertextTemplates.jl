struct ReviseIsLoaded end

_is_revise_loaded() = __is_revise_loaded(ReviseIsLoaded())
__is_revise_loaded(::Any) = false

# Everything the source-tracking machinery works out is derived from source that
# Revise may reload, and all of it goes stale for exactly two reasons:
#
#   * the definition it describes was re-evaluated, which advances the world
#     counter, or
#   * its file was edited so that the definition kept its identity but moved,
#     which is the case this machinery exists for in the first place, and which
#     changes the file's modification time.
#
# Both are cheap to check -- a counter read and a `stat` -- against answers that
# cost tens of microseconds to produce. So they are checked, together, by one
# memo used for every such answer rather than each caller growing its own.
#
# None of it runs unless Revise is loaded.
struct SourceCache{K,V}
    lock::ReentrantLock
    entries::Dict{K,Tuple{UInt,Float64,V}}
    limit::Int
end

SourceCache{K,V}(; limit::Int = 8192) where {K,V} =
    SourceCache{K,V}(ReentrantLock(), Dict{K,Tuple{UInt,Float64,V}}(), limit)

# Re-expanding a template hands out fresh keys, so a long editing session leaves
# behind entries that are never referenced again, and the table is kept under a
# size no real template set reaches.
#
# What gets dropped to stay there are the entries that were doomed anyway. An
# entry is only ever returned when its world matches the current one, so one
# stamped with an older world is already guaranteed to miss and be recomputed
# the next time it is asked for -- and after an edit, the only thing that grows
# this table, those are precisely the abandoned revisions. Clearing outright is
# kept only as a floor, for the shape where one world really does hold more live
# entries than the limit.
function _evict!(cache::SourceCache, world::UInt)
    filter!(entry -> entry.second[1] == world, cache.entries)
    length(cache.entries) >= cache.limit && empty!(cache.entries)
    return nothing
end

"""
    _cached(compute, cache, key, file)

Return the memoised value for `key`, computing it with `compute` if the answer
is missing or has gone stale. `file` is the source file the answer depends on.

The lock spans the computation as well as the lookup, so that concurrent first
renders of a given key resolve it once between them rather than each paying the
full cost.
"""
function _cached(compute, cache::SourceCache{K,V}, key::K, file) where {K,V}
    world = Base.get_world_counter()
    stamp = mtime(file)
    lock(cache.lock)
    try
        entry = get(cache.entries, key, nothing)
        isnothing(entry) || (entry[1] == world && entry[2] == stamp && return entry[3])
        value = compute()
        length(cache.entries) >= cache.limit && _evict!(cache, world)
        cache.entries[key] = (world, stamp, value)
        return value
    finally
        unlock(cache.lock)
    end
end
