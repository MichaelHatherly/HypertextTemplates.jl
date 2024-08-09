macro V_str(txt)
    return esc(_hidden_name(txt))
end

macro S_str(txt)
    return QuoteNode(_hidden_name(txt))
end

_hidden_name(txt::String) = Symbol("**$txt**")
