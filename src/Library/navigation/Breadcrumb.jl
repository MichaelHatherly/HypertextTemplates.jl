"""
    @Breadcrumb

A navigation breadcrumb component that displays the hierarchical path to the current page. Breadcrumbs are crucial wayfinding elements that help users understand their location within a website's structure and provide quick navigation to parent pages. This component automatically handles the visual styling of links versus the current page, includes proper ARIA attributes for accessibility, and uses semantic HTML markup. The customizable separator and responsive text sizing ensure breadcrumbs remain readable and functional across all device sizes.

# Props
- `items::Vector{Tuple{String,String}}`: Breadcrumb items as (href, label) tuples
- `separator::String`: Separator character/string (default: `"/"`)

# Accessibility
**ARIA:** Uses `<nav aria-label="Breadcrumb">` with `aria-current="page"` for current page. Ordered list conveys hierarchy.

**Keyboard:** Tab through breadcrumb links, Enter follows navigation. Current page is skipped in tab order.

**Guidelines:** Include home page as first item, use descriptive titles, keep text concise.
"""
@component function Breadcrumb(;
    items::Vector{Tuple{String,String}} = Tuple{String,String}[],
    separator::String = "/",
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract breadcrumb theme safely
    breadcrumb_theme = if isa(theme, NamedTuple) && haskey(theme, :breadcrumb)
        theme.breadcrumb
    else
        HypertextTemplates.Library.default_theme().breadcrumb
    end

    # Get classes
    list_class = get(
        breadcrumb_theme,
        :list,
        HypertextTemplates.Library.default_theme().breadcrumb.list,
    )
    item_class = get(
        breadcrumb_theme,
        :item,
        HypertextTemplates.Library.default_theme().breadcrumb.item,
    )
    current_class = get(
        breadcrumb_theme,
        :current,
        HypertextTemplates.Library.default_theme().breadcrumb.current,
    )
    link_class = get(
        breadcrumb_theme,
        :link,
        HypertextTemplates.Library.default_theme().breadcrumb.link,
    )
    separator_class = get(
        breadcrumb_theme,
        :separator,
        HypertextTemplates.Library.default_theme().breadcrumb.separator,
    )

    @nav {"aria-label" = "Breadcrumb", attrs...} begin
        @ol {class = list_class} begin
            for (i, (href, label)) in enumerate(items)
                @li {class = item_class} begin
                    if i == length(items)
                        # Current page
                        @span {class = current_class, "aria-current" = "page"} $label
                    else
                        # Link
                        @a {href = href, class = link_class} $label
                    end

                    if i < length(items)
                        @span {class = separator_class, "aria-hidden" = "true"} $separator
                    end
                end
            end
        end
    end
end

@deftag macro Breadcrumb end
