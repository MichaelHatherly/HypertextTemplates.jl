const __SPECIAL_AT_SYMBOL__ = "__special_at_symbol__"

function _swap_special_symbols(s::String)::String
    return replace(s, "@" => __SPECIAL_AT_SYMBOL__)
end

function _restore_special_symbols(other)
    return other
end

function _restore_special_symbols(s::AbstractString)
    return replace(s, __SPECIAL_AT_SYMBOL__ => "@")
end
