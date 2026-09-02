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

# `print(io, ::Int)` builds a `String` first: 85% of a 200 row table's
# allocations. These are written digit by digit into a stack buffer instead.
#
# `Bool` is excluded because it prints as `true`/`false`; the 128-bit types and
# `BigInt` because the loop is slower than `print` for them.
const NativeInteger = Union{Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64}

function _write_integer(io::IO, n::NativeInteger)
    negative = n < 0
    # Negating `typemin` wraps back to itself, and unsigned that is the
    # magnitude wanted, so no special case is needed.
    u = negative ? unsigned(-n) : unsigned(n)
    # 20 digits holds `typemax(UInt64)`. Never escapes, so it stays on the stack.
    buffer = Ref{NTuple{24, UInt8}}()
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

# `show` hands `Base.Ryu` a fresh `StringVector` per call, so a float costs
# three allocations and 432 bytes. Only that buffer is replaced; `Ryu` still
# produces the digits. It has to be a real `Vector{UInt8}`, so it is kept in
# task-local storage: a render that yields mid-write resumes to find its own
# digits there, since anything that ran in between had a buffer of its own.
#
# `BigFloat` is excluded because it prints through MPFR rather than Ryu.
const NativeFloat = Union{Float16, Float32, Float64}

# `Ryu`'s own figure, not one derived from how long a `Float64` can get:
# `writeshortest` writes without bounds checking, so being wrong here would
# overflow the heap rather than truncate a number.
const FLOAT_DIGITS = Base.Ryu.neededdigits(Float64)

# Task-local storage is shared with everything else in the task, so the key is
# namespaced.
const FLOAT_SCRATCH_KEY = :HypertextTemplates_float_scratch

function _write_float(io::IO, x::NativeFloat)
    scratch = get!(
        () -> Vector{UInt8}(undef, FLOAT_DIGITS),
        task_local_storage(),
        FLOAT_SCRATCH_KEY,
    )::Vector{UInt8}
    # The arguments `Base.show(::IO, ::AbstractFloat)` uses when reached through
    # `print`. The suite checks the result against `print` over the whole bit
    # space of `Float16` and a wide sample of the other two, so a Julia version
    # that formats differently is caught rather than silently rendered.
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

# Scanning bytes is safe because every character replaced is ASCII, and ASCII
# bytes never appear inside a multi-byte UTF-8 sequence. Every other string
# goes through `EscapeStream` at the bottom of this file, alongside the values
# that are not strings at all.
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
function escape_html(io::IO, value::Union{String, SubString{String}})
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
escape_html(io::IO, value::Union{Integer, AbstractFloat}) = (print(io, value); nothing)
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

# Entities are not decoded in a `script` or a `style`, so escaping the body
# changes the program. What cannot appear there is what takes the parser out of
# the element: that element's own end tag, and in a `script` also `<!--`, which
# enters script data escaped where a following `<script` reaches double escaped
# and `</script>` stops closing the element (HTML §13.2.5). Neutralising the
# comment keeps both states out of reach, so a bare `<script` needs nothing.
#
# A bare `</` is not an exit. The tokenizer reads the name after it and emits
# the characters again unless they name the open element (§13.2.5.13-14,
# §13.2.5.16-17), so neutralising every `</` would corrupt markup nested in a
# `text/template` block for no gain.
#
# A backslash after the `<` neutralises both. `<\/` is how JavaScript spells
# `</` inside a string, and `<` is not valid CSS in any spelling.
const RAW_TEXT_ESCAPE = "<\\"
# The bytes each sequence expects after its `<`. An end tag is the solidus then
# the element's own name, whose letters are matched in either case.
const RAW_TEXT_SOLIDUS = UInt8('/')
const RAW_TEXT_COMMENT = map(UInt8, ('!', '-', '-'))
const RAW_TEXT_SCRIPT = map(UInt8, ('s', 'c', 'r', 'i', 'p', 't'))
const RAW_TEXT_STYLE = map(UInt8, ('s', 't', 'y', 'l', 'e'))

_raw_text_name(::Val{true}) = RAW_TEXT_SCRIPT
_raw_text_name(::Val{false}) = RAW_TEXT_STYLE

@inline _ascii_lowercase(byte::UInt8) = byte | 0x20

# A stream this package puts in front of the destination a render writes to.
# Writing is its own; everything else belongs to the destination behind it, so
# a `show` method handed one of these gets the answers it would have got from
# the destination itself rather than `displaysize`'s terminal default.
abstract type WrappedIO <: IO end

