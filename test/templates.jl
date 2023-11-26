using HypertextTemplates

@custom_element "custom-element"

template"templates/basic/for.html"
template"templates/basic/julia.html"
template"templates/basic/show.html"
template"templates/basic/match.html"
template"templates/basic/slot.html"
template"templates/basic/named-slot.html"
template"templates/basic/complete.html"
template"templates/basic/props.html"
template"templates/basic/layout.html"
template"templates/basic/layout-usage.html"
template"templates/basic/special-symbols.html"
template"templates/basic/custom-elements.html"
template"templates/basic/splat.html"
template"templates/basic/splatted-props.html"
template"templates/basic/file-and-line-info.html"

module Complex

using HypertextTemplates

template"templates/complex/layouts/base-layout.html"
template"templates/complex/layouts/sidebar.html"
template"templates/complex/layouts/docs.html"

template"templates/complex/pages/home.html"
template"templates/complex/pages/app.html"
template"templates/complex/pages/help.html"
template"templates/complex/pages/tutorials.html"

template"templates/complex/components/button.html"
template"templates/complex/components/dropdown.html"
template"templates/complex/components/tooltip.html"
template"templates/complex/components/modal.html"

end

module Keywords

using HypertextTemplates

template"templates/keywords/keywords.html"

end
