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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract pagination theme safely
    pagination_theme = if isa(theme, NamedTuple) && haskey(theme, :pagination)
        theme.pagination
    else
        HypertextTemplates.Library.default_theme().pagination
    end

    # Get classes
    wrapper_class = get(
        pagination_theme,
        :wrapper,
        HypertextTemplates.Library.default_theme().pagination.wrapper,
    )
    list_class = get(
        pagination_theme,
        :list,
        HypertextTemplates.Library.default_theme().pagination.list,
    )
    button_class = get(
        pagination_theme,
        :button,
        HypertextTemplates.Library.default_theme().pagination.button,
    )
    button_disabled_class = get(
        pagination_theme,
        :button_disabled,
        HypertextTemplates.Library.default_theme().pagination.button_disabled,
    )
    page_class = get(
        pagination_theme,
        :page,
        HypertextTemplates.Library.default_theme().pagination.page,
    )
    page_current_class = get(
        pagination_theme,
        :page_current,
        HypertextTemplates.Library.default_theme().pagination.page_current,
    )
    ellipsis_class = get(
        pagination_theme,
        :ellipsis,
        HypertextTemplates.Library.default_theme().pagination.ellipsis,
    )
    prev_icon = get(
        pagination_theme,
        :prev_icon,
        HypertextTemplates.Library.default_theme().pagination.prev_icon,
    )
    next_icon = get(
        pagination_theme,
        :next_icon,
        HypertextTemplates.Library.default_theme().pagination.next_icon,
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

    @nav {class = wrapper_class, "aria-label" = "Pagination", attrs...} begin
        @ul {class = list_class} begin
            # Previous button
            @li begin
                if current > 1
                    @a {
                        href = "$base_url$(current-1)",
                        class = button_class,
                        "aria-label" = "Go to previous page",
                    } begin
                        @text HypertextTemplates.SafeString(prev_icon)
                    end
                else
                    @span {
                        class = button_disabled_class,
                        "aria-label" = "Previous page (disabled)",
                        "aria-disabled" = "true",
                    } begin
                        @text HypertextTemplates.SafeString(prev_icon)
                    end
                end
            end

            # Page numbers
            for page in pages
                @li begin
                    if page == -1
                        # Ellipsis
                        @span {class = ellipsis_class} "..."
                    elseif page == current
                        # Current page
                        @span {"aria-current" = "page", class = page_current_class} @text string(
                            page,
                        )
                    else
                        # Other pages
                        @a {href = "$base_url$page", class = page_class} @text string(page)
                    end
                end
            end

            # Next button
            @li begin
                if current < total
                    @a {
                        href = "$base_url$(current+1)",
                        class = button_class,
                        "aria-label" = "Go to next page",
                    } begin
                        @text HypertextTemplates.SafeString(next_icon)
                    end
                else
                    @span {
                        class = button_disabled_class,
                        "aria-label" = "Next page (disabled)",
                        "aria-disabled" = "true",
                    } begin
                        @text HypertextTemplates.SafeString(next_icon)
                    end
                end
            end
        end
    end
end

@deftag macro Pagination end
