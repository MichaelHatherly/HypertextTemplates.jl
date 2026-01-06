module Routes

using HypertextTemplates
using ReloadableMiddleware.Router
import HTTP

import ..Templates

@GET "/examples/{name}" function example(req; path::@NamedTuple{name::String})
    # TODO: Implement a proper example page
    name = path.name
    name = Symbol(endswith(name, ".html") ? first(splitext(name)) : name)
    component = getfield(Templates, name)
    @render Templates.@HTMLDocument {
        title = Templates.component_title(component),
        current_page = String(name),
    } begin
        @<component
    end
end

@GET "/assets/dist/app.css" function (req)
    css_path = joinpath(@__DIR__, "..", "assets", "dist", "app.css")
    content = read(css_path, String)
    return HTTP.Response(200, ["Content-Type" => "text/css"], content)
end

end
