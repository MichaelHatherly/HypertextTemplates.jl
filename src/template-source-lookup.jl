"""
    TemplateFileLookup(handler)

A developer tool that opens the template behind part of a rendered page in your
editor, instead of searching a codebase for whatever wrote a given item. Add it
to an `HTTP` handler stack:

```julia
HTTP.serve(router |> TemplateFileLookup, host, port)
```

Hold the pointer over the part of the page you are interested in and press
`Ctrl+1` to open the template the page was rendered from, or `Ctrl+2` to open
the one that wrote the element under the pointer. The file opens in the editor
`InteractiveUtils.edit` chooses, which `JULIA_EDITOR` controls.

Both rely on the `data-htroot` and `data-htloc` attributes, which a render only
writes when `Revise` is loaded.

Always add the `TemplateFileLookup` handler after the other handlers, since it
injects a script into the response and needs the rendered page to inject it
into.
"""
TemplateFileLookup(handler) = _template_file_lookup(nothing, handler)

# This interface function is extended by the `HypertextTemplatesHTTPExt`
# extension module. See that file for the real definition.
_template_file_lookup(::Any, handler) =
    error("`TemplateFileLookup` needs `HTTP.jl` to work.")
