# The destination `@render` builds for itself.
#
# `IOBuffer` is a general-purpose type: it is seekable, readable, optionally
# appending and size-limited, and on Julia 1.11 and earlier its `unsafe_write`
# copies one byte at a time through a scalar loop rather than a `memcpy` (see
# `base/iobuffer.jl`). A render is nothing but a long sequence of writes, so
# that loop and its bookkeeping accounted for roughly a third of the profile.
#
# `RenderBuffer` does the one thing a render destination has to do — append
# bytes — and nothing else, which lets the copy go through `memcpy`. It only
# ever backs `@render` calls that produce a `String` or a `Vector{UInt8}`; a
# destination the caller supplies is still written to directly and unchanged.
#
# Julia 1.12 rewrote `IOBuffer` and its `unsafe_write` now does use `memcpy`
# for anything longer than four bytes, so the scalar loop is not the whole
# story and this does not become redundant when 1.12 is the minimum. Writing
# the same 147 KB page through both, buffers pre-grown so only the write path
# is timed:
#
#   Julia 1.11.7   IOBuffer 87.3 us   RenderBuffer 35.0 us   2.5x
#   Julia 1.12.0   IOBuffer 72.0 us   RenderBuffer 33.7 us   2.1x
#
# What is left after the `memcpy` fix is the generality: `ensureroom` and its
# compaction heuristics, the `maxsize`, `append`, `offset` and `ptr`
# arithmetic, and the clamping that every write has to do because the buffer
# might be seekable or size-limited. None of that applies to a sink that only
# ever appends.

mutable struct RenderBuffer <: IO
    data::Vector{UInt8}
    size::Int
end

# Room for a small fragment up front, so the common case of rendering a handful
# of elements allocates once and never grows.
const RENDER_BUFFER_START = 64

RenderBuffer(sizehint::Int = RENDER_BUFFER_START) =
    RenderBuffer(Vector{UInt8}(undef, sizehint), 0)

# Doubling, so a page that turns out to be large costs a handful of copies
# rather than one per write.
@noinline function _grow!(buffer::RenderBuffer, needed::Int)
    capacity = length(buffer.data)
    while capacity < needed
        capacity = capacity < RENDER_BUFFER_START ? RENDER_BUFFER_START : capacity * 2
    end
    resize!(buffer.data, capacity)
    return nothing
end

@inline function Base.unsafe_write(buffer::RenderBuffer, source::Ptr{UInt8}, n::UInt)
    count = n % Int
    at = buffer.size
    needed = at + count
    needed > length(buffer.data) && _grow!(buffer, needed)
    data = buffer.data
    GC.@preserve data unsafe_copyto!(pointer(data, at + 1), source, count)
    buffer.size = needed
    return count
end

@inline function Base.write(buffer::RenderBuffer, byte::UInt8)
    at = buffer.size
    at + 1 > length(buffer.data) && _grow!(buffer, at + 1)
    @inbounds buffer.data[at+1] = byte
    buffer.size = at + 1
    return 1
end

# Empties the buffer but keeps the capacity it has grown into, for a buffer
# that is filled and drained over and over.
_reset!(buffer::RenderBuffer) = (buffer.size = 0; nothing)

# Hands the bytes over and leaves the buffer empty, matching `IOBuffer`.
function Base.take!(buffer::RenderBuffer)
    data = buffer.data
    resize!(data, buffer.size)
    buffer.data = UInt8[]
    buffer.size = 0
    return data
end

# The rest of the `IO` interface is deliberately absent. `unsafe_write`,
# `write` and `take!` are what a render destination is asked for, and
# `position` is what the streaming writer asks its batch buffer for. There were
# once `isopen`, `close`, `bytesavailable`, `isreadable` and `iswritable` here
# as well, so the type would look like a complete `IO`; nothing called any of
# them, and `flush` merely repeated `Base`'s own `flush(::IO) = nothing`.
Base.position(buffer::RenderBuffer) = buffer.size