Base.get(io::WrappedIO, key, default) = get(io.io, key, default)
Base.getindex(io::WrappedIO, key) = getindex(io.io, key)
Base.haskey(io::WrappedIO, key) = haskey(io.io, key)

# `Base`'s multi-argument `print` locks the stream, and its fallback for an
# unknown `IO` does nothing. Forwarding keeps a shared file or socket locked
# for the whole call.
Base.lock(io::WrappedIO) = lock(io.io)
Base.unlock(io::WrappedIO) = unlock(io.io)
Base.flush(io::WrappedIO) = flush(io.io)

Base.displaysize(io::WrappedIO) = displaysize(io.io)
Base.isopen(io::WrappedIO) = isopen(io.io)
Base.iswritable(io::WrappedIO) = iswritable(io.io)
Base.isreadable(io::WrappedIO) = isreadable(io.io)

# One element's raw text arrives in pieces, each literal and interpolated value
# written by a call of its own, so a per-call scan misses a sequence divided
# between two: `@script $("x<") $("/script><img src=x onerror=1>")` closed the
# element. All the children of one element therefore go through one of these,
# which holds back bytes that begin a sequence until one arrives that completes
# it or rules it out. Every sequence starts with `<` and they differ at the
# next byte, so what is held is always a `<` and one sequence's prefix.
# `_flush_raw_text` writes out whatever is still held before the end tag.
mutable struct RawTextWriter{script, I <: IO} <: WrappedIO
    io::I
    # Packed one byte per byte from the low end, so holding costs no
    # allocation. `</script` is the longest sequence and its eighth byte
    # completes it rather than being held, so at most seven are packed here.
    held::UInt64
    count::Int
end

RawTextWriter{script}(io::I) where {script, I <: IO} =
    RawTextWriter{script, I}(io, zero(UInt64), 0)

@inline _held_byte(held::UInt64, index::Int) = (held >> (8 * (index - 1))) % UInt8

# Everything a raw text element's children write goes through one writer, so
# that a sequence divided between two of them is still seen whole. The writer
# is built once per rendered element and emptied before the end tag follows.
@inline function _raw_text_scope(f::F, io::IO, ::Val{script}) where {F, script}
    writer = RawTextWriter{script}(io)
    f(writer)
    _flush_raw_text(writer)
    return nothing
end

# An element written inside a raw text one starts markup again, so this stands
# in for the writer while it renders its children: every byte still reaches the
# writer, but a write dispatches as markup and so is escaped.
#
# `<script type="text/template">` is why. The page reads such a block back out
# and parses it as HTML, decoding entities, so a value that reached it from a
# user has to be escaped for that parse.
struct MarkupWriter{I <: IO} <: WrappedIO
    io::I
end

Base.unsafe_write(markup::MarkupWriter, source::Ptr{UInt8}, n::UInt) =
    unsafe_write(markup.io, source, n)
Base.write(markup::MarkupWriter, byte::UInt8) = write(markup.io, byte)

# The stream an element that is not raw text hands its children. Only a raw
# text writer has anything to wrap, and the type settles which method runs, so
# the ordinary path builds nothing.
@inline _markup_scope(f::F, writer::RawTextWriter) where {F} = f(MarkupWriter(writer))
@inline _markup_scope(f::F, io::IO) where {F} = f(io)

# What a byte does to the `count` bytes already held, which are a `<` and the
# first `count - 1` bytes of one of the sequences. Returns the number of bytes
# held afterwards, zero for a sequence the byte completes, and a negative
# number for one it breaks.
#
# `second` is the held byte after the `<`, which is what says which sequence is
# being matched. It is only read once there is one, so what a caller passes for
# the first byte after a `<` is immaterial.
@inline function _raw_text_step(
        ::Val{script},
        second::UInt8,
        count::Int,
        byte::UInt8,
    ) where {script}
    if count == 1
        byte == RAW_TEXT_SOLIDUS && return 2
        script && byte == RAW_TEXT_COMMENT[1] && return 2
        return -1
    end
    if second == RAW_TEXT_SOLIDUS
        # Only the tag name has letters in it, so folding case is right here.
        # It would not be in the comment below, where a byte folded onto `-`
        # would let a carriage return open one.
        name = _raw_text_name(Val(script))
        _ascii_lowercase(byte) == name[count - 1] || return -1
        return count - 1 == length(name) ? 0 : count + 1
    end
    byte == RAW_TEXT_COMMENT[count] || return -1
    return count == length(RAW_TEXT_COMMENT) ? 0 : count + 1
