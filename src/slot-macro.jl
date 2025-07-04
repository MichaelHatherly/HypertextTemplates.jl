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
    esc(:(getfield($(S"slots"), $(QuoteNode(name)))($(S"io"))))
end
