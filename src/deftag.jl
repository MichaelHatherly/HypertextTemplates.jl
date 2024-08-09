"""
    @deftag macro name end
    @deftag name

Create a macro version of the given element or component called `name`. This is
a shorthand way to call the `@<` macro with the given `name` while still
correctly passing the source information through to the renderer. The `macro` variant
allows the LSP to correctly infer the location of the definition whereas the plain
symbol variant does not.
"""
macro deftag(name)
    if isa(name, Symbol)
        return deftag(name)
    elseif MacroTools.@capture(name, macro mname_ end)
        return deftag(mname)
    else
        error("invalid `@deftag` usage. Must be a macro defintion with no body.")
    end
end

function deftag(name::Symbol)
    return esc(
        quote
            $(Expr(:function, name))
            macro $(name)(args...)
                return esc(
                    Expr(
                        :macrocall,
                        GlobalRef(HypertextTemplates, Symbol("@<")),
                        __source__,
                        $(name),
                        args...,
                    ),
                )
            end
        end,
    )
end
