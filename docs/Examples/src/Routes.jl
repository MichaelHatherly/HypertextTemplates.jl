module Routes

using HypertextTemplates
using ReloadableMiddleware.Router

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

end
