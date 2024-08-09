# Components.

"""
    @component function component_name(; properties...)
        # ...
    end

Define a new reusable component definition.
"""
macro component(expr)
    io = esc(S"io")
    slots = esc(S"slots")
    source = esc(S"source")
    revise = esc(S"revise")
    line, block = if MacroTools.@capture(expr, function name_(; kwargs__)
        body__
    end)
        # IMPORTANT: variables below and `quote` syntax much remain as is such
        # that the line offset calculation remains correct.
        @__LINE__() + 2,
        quote
            function $(esc(name))(;
                $(source) = ("", 0),
                $(io)::IO = IOBuffer(),
                $(slots)::NamedTuple = (;),
                $(esc.(kwargs)...),
            )
                $(revise) = ($(esc(name)), $(String(__source__.file), __source__.line))
                $(esc.(body)...)
            end
        end
    elseif MacroTools.@capture(expr, function name_()
        body__
    end)
        # IMPORTANT: variables below and `quote` syntax much remain as is such
        # that the line offset calculation remains correct.
        @__LINE__() + 2,
        quote
            function $(esc(name))(;
                $(source) = ("", 0),
                $(io)::IO = IOBuffer(),
                $(slots)::NamedTuple = (;),
            )
                $(revise) = ($(esc(name)), $(String(__source__.file), __source__.line))
                $(esc.(body)...)
            end
        end
    else
        error("invalid use of `@component`. Must be a function definition or a code block.")
    end

    # Rewrite line numbers within the function expression such that the
    # `functionloc` of this function matches the definition location rather
    # than the `quote` location.
    return MacroTools.postwalk(block) do each
        if isa(each, LineNumberNode) &&
           String(each.file) == @__FILE__() &&
           each.line == line
            return LineNumberNode(__source__.line, __source__.file)
        else
            return each
        end
    end
end
