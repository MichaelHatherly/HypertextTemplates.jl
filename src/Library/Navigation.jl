# Import required utilities
using HypertextTemplates: SafeString
using ..Library: merge_attrs

"""
    @Breadcrumb

Navigation breadcrumb component.

# Props
- `items::Vector{Tuple{String,String}}`: Breadcrumb items as (href, label) tuples
- `separator::String`: Separator character/string (default: `"/"`)
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
                            class = "text-gray-700 dark:text-gray-300 font-medium",
                            "aria-current" = "page",
                        } $label
                    else
                        # Link
                        @a {
                            href = href,
                            class = "text-gray-600 hover:text-blue-600 dark:text-gray-400 dark:hover:text-blue-400 transition-colors duration-200 hover:underline underline-offset-2",
                        } $label
                    end

                    if i < length(items)
                        @span {
                            class = "mx-2 text-gray-400 dark:text-gray-600",
                            "aria-hidden" = "true",
                        } $separator
                    end
                end
            end
        end
    end
end

@deftag macro Breadcrumb end

"""
    @Pagination

Page navigation component.

# Props
- `current::Int`: Current page number (default: `1`)
- `total::Int`: Total number of pages (default: `1`)
- `siblings::Int`: Number of sibling pages to show (default: `1`)
- `base_url::String`: Base URL for page links (default: `"#"`)
"""
@component function Pagination(;
    current::Int = 1,
    total::Int = 1,
    siblings::Int = 1,
    base_url::String = "#",
    attrs...,
)
    # Calculate which page numbers to show
    pages = Int[]

    # Always show first page
    push!(pages, 1)

    # Show pages around current
    start_page = max(2, current - siblings)
    end_page = min(total - 1, current + siblings)

    # Add ellipsis if needed
    if start_page > 2
        push!(pages, -1)  # -1 represents ellipsis
    end

    # Add middle pages
    for p = start_page:end_page
        push!(pages, p)
    end

    # Add ellipsis if needed
    if end_page < total - 1
        push!(pages, -1)  # -1 represents ellipsis
    end

    # Always show last page (if more than 1 page)
    if total > 1
        push!(pages, total)
    end

    @nav {class = "flex items-center justify-center", "aria-label" = "Pagination", attrs...} begin
        @ul {class = "flex items-center gap-1"} begin
            # Previous button
            @li begin
                if current > 1
                    @a {
                        href = "$base_url$(current-1)",
                        class = "relative inline-flex items-center px-3 py-2 text-sm font-medium text-gray-600 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 dark:bg-gray-900 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-800 transition-all duration-200 shadow-sm hover:shadow",
                        "aria-label" = "Go to previous page",
                    } begin
                        @text HypertextTemplates.SafeString(
                            """<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" /></svg>""",
                        )
                    end
                else
                    @span {
                        class = "relative inline-flex items-center px-3 py-2 text-sm font-medium text-gray-400 bg-gray-50 border border-gray-200 rounded-xl cursor-not-allowed dark:bg-gray-900 dark:border-gray-700 opacity-50",
                        "aria-label" = "Previous page (disabled)",
                        "aria-disabled" = "true",
                    } begin
                        @text HypertextTemplates.SafeString(
                            """<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" /></svg>""",
                        )
                    end
                end
            end

            # Page numbers
            for page in pages
                @li begin
                    if page == -1
                        # Ellipsis
                        @span {
                            class = "relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg dark:bg-gray-900 dark:border-gray-700 dark:text-gray-500",
                        } "..."
                    elseif page == current
                        # Current page
                        @span {
                            "aria-current" = "page",
                            class = "relative inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-500 border border-blue-500 rounded-xl shadow-sm dark:bg-blue-600 dark:border-blue-600",
                        } @text string(page)
                    else
                        # Other pages
                        @a {
                            href = "$base_url$page",
                            class = "relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-600 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 dark:bg-gray-900 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-800 transition-all duration-200 shadow-sm hover:shadow",
                        } @text string(page)
                    end
                end
            end

            # Next button
            @li begin
                if current < total
                    @a {
                        href = "$base_url$(current+1)",
                        class = "relative inline-flex items-center px-3 py-2 text-sm font-medium text-gray-600 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 dark:bg-gray-900 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-800 transition-all duration-200 shadow-sm hover:shadow",
                        "aria-label" = "Go to next page",
                    } begin
                        @text HypertextTemplates.SafeString(
                            """<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" /></svg>""",
                        )
                    end
                else
                    @span {
                        class = "relative inline-flex items-center px-3 py-2 text-sm font-medium text-gray-400 bg-gray-50 border border-gray-200 rounded-xl cursor-not-allowed dark:bg-gray-900 dark:border-gray-700 opacity-50",
                        "aria-label" = "Next page (disabled)",
                        "aria-disabled" = "true",
                    } begin
                        @text HypertextTemplates.SafeString(
                            """<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" /></svg>""",
                        )
                    end
                end
            end
        end
    end
