"""
    SafeString(str::String)

A string wrapper that bypasses automatic HTML escaping.

By default, all string content is HTML-escaped to prevent XSS attacks. `SafeString`
marks content as pre-escaped or trusted HTML that should be rendered as-is.

!!! warning "Security Risk"
    Only use `SafeString` with content you trust completely. Never wrap user input
    directly with `SafeString` without proper sanitization. This can lead to XSS
    vulnerabilities.

# Arguments
- `str::String`: The HTML string to mark as safe

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> # Normal strings are escaped
       @render @div "<b>Bold</b>"
"<div>&lt;b&gt;Bold&lt;/b&gt;</div>"

julia> # SafeString content is not escaped
       @render @div SafeString("<b>Bold</b>")
"<div><b>Bold</b></div>"

julia> # Common use case: pre-rendered markdown
       markdown_html = "<p>Already <em>escaped</em> content</p>";

julia> @render @article SafeString(markdown_html)
"<article><p>Already <em>escaped</em> content</p></article>"
```

# Security best practices
```julia
# GOOD: Content from trusted sources
html = markdown_to_html(user_content)  # Markdown processor escapes content
@render @div SafeString(html)

# GOOD: Your own HTML generation
safe_html = "<span class=\"highlight\">Important</span>"
@render @div SafeString(safe_html)

# BAD: Never do this with user input!
user_input = get_user_input()
@render @div SafeString(user_input)  # DANGER: XSS vulnerability!
```

See also: [`@render`](@ref), [`escape_html`](@ref), [`@esc_str`](@ref)
"""
struct SafeString <: AbstractString
    str::String
end

Base.show(io::IO, s::SafeString) = show(io, s.str)
Base.ncodeunits(s::SafeString) = ncodeunits(s.str)
Base.codeunit(s::SafeString) = codeunit(s.str)
Base.codeunit(s::SafeString, i::Integer) = codeunit(s.str, i)
Base.isvalid(s::SafeString, index::Integer) = isvalid(s.str, index)
Base.iterate(s::SafeString) = iterate(s.str)
Base.iterate(s::SafeString, state::Integer) = iterate(s.str, state)
Base.String(s::SafeString) = String(s.str)