end

# Writes a completed sequence with the backslash in it, the bytes otherwise as
# they were written: a `<SCRIPT` neutralises to `<\SCRIPT`.
function _write_neutralised(io::IO, held::UInt64, count::Int, byte::UInt8)
    print(io, RAW_TEXT_ESCAPE)
    for index in 2:count
        write(io, _held_byte(held, index))
    end
    write(io, byte)
    return nothing
end

function _flush_raw_text(writer::RawTextWriter)
    count = writer.count
    count == 0 && return nothing
    io = writer.io
    for index in 1:count
        write(io, _held_byte(writer.held, index))
    end
    writer.held = zero(UInt64)
    writer.count = 0
    return nothing
end

@inline function _hold_raw_text(writer::RawTextWriter, byte::UInt8)
    writer.held = UInt64(byte)
    writer.count = 1
    return nothing
end

# Nothing held past the `<` can itself begin a sequence, so a byte that breaks
# one only has to be reconsidered on its own.
@inline function _restart_raw_text(writer::RawTextWriter, byte::UInt8)
    _flush_raw_text(writer)
    byte == UInt8('<') ? _hold_raw_text(writer, byte) : write(writer.io, byte)
    return nothing
end

function _raw_text_byte(writer::RawTextWriter{script}, byte::UInt8) where {script}
    count = writer.count
    if count == 0
        byte == UInt8('<') ? _hold_raw_text(writer, byte) : write(writer.io, byte)
        return nothing
    end
    step = _raw_text_step(Val(script), _held_byte(writer.held, 2), count, byte)
    if step > 0
        writer.held |= UInt64(byte) << (8 * count)
        writer.count = step
    elseif step == 0
        _write_neutralised(writer.io, writer.held, count, byte)
        writer.held = zero(UInt64)
        writer.count = 0
    else
        _restart_raw_text(writer, byte)
    end
    return nothing
end

# How long the sequence starting at the `<` at `index` is, zero if the bytes
# there begin none, and a negative number if they begin one that the bytes in
# hand do not finish.
@inline function _raw_text_sequence(
        ::Val{script},
        source::Ptr{UInt8},
        index::Int,
        n::Int,
    ) where {script}
    second = index < n ? unsafe_load(source, index + 1) : 0x00
    count = 1
    while true
        position = index + count
        position > n && return -1
        step = _raw_text_step(Val(script), second, count, unsafe_load(source, position))
        step < 0 && return 0
        step == 0 && return count + 1
        count = step
    end
    return
end

function _write_raw_text(
        writer::RawTextWriter{script},
        source::Ptr{UInt8},
        n::Int,
    ) where {script}
    io = writer.io
    index = 1
    # Whatever the last call held back is resolved against the bytes this one
    # starts with, a byte at a time until the sequence is settled either way.
    # A held sequence is at most seven bytes long, so this is not a second scan.
    while writer.count > 0 && index <= n
        _raw_text_byte(writer, unsafe_load(source, index))
        index += 1
    end
    from = index
    while index <= n
        offset = _first_escapable(source + index - 1, n - index + 1, Val(:rawtext))
        # Nothing left that could take the parser out of the element.
        offset == 0 && break
        index += offset - 1
        matched = _raw_text_sequence(Val(script), source, index, n)
        if matched == 0
            # An ordinary `<`, which stays in the run being written.
            index += 1
            continue
        end
        index > from && unsafe_write(io, source + from - 1, UInt(index - from))
        if matched < 0
            # The call ends inside a sequence the next one may complete.
            _hold_raw_text_run(writer, source, index, n)
            return nothing
        end
        print(io, RAW_TEXT_ESCAPE)
        unsafe_write(io, source + index, UInt(matched - 1))
        index += matched
        from = index
    end
    from <= n && unsafe_write(io, source + from - 1, UInt(n - from + 1))
    return nothing
end

function _hold_raw_text_run(
        writer::RawTextWriter,
        source::Ptr{UInt8},
        index::Int,
        n::Int,
    )
    held = zero(UInt64)
    count = 0
    while index + count <= n
        held |= UInt64(unsafe_load(source, index + count)) << (8 * count)
        count += 1
    end
    writer.held = held
    writer.count = count
    return nothing
end

function Base.unsafe_write(writer::RawTextWriter, source::Ptr{UInt8}, n::UInt)
    n > 0 && _write_raw_text(writer, source, Int(n))
    return Int(n)
