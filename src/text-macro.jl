"""
    @text content...

Explicitly render content as text within templates.

The `@text` macro explicitly marks content for text rendering with HTML escaping.
It is rarely needed directly since the `\$` interpolation syntax provides the
same functionality more concisely.

Text content is automatically HTML-escaped unless wrapped in [`SafeString`](@ref).
The exception is a `script` or a `style`, whose bodies are raw text rather than
markup: content written directly in one goes out unescaped, with the sequences
that would end the element neutralised instead. The innermost element is what
decides, so `@text` inside an element nested in a script is escaped again.

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
    return Expr(:block, map(_text_content, content)...)
end

# Literal text is escaped during expansion and written as a constant. One that
# escaping changes carries both forms, and `_literal_text` picks between them
# from the stream's type, so it costs an extra constant and nothing at render
# time.
function _text_literal(s::AbstractString)
    escaped = sprint(escape_html, s)
    content = escaped == s ? s : :($(_literal_text)($(esc(S"io")), $(s), $(escaped)))
    return :(print($(esc(S"io")), $(content)))
end

# `value` arrives hygiene-escaped: the caller knows whether it has a piece of
# an interpolated string to flatten first.
_escape_content(value) = :(
    $(_write_content)(
        $(esc(S"io")),
        $(value),
        $(esc(S"revise")),
    )
)

_text_content(s::AbstractString) = _text_literal(s)
function _text_content(other)
    # An interpolated string of two or more pieces is concatenated before being
    # escaped, so the pieces can just as well be written one after another --
    # which skips building the joined string only to scan and discard it.
    #
    # A single-piece string is deliberately left alone. There, `string` can
    # hand back a `SafeString` unchanged, so `"$value"` renders it unescaped
    # while `"x$value"` does not, and that difference is observable.
    if Meta.isexpr(other, :string) && length(other.args) > 1
        return Expr(:block, map(_text_piece, other.args)...)
    end
    return _escape_content(esc(other))
end

_text_piece(s::AbstractString) = _text_literal(s)
_text_piece(other) = _escape_content(:($(_as_text)($(esc(other)))))
