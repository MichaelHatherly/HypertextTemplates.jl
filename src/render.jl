# `component::C` rather than `component::Function`: Julia does not specialize on
# an argument only passed along, and the component is worth specializing on.
"""
    render([dst], component; properties...)

Render the `component` with the given `properties` to the optional `dst`.
This is the functional version of `@render`.
"""
render(component::C; properties...) where {C <: Function} =
    @render @<component {properties...}
render(dst, component::C; properties...) where {C <: Function} =
    @render dst @<component {properties...}
