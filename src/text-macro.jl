"""
    @text content...

Explicitly render content as text within templates.

The `@text` macro explicitly marks content for text rendering with HTML escaping.
It is rarely needed directly since the `\$` interpolation syntax provides the
same functionality more concisely.

Text content is automatically HTML-escaped unless wrapped in [`SafeString`](@ref).

# Arguments
- `content...`: One or more values to render as text

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> # HTML is escaped by default
       @render @div @text "<script>alert('XSS')</script>"
"<div>&lt;script&gt;alert('XSS')&lt;/script&gt;</div>"

julia> # Mix with elements
       @render @div begin
           @h1 "Title"
           @text "Some text content"
           @p "In a paragraph"
       end
"<div><h1>Title</h1>Some text content<p>In a paragraph</p></div>"
```

!!! tip
    The `\$` interpolation syntax is preferred over `@text` in most cases:
    ```julia
    # Preferred
    @div "Count: " \$count

    # Equivalent but verbose
    @div "Count: " @text count
    ```

See also: [`SafeString`](@ref), [`escape_html`](@ref)
"""
macro text(content...)
    fn(s::AbstractString) = :(print($(esc(S"io")), $(sprint(escape_html, s))))
    fn(other) = :($(escape_html)($(esc(S"io")), $(esc(other)), $(esc(S"revise"))))
    content = fn.(content)
    return Expr(:block, content...)
end