end

function Base.write(writer::RawTextWriter, byte::UInt8)
    _raw_text_byte(writer, byte)
    return 1
end

# A value written into a raw text element is handed to the writer as it prints,
# with no copy in between, and the writer is what neutralises the end tag.
escape_raw_text(io::IO, value) = (print(io, value); nothing)
# `print(io, ::Integer)` builds a `String` first; these two do not.
escape_raw_text(io::IO, value::NativeInteger) = _write_integer(io, value)
escape_raw_text(io::IO, value::NativeFloat) = _write_float(io, value)
# Nothing escapes a `SafeString`, but it still goes through the writer rather
# than past it, so the sequences that end the element are neutralised in it as
# in any other child. Such a value in a `script` is usually JSON built from a
# user's data, where a `</script` would end the element and leave the rest as
# markup; `<\/` is a valid JSON string escape, so the value still parses.
#
# `<\!--` is not, so a JSON value carrying a comment opener will not parse
# back. No spelling both contains the sequence and survives, and containment
# wins over round-tripping.
escape_raw_text(io::IO, ss::SafeString) = (print(io, ss.str); nothing)
# Takes the source location the same way `escape_html` does, so that the two
# are interchangeable in what `@text` expands to.
escape_raw_text(io::IO, value, revise) = escape_raw_text(io, value)

# The element a write lands in decides whether it is escaped, and the stream is
# how that reaches the write: a literal, an interpolated value and a slot's
# content all belong to the body of whichever element's writer is the stream.
# Dispatch settles it where `io` is bound, so the render itself asks nothing.
_write_content(io::RawTextWriter, value, revise) = escape_raw_text(io, value, revise)
_write_content(io::IO, value, revise) = escape_html(io, value, revise)

# The two forms a literal was expanded into, chosen the same way. Both are
# constants, so the branch folds away and the unused one is dropped.
_literal_text(::RawTextWriter, raw, _) = raw
_literal_text(::IO, _, escaped) = escaped

# The escaped form is assembled in a fixed stack buffer and handed over a block
# at a time, so a character costs a couple of stores rather than a call into
# the stream. Clean stretches are written straight from the source, so text
# needing no escaping costs one scan and one write and never touches the
# buffer.
const ESCAPE_BLOCK = 256

@inline function _escapable(b::UInt8, ::Val{attribute}) where {attribute}
    return b == UInt8('&') ||
        b == UInt8('<') ||
        b == UInt8('>') ||
        (attribute && (b == UInt8('"') || b == UInt8('\'')))
end

# Raw text is a third mode for the scan below. Nothing in it is escaped, so the
# only byte the writer has to stop on is the `<` that could end the element.
@inline _escapable(b::UInt8, ::Val{:rawtext}) = b == UInt8('<')

@inline function _store_entity(
        out::Ptr{UInt8},
        filled::Int,
        bytes::NTuple{N, UInt8},
    ) where {N}
    for index in 1:N
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

# Shorter clean stretches are copied into the block; longer ones are worth a
# write of their own, since a call into the stream costs a couple of dozen
# stores.
const ESCAPE_CLEAN_RUN = 32

function _escape_blocked(
        io::IO,
        source::Ptr{UInt8},
        from::Int,
        to::Int,
        ::Val{attribute},
    ) where {attribute}
    # Between two block checks the buffer takes one entity and then a clean
    # run, so it carries headroom for both.
    scratch = Ref{NTuple{ESCAPE_BLOCK + ESCAPE_CLEAN_RUN + 8, UInt8}}()
    GC.@preserve scratch begin
        out = Base.unsafe_convert(Ptr{UInt8}, scratch)
        filled = 0
        i = from
        while i <= to
            while i <= to
                byte = unsafe_load(source, i)
                _escapable(byte, Val(attribute)) || break
                filled = _store_escaped(out, filled, byte, Val(attribute))
                i += 1
                if filled >= ESCAPE_BLOCK
                    unsafe_write(io, out, UInt(filled))
                    filled = 0
                end
            end
            clean = 0
            while clean < ESCAPE_CLEAN_RUN && i <= to
                byte = unsafe_load(source, i)
                _escapable(byte, Val(attribute)) && break
                clean += 1
                filled += 1
                unsafe_store!(out, byte, filled)
                i += 1
            end
            if filled >= ESCAPE_BLOCK
                unsafe_write(io, out, UInt(filled))
                filled = 0
            end
            if clean == ESCAPE_CLEAN_RUN && i <= to
                offset = _first_escapable(source + i - 1, to - i + 1, Val(attribute))
                stretch = offset == 0 ? to - i + 1 : offset - 1
                if stretch > 0
                    # The block goes first, or the two writes come out swapped.
                    filled > 0 && unsafe_write(io, out, UInt(filled))
                    filled = 0
                    unsafe_write(io, source + i - 1, UInt(stretch))
                    i += stretch
                end
            end
        end
        filled > 0 && unsafe_write(io, out, UInt(filled))
    end
    return nothing
