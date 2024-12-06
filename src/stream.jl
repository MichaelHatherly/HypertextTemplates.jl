"""
    StreamingRender(func)

An iterable that will run the render function `func`, which takes a single `io`
argument that must be passed to the `@render` macro call.

```julia
for bytes in StreamingRender(io -> @render io @component {args...})
    write(http_stream, bytes)
end
```

Or use a `do` block rather than `->` syntax.
"""
struct StreamingRender
    io::SimpleBufferStream.BufferStream
    task::Task

    function StreamingRender(f)
        io = SimpleBufferStream.BufferStream()
        task = Threads.@spawn begin
            f(io)
            close(io)
        end
        return new(io, task)
    end
end

function Base.iterate(s::StreamingRender, state = nothing)
    bytes = readavailable(s.io)
    if isempty(bytes)
        wait(s.task)
        return nothing
    else
        return bytes, nothing
    end
end
Base.eltype(::Type{StreamingRender}) = Vector{UInt8}
Base.IteratorSize(::Type{StreamingRender}) = Base.SizeUnknown()

