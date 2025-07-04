"""
    @Pagination

A page navigation component that provides intuitive controls for navigating through paginated content. Pagination is essential for managing large datasets by breaking them into digestible chunks, improving both performance and user experience. This component intelligently displays page numbers with ellipsis for large ranges, always shows first and last pages, and includes previous/next navigation buttons. It handles edge cases like disabled states at boundaries and provides proper ARIA labels for screen reader users. The responsive design ensures the pagination remains usable on mobile devices.

# Props
- `current::Int`: Current page number (default: `1`)
- `total::Int`: Total number of pages (default: `1`)
- `siblings::Int`: Number of sibling pages to show (default: `1`)
- `base_url::String`: Base URL for page links (default: `"#"`)

# Accessibility
**ARIA:** Uses `<nav aria-label="Pagination">` with `aria-current="page"` and `aria-disabled` for states.

**Keyboard:** Tab through pagination controls, Enter activates navigation. Disabled controls are skipped.

**Screen Reader:** Current page and button states are announced with positional context.

**Guidelines:** Provide meaningful URLs, consider mobile behavior, include page count context.
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
