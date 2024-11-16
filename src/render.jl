"""
    render([dst], component; properties...)

Render the `component` with the given `properties` to the optional `dst`.
This is the functional version of `@render`.
"""
render(component::Function; properties...) = @render @<component {properties...}
render(dst, component::Function; properties...) = @render dst @<component {properties...}
