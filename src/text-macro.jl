"""
    @text content...

Embed the given `content` as plain text in the surrounding DOM tree.
Can only be used within DOM expressions. Text is HTML-escaped before
printing to the output. Use `SafeString` to mark text as "safe" so that
it is not escaped.
"""
macro text(content...)
    fn(s::AbstractString) = :(print($(esc(S"io")), $(sprint(escape_html, s))))
    fn(other) = :($(escape_html)($(esc(S"io")), $(esc(other)), $(esc(S"revise"))))
    content = fn.(content)
    return Expr(:block, content...)
end
