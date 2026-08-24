"""
    @esc_str

Escape HTML at compile time and return a [`SafeString`](@ref).

This string macro performs HTML escaping during macro expansion rather than at
runtime, providing better performance for static content that needs escaping.

The resulting `SafeString` will not be escaped again during rendering.

See also: [`SafeString`](@ref), [`escape_html`](@ref)
"""
macro esc_str(txt)
    return SafeString(sprint(escape_html, txt))
end

# `print(io, ::Int)` builds a `String` first, so it allocates on every integer
# written. In a page of any size that dominates: a 200 row table spent about
# 85% of its allocations there. Integers are extremely common in templates --
# loop counters, ids, indices, sizes -- so they get written digit by digit into
# a fixed size stack buffer instead, and handed to the stream in one go.
#
# `Bool` is deliberately excluded: it prints as `true`/`false`, not `1`/`0`.
# `Int128`/`UInt128` and `BigInt` are excluded too, since for those the
# buffered loop is slower than `print` and they are vanishingly rare here.
const NativeInteger = Union{Int8,Int16,Int32,Int64,UInt8,UInt16,UInt32,UInt64}

function _write_integer(io::IO, n::NativeInteger)
    negative = n < 0
    # Negating `typemin` wraps back to `typemin`, whose reinterpretation as an
    # unsigned value is exactly the magnitude wanted, so this needs no special
    # case.
    u = negative ? unsigned(-n) : unsigned(n)
    # 20 digits holds `typemax(UInt64)`; the buffer is oversized for headroom
    # and never escapes, so it stays on the stack.
    buffer = Ref{NTuple{24,UInt8}}()
    len = 0
    GC.@preserve buffer begin
        ptr = Base.unsafe_convert(Ptr{UInt8}, buffer)
        index = 24
        while true
            quotient, remainder = divrem(u, oftype(u, 10))
            unsafe_store!(ptr, UInt8('0') + (remainder % UInt8), index)
            index -= 1
            len += 1
            u = quotient
            iszero(u) && break
        end
        if negative
            unsafe_store!(ptr, UInt8('-'), index)
            index -= 1
            len += 1
        end
        unsafe_write(io, ptr + index, UInt(len))
    end
    return nothing
end

"""
    escape_html(io::IO, value)

Write HTML-escaped content to an IO stream.

This function escapes HTML special characters to prevent XSS attacks when rendering
user content. It is automatically called by HypertextTemplates for all string content
unless wrapped in [`SafeString`](@ref).

# Escaped characters
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`

# Arguments
- `io::IO`: The output stream to write to
- `value`: The content to escape (converted to string if not already)

# Examples
```jldoctest
julia> using HypertextTemplates

julia> io = IOBuffer();

julia> HypertextTemplates.escape_html(io, "Hello <script>alert('XSS')</script>")

julia> String(take!(io))
"Hello &lt;script&gt;alert('XSS')&lt;/script&gt;"

julia> # SafeString content is not escaped
       io = IOBuffer();

julia> HypertextTemplates.escape_html(io, SafeString("<b>Bold</b>"))

julia> String(take!(io))
"<b>Bold</b>"
```

See also: [`escape_attr`](@ref), [`SafeString`](@ref), [`@esc_str`](@ref)
"""
function escape_html(io::IO, value::AbstractString)
    for c in value
        if c == '&'
            print(io, "&amp;")
        elseif c == '<'
            print(io, "&lt;")
        elseif c == '>'
            print(io, "&gt;")
        else
            print(io, c)
        end
    end
end

# Fast path for the string types that actually show up in templates. Rather
# than writing one character at a time we scan the code units and write the
# runs between escapable characters in one go. Scanning bytes is safe because
# the characters we escape are all ASCII and ASCII bytes never appear inside a
# multi-byte UTF-8 sequence.
function escape_html(io::IO, value::Union{String,SubString{String}})
    n = ncodeunits(value)
    start = 1
    i = 1
    @inbounds while i <= n
        b = codeunit(value, i)
        if b == UInt8('&') || b == UInt8('<') || b == UInt8('>')
            i > start && _write_range(io, value, start, i - 1)
            if b == UInt8('&')
                write(io, "&amp;")
            elseif b == UInt8('<')
                write(io, "&lt;")
            else
                write(io, "&gt;")
            end
            start = i + 1
        end
        i += 1
    end
    start <= n && _write_range(io, value, start, n)
    return nothing
end

escape_html(io::IO, ss::SafeString) = print(io, ss.str)
# Numbers cannot produce any character that needs escaping, so skip both the
# scan and the `string` allocation that the generic fallback would make.
escape_html(io::IO, value::Union{Integer,AbstractFloat}) = (print(io, value); nothing)
escape_html(io::IO, value::NativeInteger) = _write_integer(io, value)
# A single character needs at most one substitution, and checking it directly
# avoids the `string` allocation the generic fallback would make.
function escape_html(io::IO, value::Char)
    if value == '&'
        print(io, "&amp;")
    elseif value == '<'
        print(io, "&lt;")
    elseif value == '>'
        print(io, "&gt;")
    else
        print(io, value)
    end
    return nothing
end
escape_html(io::IO, other) = (print(EscapeStream{false}(io), other); nothing)
escape_html(io::IO, value, revise) = escape_html(io, value)