end

# Locating the first byte needing an entity is the whole cost of escaping text
# that needs none, which is most of what a template writes, so it is done eight
# bytes at a time. `(v - ones) & ~v & highs` leaves a high bit set in each zero
# byte of `v`, so xor-ing with a repeated target byte turns "is this byte
# present" into "is any byte zero".
const _ONE_PER_BYTE = 0x0101010101010101
const _HIGH_PER_BYTE = 0x8080808080808080

@inline _zero_byte(word::UInt64) = (word - _ONE_PER_BYTE) & ~word & _HIGH_PER_BYTE
@inline _byte_present(word::UInt64, b::UInt8) = _zero_byte(word ⊻ (_ONE_PER_BYTE * b))

@inline function _escapable_present(word::UInt64, ::Val{attribute}) where {attribute}
    found =
        _byte_present(word, UInt8('&')) | _byte_present(word, UInt8('<')) |
        _byte_present(word, UInt8('>'))
    if attribute
        found |= _byte_present(word, UInt8('"')) | _byte_present(word, UInt8('\''))
    end
    return found
end

@inline _escapable_present(word::UInt64, ::Val{:rawtext}) =
    _byte_present(word, UInt8('<'))

# Below this the word loop's alignment prologue costs more than it saves.
const _WORD_SCAN_MINIMUM = 16

function _first_escapable(source::Ptr{UInt8}, n::Int, ::Val{attribute}) where {attribute}
    i = 1
    if n >= _WORD_SCAN_MINIMUM
        # Advance to an eight-byte boundary first, so the loop below never
        # issues an unaligned load.
        while i <= n && (UInt(source + i - 1) & 0x07) != 0
            _escapable(unsafe_load(source, i), Val(attribute)) && return i
            i += 1
        end
        while i + 7 <= n
            if _escapable_present(
                    unsafe_load(Ptr{UInt64}(source + i - 1)),
                    Val(attribute),
                ) != 0
                # Some byte in this word matches; find which.
                for offset in 0:7
                    _escapable(unsafe_load(source, i + offset), Val(attribute)) &&
                        return i + offset
                end
            end
            i += 8
        end
    end
    while i <= n
        _escapable(unsafe_load(source, i), Val(attribute)) && return i
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
    first = _first_escapable(source, n, Val(attribute))
    # Nothing to escape: hand the whole run over in one write.
    if first == 0
        unsafe_write(io, source, UInt(n))
        return nothing
    end
    first > 1 && unsafe_write(io, source, UInt(first - 1))
    _escape_blocked(io, source, first, n, Val(attribute))
    return nothing
end

function _escape_scan(io::IO, value::Union{String, SubString{String}}, escaping::Val)
    n = ncodeunits(value)
    n == 0 && return nothing
    GC.@preserve value _escape_bytes(io, pointer(value), n, escaping)
    return nothing
end

# See `escape_html` above for why the code unit scan is safe and where the
# strings this does not match are escaped.
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
function escape_attr(io::IO, value::Union{String, SubString{String}})
    _escape_scan(io, value, Val(true))
    return nothing
end

escape_attr(io::IO, ss::SafeString) = print(io, ss.str)
escape_attr(io::IO, value::Union{Integer, AbstractFloat}) = (print(io, value); nothing)
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

# Escapes the bytes of a value that is neither a string, a number nor a
# character as `print` produces them, with no `String` copy in between. The
# type parameter selects attribute escaping at compile time.
#
# A `WrappedIO` like the raw text writers, so a `show` method reached through
# it is answered by the destination. Otherwise the same value would lay itself
# out to a default width in a `p` and the caller's width in a `script`.
struct EscapeStream{attribute, I <: IO} <: WrappedIO
    io::I
end

EscapeStream{attribute}(io::I) where {attribute, I <: IO} = EscapeStream{attribute, I}(io)

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
