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

julia> # Now use like an HTML element
       @render @alert {type = "warning"} "Watch out!"
"<div class=\"alert alert-warning\">Watch out!</div>"

julia> # Alternative syntax (works but no LSP support)
       @component function message(; text)
           @p {class = "message"} \$text
       end
message (generic function with 1 method)

julia> @deftag message

julia> @render @message {text = "Hello"}
"<p class=\"message\">Hello</p>"
```

# Custom elements
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> # Define a custom HTML element
       @element "my-widget" my_widget
my_widget (generic function with 6 methods)

julia> @deftag macro my_widget end

julia> @render @my_widget {id = "w1"} "Custom element"
"<my-widget id=\"w1\">Custom element</my-widget>"
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
