"""
    @__slot__ [name]

Mark a slot location within the DOM. An unnamed slot will run all
expressions that are not named within a `@<` expression, while named
slots will only run the expressions that are named with `name := expr`
syntax.
"""
macro __slot__(name = S"default")
    esc(:(getfield($(S"slots"), $(QuoteNode(name)))()))
end
