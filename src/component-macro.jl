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
