struct Text <: AbstractNode
    content::String
    line::Int

    function Text(content::String, line)
        return new(content, line)
    end
end

function Text(ctx, n::Lexbor.Node)
    if Lexbor.istext(n)
        content = Lexbor.nodecontent(n)

        # Leave a space on either side of the content if there is non-whitespace.
        left = lstrip(content)
        content = left == content ? content : " $left"
        right = rstrip(content)
        content = right == content ? content : "$right "

        return Text(all(isspace, content) ? "" : content, nodeline(n))
    else
        error("expected a text node, found: $(Lexbor.nodename(n))")
    end
end

function Text(ctx, str::String)
    left = lstrip(str)
    str = left == str ? str : " $left"
    right = rstrip(str)
    str = right == str ? str : "$right "
    return Text(all(isspace, str) ? "" : str, 0)
end

function expression(c::BuilderContext, t::Text)
    if isempty(t.content)
        return nothing
    else
        :(print($(c.io), $(t.content))) |> lln_replacer(c.file, t.line)
    end
end
