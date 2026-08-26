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

# `print(io, ::Float64)` has the same problem an integer had, one step removed:
# `show` hands `Base.Ryu` a fresh `StringVector` for the digits on every call,
# so a float costs three allocations and 432 bytes before a byte reaches the
# page. A table of measurements or prices pays that per cell.
#
# The digits themselves are `Base.Ryu`'s to produce -- reimplementing shortest
# round-trip formatting to save an allocation would be a poor trade -- so what
# is replaced is only the buffer it writes them into. `writeshortest` insists
# on a real `Vector{UInt8}`, which cannot live on the stack the way the
# integer writer's does, so it is kept by the task doing the rendering and
# reused for every float that task writes.
#
# Belonging to the task is what makes it safe to write straight out of: a
# render that yields mid-write -- which one to a socket does -- resumes to
# find its own digits still there, because whatever ran in between was another
# task with a buffer of its own.
#
# `Bool` is an `Integer` and never reaches here. `BigFloat` is excluded because
# it prints through MPFR rather than Ryu.
const NativeFloat = Union{Float16,Float32,Float64}

# The size is `Base.Ryu`'s own figure rather than one derived from how long a
# shortest-round-trip `Float64` can get -- which is 24 characters, sign and
# exponent included. `writeshortest` writes without checking, so being wrong
# about that would be a heap overflow rather than a truncated number, and the
# only party that can promise how much room it needs is the one doing the
# writing.
const FLOAT_DIGITS = Base.Ryu.neededdigits(Float64)

# The task's storage is shared with everything else running in it, so the key
# is namespaced rather than something a package could plausibly pick too.
const FLOAT_SCRATCH_KEY = :HypertextTemplates_float_scratch

function _write_float(io::IO, x::NativeFloat)
    scratch = get!(
        () -> Vector{UInt8}(undef, FLOAT_DIGITS),
        task_local_storage(),
        FLOAT_SCRATCH_KEY,
    )::Vector{UInt8}
    # The arguments are the ones `Base.show(::IO, ::AbstractFloat)` uses when
    # reached through `print`: shortest form, no plus or space, a `.` before a
    # bare exponent, full precision, `e` for the exponent -- `print` passes
    # `fromprint`, so a `Float32` gets `e` and not `f` -- and neither the type
    # annotation nor `:compact`, neither of which a rendered page ever wants.
    # The suite checks the result against `print` across the whole bit space
    # of `Float16` and a wide random sample of `Float32` and `Float64`, so a
    # version that formats differently is caught rather than silently
    # rendered.
    stop = Base.Ryu.writeshortest(
        scratch,
        1,
        x,
        false,
        false,
        true,
        -1,
        UInt8('e'),
        false,
        UInt8('.'),
        false,
        false,
    )
    GC.@preserve scratch unsafe_write(io, pointer(scratch), UInt(stop - 1))
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

# Fast path for the string types that actually show up in templates: see
# `_escape_scan` below. Scanning bytes is safe because every character replaced
# is ASCII, and ASCII bytes never appear inside a multi-byte UTF-8 sequence.
function escape_html(io::IO, value::Union{String,SubString{String}})
    _escape_scan(io, value, Val(false))
    return nothing
end

escape_html(io::IO, ss::SafeString) = print(io, ss.str)

# Concatenating a `SafeString` into a longer string yields ordinary text, and
# the result is then escaped as a whole. `@text` writes the pieces of such a
# string separately rather than joining them, so it flattens each piece the
# same way to keep the outcome identical.
_as_text(value::SafeString) = value.str
_as_text(value) = value
# Numbers cannot produce any character that needs escaping, so skip both the
# scan and the `string` allocation that the generic fallback would make.
escape_html(io::IO, value::Union{Integer,AbstractFloat}) = (print(io, value); nothing)
escape_html(io::IO, value::NativeInteger) = _write_integer(io, value)
escape_html(io::IO, value::NativeFloat) = _write_float(io, value)
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

# Escaping used to write each entity with its own `write(io, "&lt;")`, which on
# text that needs a lot of escaping meant a write per character. Instead the
# escaped form is assembled in a fixed stack buffer and handed over a block at
# a time, so the cost per character is a couple of stores rather than a call
# into the stream.
#
# The clean prefix is still written straight from the source string, so text
# that needs no escaping at all -- the common case -- costs one scan and one
# write and never touches the scratch buffer.
const ESCAPE_BLOCK = 256

@inline function _escapable(b::UInt8, attribute::Bool)
    return b == UInt8('&') ||
           b == UInt8('<') ||
           b == UInt8('>') ||
           (attribute && (b == UInt8('"') || b == UInt8('\'')))
end

@inline function _store_entity(
    out::Ptr{UInt8},
    filled::Int,
    bytes::NTuple{N,UInt8},
) where {N}
    for index = 1:N
        unsafe_store!(out, bytes[index], filled + index)
    end
    return filled + N
end

