# Development Tools

The parts that only show up while you are developing.

## Source Locations in the Output

When Revise is loaded, every element carries the template location it was
written at:

```julia
using Revise
using HypertextTemplates, HypertextTemplates.Elements

@component function greeting()
    @p "hi"
end
@deftag macro greeting end

page() = @render @div {class = "x"} @greeting

page()
```

```html
<div class="x" data-htroot="app.jl:9" data-htloc="app.jl:9">
    <p data-htroot="app.jl:9" data-htloc="app.jl:5">hi</p>
</div>
```

`data-htloc` is the file and line of the element itself. The `p` above points
into the component that writes it, not into the page. `data-htroot` is the
`@render` call the whole page came from, which is how you get from a fragment
back to the page holding it. It appears when that call sits in a method Revise
can resolve.

None of this reaches a render without Revise. That check is a compile-time
constant: the branch that writes the attributes is not in the code a deployed
render runs.

To leave them out of one render while Revise is loaded, set the
`include_data_htloc` property on the destination:

```julia
io = IOContext(stdout, :include_data_htloc => false)
@render io @div {class = "x"} @greeting
```

The line numbers survive editing. When a file changes, the offset between where
a component was compiled and where it now sits is resolved again, and a location
still names the line you are looking at.

## Opening a Template From the Browser

[`HypertextTemplates.TemplateFileLookup`](@ref) is an HTTP handler that turns
those attributes into a jump to the editor. It injects a small script into every
`text/html` response, which means it wraps the rest of the stack and goes on
last:

```julia
using HTTP
using HypertextTemplates

HTTP.serve(router |> TemplateFileLookup, host, port)
```

Hold the pointer over the part of the page you are interested in and press
`Ctrl+1` to open the template the page was rendered from, or `Ctrl+2` to open
the one that wrote the element under the pointer. The file opens in the editor
`InteractiveUtils.edit` picks, which `JULIA_EDITOR` controls.

It needs HTTP loaded, and it needs attributes to aim at, which means Revise as
well.

## Live Reloading

With Revise loaded, editing a component's source updates what later renders
produce, the way it does for any other function.

Markdown components follow their file too. Under Revise, `@cm_component` re-reads
and re-parses it, so an edit to the Markdown shows up on the next render.
Otherwise the file is read and parsed once while the macro expands, and a
deployed render pays nothing for the parse.

## Bonito Apps

With Bonito loaded, a `Bonito.App` interpolated into a template goes through
Bonito's own `text/html` rendering instead of being escaped. An interactive app
can therefore sit inside a page a template builds. The session and the assets it
needs are still Bonito's to supply.

```julia
using Bonito
using HypertextTemplates, HypertextTemplates.Elements

app = App() do
    DOM.div("Interactive content")
end

@render @div {class = "app"} $app
```
