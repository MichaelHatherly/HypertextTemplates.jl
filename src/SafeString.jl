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
       @render @div \$(SafeString("<b>Bold</b>"))
"<div><b>Bold</b></div>"

julia> # Common use case: pre-rendered markdown
       markdown_html = "<p>Already <em>escaped</em> content</p>";

julia> @render @article \$(SafeString(markdown_html))
"<article><p>Already <em>escaped</em> content</p></article>"

julia> # Inside a script the element's own end tag is still neutralised
       @render @script \$(SafeString("var s = '</script>';"))
"<script>var s = '<\\\\/script>';</script>"
```

!!! note "Inside a `script` or a `style`"
    Those two hold raw text, and nothing written in one is escaped, a
    `SafeString` included. What is still neutralised there is the sequence that
    would take the parser out of the element, since a `</script` carried in
    trusted JSON built from a user's data would end the `script` and leave the
    rest of the value as markup. `<\\/` is what JavaScript reads as `</` inside
    a string and is a valid JSON string escape, so the program the script runs
    and the value it parses are unchanged.

    An end tag for any other element is left alone: the parser reads the name
    after the `</` and hands the characters back as text unless they name the
    element that is open. So markup written into a `script` for a page to read
    back, a `text/template` block, survives as markup.

    The one sequence with no faithful spelling is `<!--`, which opens a state
    where a `script`'s own end tag stops closing it. It is neutralised to
    `<\\!--`, which JSON does not accept, so a JSON value carrying a comment
    opener will not parse back.

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