end

@deftag macro Pagination end

"""
    @Tabs

Interactive tab navigation component powered by Alpine.js.

# Props
- `items::Vector{Tuple{String,String}}`: Tab items as (id, label) tuples
- `active::String`: ID of the active tab (default: first item's ID)
- `aria_label::Union{String,Nothing}`: ARIA label for the tab list (optional)

# Requirements
This component requires Alpine.js for tab switching functionality.
Include Alpine.js in your page:

```julia
@script {defer=true, src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"}
```

# Usage
```julia
@Tabs {items = [("tab1", "Tab 1"), ("tab2", "Tab 2")]} begin
    @TabPanel {id = "tab1"} begin
        @Text "Content for Tab 1"
    end
    
    @TabPanel {id = "tab2"} begin
        @Text "Content for Tab 2"
    end
end
```
"""
@component function Tabs(;
    items::Vector{Tuple{String,String}} = Tuple{String,String}[],
    active::String = "",
    aria_label::Union{String,Nothing} = nothing,
    attrs...,
)
    # Use first item as active if not specified
    active_id = isempty(active) && !isempty(items) ? items[1][1] : active

    # Build component default attributes with Alpine.js
    component_attrs = (var"x-data" = SafeString("{ activeTab: '$(active_id)' }"),)

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @nav {
            class = "flex gap-2 border-b-2 border-gray-200 dark:border-gray-700",
            "aria-label" = isnothing(aria_label) ? "Tabs" : aria_label,
            role = "tablist",
        } begin
            for (id, label) in items
                @button {
                    type = "button",
                    role = "tab",
                    id = "tab-$id",
                    "aria-controls" = "tabpanel-$id",
                    "@click" = "activeTab = '$id'",
                    ":class" = SafeString(
                        """activeTab === '$id' ? 'px-4 py-2.5 text-sm font-medium text-blue-600 dark:text-blue-400 border-b-2 border-blue-500 dark:border-blue-400 -mb-[2px] transition-all duration-200 rounded-t-lg bg-blue-50 dark:bg-blue-950/30' : 'px-4 py-2.5 text-sm font-medium text-gray-600 dark:text-gray-400 border-b-2 border-transparent -mb-[2px] hover:text-gray-900 hover:bg-gray-50 dark:hover:text-gray-100 dark:hover:bg-gray-800 transition-all duration-200 rounded-t-lg'""",
                    ),
                    ":aria-selected" = "activeTab === '$id'",
                } $label
            end
        end

        # Tab panels container
        @div {class = "mt-4"} begin
            # The slot should contain @TabPanel components
            @__slot__()
        end
    end
end

@deftag macro Tabs end

"""
    @TabPanel

Tab panel component for use within @Tabs. Automatically handles Alpine.js show/hide behavior.

# Props
- `id::String`: The tab ID this panel corresponds to (required)
- `class::String`: Additional CSS classes (optional)

# Usage
```julia
@Tabs {items = [("tab1", "Tab 1"), ("tab2", "Tab 2")]} begin
    @TabPanel {id = "tab1"} begin
        @Text "Content for Tab 1"
    end

    @TabPanel {id = "tab2"} begin
        @Text "Content for Tab 2"
    end
end
```
"""
@component function TabPanel(; id::String, class::String = "", attrs...)
    # Build component attributes with Alpine.js directives
    component_attrs = (
        id = "tabpanel-$id",
        role = "tabpanel",
        var"x-show" = "activeTab === '$id'",
        var"x-transition:enter" = "transition ease-out duration-150",
        var"x-transition:enter-start" = "opacity-0",
        var"x-transition:enter-end" = "opacity-100",
        class = class,
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro TabPanel end
