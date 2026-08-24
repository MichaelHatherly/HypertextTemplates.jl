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

# Hands the bytes over and leaves the buffer empty, matching `IOBuffer`.
function Base.take!(buffer::RenderBuffer)
    data = buffer.data
    resize!(data, buffer.size)
    buffer.data = UInt8[]
    buffer.size = 0
    return data
end

Base.position(buffer::RenderBuffer) = buffer.size
Base.bytesavailable(::RenderBuffer) = 0
Base.isreadable(::RenderBuffer) = false
Base.iswritable(::RenderBuffer) = true
Base.isopen(::RenderBuffer) = true
Base.flush(::RenderBuffer) = nothing
Base.close(::RenderBuffer) = nothing
