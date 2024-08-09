"""
    TemplateFileLookup(handler)

This is a developer tool that can be added to an `HTTP` handler stack to allow
the user to open the template file in their default editor by holding down the
`Ctrl` key and clicking on the rendered template. This is useful for debugging
navigating the template files instead of having to manually search through a
codebase for the template file that renders a given item within a page.

```julia
HTTP.serve(router |> TemplateFileLookup, host, port)
```

Always add the `TemplateFileLookup` handler after the other handlers, since it
needs to inject a script into the response to listen for clicks on the rendered
template.
"""
TemplateFileLookup(handler) = _template_file_lookup(nothing, handler)

function _template_file_lookup(::Any, handler)
    function (request)
        return handler(request)
    end
end
