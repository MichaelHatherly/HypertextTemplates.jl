"""
    @deftag macro name end
    @deftag name

Create a macro shortcut for using a component or element.

After defining a component with [`@component`](@ref), use `@deftag` to create
a convenient macro that allows using the component like an HTML element.

The `macro name end` syntax is preferred as it allows the LSP to correctly
track the macro definition location.

# Arguments
- `name`: Symbol name of the component/element to create a macro for

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> # Define a component
       @component function alert(; type = "info", dismissible = false)
           @div {class = "alert alert-\$type"} begin
               @__slot__
               if dismissible
                   @button {class = "close"} "×"
               end
           end
       end
alert (generic function with 1 method)

julia> # Create macro (preferred syntax for LSP support)
       @deftag macro alert end
@alert (macro with 1 method)

julia> # Now use like an HTML element
       @render @alert {type = "warning"} "Watch out!"
"<div class=\\"alert alert-warning\\">Watch out!</div>"

julia> # Alternative syntax (works but no LSP support)
       @component function message(; text)
           @p {class = "message"} \$text
       end
message (generic function with 1 method)

julia> @deftag message
@message (macro with 1 method)

julia> @render @message {text = "Hello"}
"<p class=\\"message\\">Hello</p>"
```

# Custom elements
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> # Define a custom HTML element
       @element "my-widget" my_widget

julia> @deftag macro my_widget end
@my_widget (macro with 1 method)

julia> @render @my_widget {id = "w1"} "Custom element"
"<my-widget id=\\"w1\\">Custom element</my-widget>"
```

See also: [`@component`](@ref), [`@element`](@ref), [`@<`](@ref)
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
    # The generated macro is defined in, and expands in, the caller's module,
    # so every name its body mentions has to be qualified. An unqualified
    # `esc`, `Expr`, `GlobalRef` or `Symbol` would resolve against the caller's
    # bindings instead of `Base`/`Core`, and a caller that happens to define
    # any of those names would break every tag macro in their module with an
    # error pointing into this file. `HypertextTemplates` is spliced as a
    # module value for the same reason: the caller need not have it in scope
    # under that name, or at all.
    tag_macro = Core.GlobalRef(HypertextTemplates, Symbol("@<"))
    return esc(
        quote
            $(Expr(:function, name))
            macro $(name)(args...)
                return $(Base.esc)(
                    $(Core.Expr)(
                        :macrocall,
                        $(Core.GlobalRef)($(tag_macro.mod), $(QuoteNode(tag_macro.name))),
                        __source__,
                        $(name),
                        args...,
                    ),
                )
            end
        end,
    )
end
