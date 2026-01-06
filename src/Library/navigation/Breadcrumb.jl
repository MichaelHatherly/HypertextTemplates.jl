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
    @nav {"aria-label" = "Breadcrumb", attrs...} begin
        @ol {class = "flex items-center space-x-2 text-sm"} begin
            for (i, (href, label)) in enumerate(items)
                @li {class = "flex items-center"} begin
                    if i == length(items)
                        # Current page
                        @span {
                            class = "text-slate-900 dark:text-slate-100 font-medium",
                            "aria-current" = "page",
                        } $label
                    else
                        # Link
                        @a {
                            href = href,
                            class = "text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200 transition-colors duration-150",
                        } $label
                    end

                    if i < length(items)
                        @span {
                            class = "mx-2 text-slate-300 dark:text-slate-600",
                            "aria-hidden" = "true",
                        } $separator
                    end
                end
            end
        end
    end
end

@deftag macro Breadcrumb end
