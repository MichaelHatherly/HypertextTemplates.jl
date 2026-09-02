"""
    @__slot__ [name]

Define a content slot within a component.

Slots enable content projection - allowing parent components to pass content
into specific locations within child components. This is essential for creating
flexible, composable components.

# Arguments
- `name`: Optional slot name. If omitted, creates the default slot.

# Default slot
The default slot (no name) receives all content passed to the component that
isn't assigned to a named slot.

```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function card(; title)
           @div {class = "card"} begin
               @h2 \$title
               @div {class = "content"} @__slot__
           end
       end;

julia> @deftag macro card end
@card (macro with 1 method)

julia> @render @card {title = "Welcome"} begin
           @p "This goes into the default slot"
           @p "So does this"
       end
"<div class=\\"card\\"><h2>Welcome</h2><div class=\\"content\\"><p>This goes into the default slot</p><p>So does this</p></div></div>"
```

# Named slots
Named slots receive only content explicitly assigned to them using `name := content` syntax.

```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function modal(; title = "")
           @div {class = "modal"} begin
               @header begin
                   @h2 \$title
                   @__slot__ header_actions
               end
               @div {class = "body"} @__slot__
               @footer @__slot__ footer
           end
       end;

julia> @deftag macro modal end
@modal (macro with 1 method)

julia> @render @modal {title = "Confirm"} begin
           # Default slot content
           @p "Are you sure?"
           # Named slot content
           header_actions := @button {class = "close"} "×"
           footer := begin
               @button "Cancel"
               @button {class = "primary"} "OK"
           end
       end
"<div class=\\"modal\\"><header><h2>Confirm</h2><button class=\\"close\\">×</button></header><div class=\\"body\\"><p>Are you sure?</p></div><footer><button>Cancel</button><button class=\\"primary\\">OK</button></footer></div>"
```

See also: [`@component`](@ref)
"""
macro __slot__(name = S"default")
    slots = esc(S"slots")
    key = QuoteNode(name)
    # Handed the stream the component has reached, so the content is written as
    # the content of whatever element renders it.
    io = esc(S"io")
    revise = esc(S"revise")
    revise_defined = esc(Expr(:isdefined, S"revise"))
    # Which slots were passed is part of the `NamedTuple`'s type, so this test
    # is settled during compilation and a slot that was passed costs nothing.
    return quote
        if haskey($(slots), $(key))
            getfield($(slots), $(key))($(io))
        else
            $(_missing_slot)($(slots), $(key), $(revise_defined) ? $(revise) : nothing)
        end
    end
end

@noinline function _missing_slot(slots::NamedTuple, name::Symbol, revise)
    # `revise` carries the component's own function, which is the only place
    # the component's name is still available by the time a slot is looked up.
    component = isnothing(revise) ? "this component" : "component `$(nameof(revise[1]))`"
    # Every call site passes a default slot whether or not the caller wrote
    # content for it, so listing it would name a slot the template never
    # mentioned. It is also why the default can never be the missing one.
    named = filter(each -> each !== S"default", keys(slots))
    available = isempty(named) ? "no named slots were passed" :
        "the named slots passed were $(join(map(each -> "`$(each)`", named), ", "))"
    return error("$(component) has no slot named `$(name)`: $(available).")
end
