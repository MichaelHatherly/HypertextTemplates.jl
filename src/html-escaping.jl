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
escape_html(io::IO, other) = escape_html(io, string(other))
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
escape_attr(io::IO, other) = escape_attr(io, string(other))