# Write `value[from:to]` (code unit indices) without materialising a substring.
@inline function _write_range(
    io::IO,
    value::Union{String,SubString{String}},
    from::Int,
    to::Int,
)
    GC.@preserve value unsafe_write(io, pointer(value, from), UInt(to - from + 1))
    return nothing
end

"""
    escape_attr(io::IO, value)

Write HTML attribute-escaped content to an IO stream.

This function escapes characters that have special meaning in HTML attributes,
providing more comprehensive escaping than [`escape_html`](@ref). It is automatically
called for all attribute values unless wrapped in [`SafeString`](@ref).

# Escaped characters
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`
- `'` → `&#39;`

# Arguments
- `io::IO`: The output stream to write to
- `value`: The attribute value to escape (converted to string if not already)

!!! note
    This function provides defense-in-depth but cannot prevent all attribute-based
    attacks. Always validate URLs and other sensitive attribute values at the
    application level.

See also: [`escape_html`](@ref), [`SafeString`](@ref)
"""
function escape_attr(io::IO, value::AbstractString)
    for c in value
        if c == '&'
            print(io, "&amp;")
        elseif c == '<'
            print(io, "&lt;")
        elseif c == '>'
            print(io, "&gt;")
        elseif c == '"'
            print(io, "&quot;")
        elseif c == '\''
            print(io, "&#39;")
        else
            print(io, c)
        end
    end
end

# See `escape_html` above for why the code unit scan is safe.
function escape_attr(io::IO, value::Union{String,SubString{String}})
    n = ncodeunits(value)
    start = 1
    i = 1
    @inbounds while i <= n
        b = codeunit(value, i)
        if b == UInt8('&') ||
           b == UInt8('<') ||
           b == UInt8('>') ||
           b == UInt8('"') ||
           b == UInt8('\'')
            i > start && _write_range(io, value, start, i - 1)
            if b == UInt8('&')
                write(io, "&amp;")
            elseif b == UInt8('<')
                write(io, "&lt;")
            elseif b == UInt8('>')
                write(io, "&gt;")
            elseif b == UInt8('"')
                write(io, "&quot;")
            else
                write(io, "&#39;")
            end
            start = i + 1
        end
        i += 1
    end
    start <= n && _write_range(io, value, start, n)
    return nothing
end

escape_attr(io::IO, ss::SafeString) = print(io, ss.str)
escape_attr(io::IO, value::Union{Integer,AbstractFloat}) = (print(io, value); nothing)
escape_attr(io::IO, value::NativeInteger) = _write_integer(io, value)
# See `escape_html(::IO, ::Char)` above.
function escape_attr(io::IO, value::Char)
    if value == '&'
        print(io, "&amp;")
    elseif value == '<'
        print(io, "&lt;")
    elseif value == '>'
        print(io, "&gt;")
    elseif value == '"'
        print(io, "&quot;")
    elseif value == '\''
        print(io, "&#39;")
    else
        print(io, value)
    end
    return nothing
end
escape_attr(io::IO, other) = (print(EscapeStream{true}(io), other); nothing)

# Values that are neither strings, numbers nor characters used to be turned
# into a `String` and then scanned, allocating a throwaway copy of every
# interpolated `Symbol`, `Date`, `UUID` and so on. Printing through this
# wrapper escapes the bytes as `print` produces them, with no copy in between.
# The type parameter selects attribute escaping, and is resolved at compile
# time.
#
# It deliberately does not forward `IOContext` properties. `string(value)`
# renders into a bare buffer, so a value whose `show` consults the stream --
# checking `:compact`, say -- must keep seeing the defaults it saw before.
struct EscapeStream{attribute,I<:IO} <: IO
    io::I
end

EscapeStream{attribute}(io::I) where {attribute,I<:IO} = EscapeStream{attribute,I}(io)

@inline function Base.write(stream::EscapeStream{attribute}, byte::UInt8) where {attribute}
    io = stream.io
    if byte == UInt8('&')
        write(io, "&amp;")
    elseif byte == UInt8('<')
        write(io, "&lt;")
    elseif byte == UInt8('>')
        write(io, "&gt;")
    elseif attribute && byte == UInt8('"')
        write(io, "&quot;")
    elseif attribute && byte == UInt8('\'')
        write(io, "&#39;")
    else
        write(io, byte)
    end
    return 1
end

# Runs between escapable bytes are forwarded whole. Scanning bytes is safe for
# the same reason it is in the escapers above: every character replaced here is
# ASCII, and ASCII bytes never occur inside a multi-byte UTF-8 sequence.
function Base.unsafe_write(
    stream::EscapeStream{attribute},
    ptr::Ptr{UInt8},
    n::UInt,
) where {attribute}
    io = stream.io
    start = 1
    index = 1
    while index <= n
        byte = unsafe_load(ptr, index)
        if byte == UInt8('&') ||
           byte == UInt8('<') ||
           byte == UInt8('>') ||
           (attribute && (byte == UInt8('"') || byte == UInt8('\'')))
            index > start && unsafe_write(io, ptr + start - 1, UInt(index - start))
            write(stream, byte)
            start = index + 1
        end
        index += 1
    end
    start <= n && unsafe_write(io, ptr + start - 1, UInt(n - start + 1))
    return Int(n)
end
