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
escape_html(io::IO, ss::SafeString) = print(io, ss.str)
escape_html(io::IO, other) = escape_html(io, string(other))
escape_html(io::IO, value, revise) = escape_html(io, value)

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
escape_attr(io::IO, ss::SafeString) = print(io, ss.str)
escape_attr(io::IO, other) = escape_attr(io, string(other))