@inline function _store_escaped(
    out::Ptr{UInt8},
    filled::Int,
    b::UInt8,
    ::Val{attribute},
) where {attribute}
    if b == UInt8('&')
        return _store_entity(out, filled, map(UInt8, ('&', 'a', 'm', 'p', ';')))
    elseif b == UInt8('<')
        return _store_entity(out, filled, map(UInt8, ('&', 'l', 't', ';')))
    elseif b == UInt8('>')
        return _store_entity(out, filled, map(UInt8, ('&', 'g', 't', ';')))
    elseif attribute && b == UInt8('"')
        return _store_entity(out, filled, map(UInt8, ('&', 'q', 'u', 'o', 't', ';')))
    elseif attribute && b == UInt8('\'')
        return _store_entity(out, filled, map(UInt8, ('&', '#', '3', '9', ';')))
    else
        unsafe_store!(out, b, filled + 1)
        return filled + 1
    end
end

function _escape_blocked(
    io::IO,
    source::Ptr{UInt8},
    from::Int,
    to::Int,
    ::Val{attribute},
) where {attribute}
    # The longest entity is six bytes, so the block can overshoot by five
    # before the check below; the headroom covers it.
    scratch = Ref{NTuple{ESCAPE_BLOCK + 8,UInt8}}()
    GC.@preserve scratch begin
        out = Base.unsafe_convert(Ptr{UInt8}, scratch)
        filled = 0
        for i = from:to
            filled = _store_escaped(out, filled, unsafe_load(source, i), Val(attribute))
            if filled >= ESCAPE_BLOCK
                unsafe_write(io, out, UInt(filled))
                filled = 0
            end
        end
        filled > 0 && unsafe_write(io, out, UInt(filled))
    end
    return nothing
end

# Locating the first byte that needs an entity is the whole cost of escaping
# text that turns out to need none, which is most of what a template writes. It
# is done eight bytes at a time: a word is read, and a handful of arithmetic
# operations say whether any byte in it is one of the ones being looked for.
#
# `(v - ones) & ~v & highs` leaves a high bit set in each zero byte of `v`, so
# xor-ing the word with a repeated target byte turns "is this byte present"
# into "is any byte zero".
const _ONE_PER_BYTE = 0x0101010101010101
const _HIGH_PER_BYTE = 0x8080808080808080

@inline _zero_byte(word::UInt64) = (word - _ONE_PER_BYTE) & ~word & _HIGH_PER_BYTE
@inline _byte_present(word::UInt64, b::UInt8) = _zero_byte(word ⊻ (_ONE_PER_BYTE * b))

@inline function _escapable_present(word::UInt64, attribute::Bool)
    found =
        _byte_present(word, UInt8('&')) | _byte_present(word, UInt8('<')) |
        _byte_present(word, UInt8('>'))
    if attribute
        found |= _byte_present(word, UInt8('"')) | _byte_present(word, UInt8('\''))
    end
    return found
end

# Below this the word loop's alignment prologue costs more than it saves.
const _WORD_SCAN_MINIMUM = 16

function _first_escapable(source::Ptr{UInt8}, n::Int, attribute::Bool)
    i = 1
    if n >= _WORD_SCAN_MINIMUM
        # Advance to an eight-byte boundary first, so the loop below never
        # issues an unaligned load.
        while i <= n && (UInt(source + i - 1) & 0x7) != 0
            _escapable(unsafe_load(source, i), attribute) && return i
            i += 1
        end
        while i + 7 <= n
            if _escapable_present(unsafe_load(Ptr{UInt64}(source + i - 1)), attribute) != 0
                # Some byte in this word matches; find which.
                for offset = 0:7
                    _escapable(unsafe_load(source, i + offset), attribute) &&
                        return i + offset
                end
            end
            i += 8
        end
    end
    while i <= n
        _escapable(unsafe_load(source, i), attribute) && return i
        i += 1
    end
    return 0
end

# Works from a pointer so that the string escapers and the wrapper used for
# arbitrary values share one implementation; the wrapper only ever has a
# pointer to hand.
function _escape_bytes(
    io::IO,
    source::Ptr{UInt8},
    n::Int,
    ::Val{attribute},
) where {attribute}
    n <= 0 && return nothing
    first = _first_escapable(source, n, attribute)
    # Nothing to escape: hand the whole run over in one write.
    if first == 0
        unsafe_write(io, source, UInt(n))
        return nothing
    end
    first > 1 && unsafe_write(io, source, UInt(first - 1))
    _escape_blocked(io, source, first, n, Val(attribute))
    return nothing
end

function _escape_scan(io::IO, value::Union{String,SubString{String}}, escaping::Val)
    n = ncodeunits(value)
    n == 0 && return nothing
    GC.@preserve value _escape_bytes(io, pointer(value), n, escaping)
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
    _escape_scan(io, value, Val(true))
    return nothing
end

escape_attr(io::IO, ss::SafeString) = print(io, ss.str)
escape_attr(io::IO, value::Union{Integer,AbstractFloat}) = (print(io, value); nothing)
escape_attr(io::IO, value::NativeInteger) = _write_integer(io, value)
escape_attr(io::IO, value::NativeFloat) = _write_float(io, value)
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
    _escape_bytes(stream.io, ptr, Int(n), Val(attribute))
    return Int(n)
end
