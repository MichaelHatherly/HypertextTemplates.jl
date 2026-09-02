# Components.

"""
    @component function component_name(; properties...)
        # template body
    end

Define a reusable component function.

Components are functions that return template content and can accept properties
as keyword arguments. They enable code reuse and composition in templates.

After defining a component, use [`@deftag`](@ref) to create a convenient macro
for using it like a regular HTML element.

# Arguments
- `component_name`: The name of the component function
- `properties...`: Keyword arguments that become the component's props

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function greeting(; name = "World")
           @h1 "Hello, " \$name "!"
       end
greeting (generic function with 1 method)

julia> @deftag macro greeting end
@greeting (macro with 1 method)

julia> @render @greeting {name = "Julia"}
"<h1>Hello, Julia!</h1>"

julia> @render @greeting  # Uses default value
"<h1>Hello, World!</h1>"
```

# Components with slots
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function card(; title)
           @div {class = "card"} begin
               @h2 \$title
               @div {class = "body"} @__slot__
           end
       end
card (generic function with 1 method)

julia> @deftag macro card end
@card (macro with 1 method)

julia> @render @card {title = "Info"} begin
           @p "Card content goes here"
       end
"<div class=\\"card\\"><h2>Info</h2><div class=\\"body\\"><p>Card content goes here</p></div></div>"
```

# Typed props for safety
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function price(; amount::Number, currency::String = "USD")
           @span {class = "price"} \$currency " " \$(round(amount, digits=2))
       end
price (generic function with 1 method)

julia> @deftag macro price end
@price (macro with 1 method)

julia> @render @price {amount = 19.999}
"<span class=\\"price\\">USD 20.0</span>"
```

See also: [`@deftag`](@ref), [`@__slot__`](@ref), [`@render`](@ref)
"""
macro component(expr)
    io = esc(S"io")
    slots = esc(S"slots")
    revise = esc(S"revise")
    name, kwargs, body = if MacroTools.@capture(
            expr, function name_(; kwargs__)
                body__
            end
        )
        name, kwargs, body
    elseif MacroTools.@capture(
            expr, function name_()
                body__
            end
        )
        name, [], body
    else
        error("invalid use of `@component`. Must be a function definition or a code block.")
    end

    # `functionloc` reads the location off the `LineNumberNode` the body opens
    # with, so the definition site goes in here directly. A `quote` would
    # supply one pointing into this file instead.
    location = LineNumberNode(__source__.line, __source__.file)
    signature = :(
        $(esc(name))(;
            $(io)::IO = IOBuffer(),
            $(slots)::NamedTuple = (;),
            $(esc.(kwargs)...),
        )
    )
    definition = Expr(
        :function,
        signature,
        Expr(
            :block,
            location,
            :($(revise) = ($(esc(name)), $(String(__source__.file), __source__.line))),
            esc.(body)...,
        ),
    )
    return Expr(:block, location, definition)
end
