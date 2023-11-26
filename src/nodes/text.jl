struct Text <: AbstractNode
    content::String
    line::Int

    function Text(content::String, line)
        return new(_restore_special_symbols(content), line)
    end
end

function Text(n::EzXML.Node)
    if EzXML.istext(n)
        content = EzXML.nodecontent(n)

        # Leave a space on either side of the content if there is non-whitespace.
        left = lstrip(content)
        content = left == content ? content : " $left"
        right = rstrip(content)
        content = right == content ? content : "$right "

        return Text(all(isspace, content) ? "" : content, nodeline(n))
    else
        error("expected a text node, found: $(EzXML.nodename(n))")
    end
end

function expression(c::BuilderContext, t::Text)
    if isempty(t.content)
        return nothing
    else
        :(print($(c.io), $(t.content))) |> lln_replacer(c.file, t.line)
    end
end
