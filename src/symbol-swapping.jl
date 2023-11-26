const __SPECIAL_AT_SYMBOL__ = "__special_at_symbol__"
const __SPECIAL_DOLLAR_SYMBOL__ = "__special_dollar_symbol__"
const __SPECIAL_SPLAT_SYMBOL__ = "__special_splat_symbol__"

function _swap_special_symbols(s::String)::String
    return _replace(
        s,
        "@" => __SPECIAL_AT_SYMBOL__,
        "\$" => __SPECIAL_DOLLAR_SYMBOL__,
        "..." => __SPECIAL_SPLAT_SYMBOL__,
    )
end

function _restore_special_symbols(other)
    return other
end

function _restore_special_symbols(s::AbstractString)
    return _replace(
        s,
        __SPECIAL_AT_SYMBOL__ => "@",
        __SPECIAL_DOLLAR_SYMBOL__ => "\$",
        __SPECIAL_SPLAT_SYMBOL__ => "...",
    )
end

@static if VERSION >= v"1.7"
    _replace(s, args...) = Base.replace(s, args...)
else
    function _replace(s, args...)
        for arg in args
            s = Base.replace(s, arg)
        end
        return s
    end
end