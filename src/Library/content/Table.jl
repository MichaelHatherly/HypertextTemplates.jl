"""
    @Table

A responsive data table component for displaying structured data with extensive customization options. Features striped rows, hover effects, sticky headers, sortable columns, and full accessibility support.

# Props
- `striped::Bool`: Whether to show striped rows (default: `false`)
- `bordered::Bool`: Whether to show borders (default: `true`)
- `hover::Bool`: Whether to show hover effect on rows (default: `true`)
- `compact::Bool`: Whether to use compact spacing (default: `false`)
- `sticky_header::Bool`: Whether table header should be sticky (default: `false`)
- `sortable::Bool`: Whether to show sortable column indicators (default: `false`)
- `caption::Union{String,Nothing}`: Table caption/description (optional)
- `overflow::Bool`: Whether to apply overflow scrolling (default: `true`). Set to `false` when table contains dropdowns or other overlaying elements

# Slots
- Table content - should contain standard HTML table elements (thead, tbody, tr, th, td)

# Example
```julia
# Basic table
@Table begin
    @thead begin
        @tr begin
            @th "Name"
            @th "Email"
            @th "Role"
        end
    end
    @tbody begin
        @tr begin
            @td "John Doe"
            @td "john@example.com"
            @td "Admin"
        end
        @tr begin
            @td "Jane Smith"
            @td "jane@example.com"
            @td "User"
        end
    end
end

# Striped table with sticky header
@Table {striped = true, sticky_header = true, caption = "User list"} begin
    @thead begin
        @tr begin
            @th "ID"
            @th "Username"
            @th "Status"
        end
    end
    @tbody begin
        # Table rows...
    end
end
```

# Accessibility
**Semantic Markup:** Uses proper `<table>`, `<thead>`, `<tbody>`, `<th>`, and `<td>` elements with scope attributes.

**Screen Readers:** Table structure, captions, and header relationships are announced to assistive technology.

**Keyboard Navigation:** Tab through any interactive elements within table cells.

**Guidelines:** Provide meaningful captions, clear column headers, and consider responsive alternatives for mobile.

# See also
- [`List`](@ref) - For simpler list layouts
- [`Grid`](@ref) - For card-based data display
"""
@component function Table(;
    striped::Bool = false,
    bordered::Bool = true,
    hover::Bool = true,
    compact::Bool = false,
    sticky_header::Bool = false,
    sortable::Bool = false,
    caption::Union{String,Nothing} = nothing,
    overflow::Bool = true,
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract table theme safely
    table_theme = if isa(theme, NamedTuple) && haskey(theme, :table)
        theme.table
    else
        HypertextTemplates.Library.default_theme().table
    end

    # Get wrapper theme
    wrapper_theme =
        get(table_theme, :wrapper, HypertextTemplates.Library.default_theme().table.wrapper)
    wrapper_base = get(wrapper_theme, :base, "w-full relative")
    wrapper_sticky = get(wrapper_theme, :sticky, "overflow-auto max-h-[600px]")
    wrapper_overflow = get(wrapper_theme, :overflow, "overflow-x-auto")

    # Build wrapper classes
    wrapper_classes = [wrapper_base]
    if sticky_header
        push!(wrapper_classes, wrapper_sticky)
    elseif overflow
        push!(wrapper_classes, wrapper_overflow)
    end

    # Get container theme
    container_theme = get(
        table_theme,
        :container,
        HypertextTemplates.Library.default_theme().table.container,
    )
    container_base = get(container_theme, :base, "w-full")
    container_bordered = get(
        container_theme,
        :bordered,
        "rounded-lg border border-gray-200 dark:border-gray-700",
    )
    container_overflow = get(container_theme, :overflow, "overflow-hidden")

    # Build container classes
    container_classes = [container_base]
    if bordered
        push!(container_classes, container_bordered)
        if overflow
            push!(container_classes, container_overflow)
        end
    end

    # Get table styles theme
    table_styles =
        get(table_theme, :table, HypertextTemplates.Library.default_theme().table.table)

    # Base table classes
    table_base = get(table_styles, :base, "w-full text-sm border-separate border-spacing-0")
    table_classes = [table_base]

    # Header styling
    header_base = get(
        table_styles,
        :header_base,
        HypertextTemplates.Library.default_theme().table.table.header_base,
    )
    push!(table_classes, header_base)

    # Header padding
    header_padding = get(
        table_styles,
        :header_padding,
        HypertextTemplates.Library.default_theme().table.table.header_padding,
    )
    header_padding_class =
        compact ? get(header_padding, :compact, "") : get(header_padding, :normal, "")
    push!(table_classes, header_padding_class)

    # Cell styling
    cell_base = get(
        table_styles,
        :cell_base,
        HypertextTemplates.Library.default_theme().table.table.cell_base,
    )
    push!(table_classes, cell_base)

    # Cell padding
    cell_padding = get(
        table_styles,
        :cell_padding,
        HypertextTemplates.Library.default_theme().table.table.cell_padding,
    )
    cell_padding_class =
        compact ? get(cell_padding, :compact, "") : get(cell_padding, :normal, "")
    push!(table_classes, cell_padding_class)

    # Striped rows
    if striped
        striped_class = get(
            table_styles,
            :striped,
            HypertextTemplates.Library.default_theme().table.table.striped,
        )
        push!(table_classes, striped_class)
    end

    # Hover effect
    if hover
        hover_class = get(
            table_styles,
            :hover,
            HypertextTemplates.Library.default_theme().table.table.hover,
        )
        push!(table_classes, hover_class)
    end

    # Sticky header
    if sticky_header
        sticky_class = get(
            table_styles,
            :sticky_header,
            HypertextTemplates.Library.default_theme().table.table.sticky_header,
        )
        push!(table_classes, sticky_class)
    end

    # Sortable columns
    if sortable
        sortable_class = get(
            table_styles,
            :sortable,
            HypertextTemplates.Library.default_theme().table.table.sortable,
        )
        push!(table_classes, sortable_class)
    end

    # Caption styling
    caption_class =
        get(table_theme, :caption, HypertextTemplates.Library.default_theme().table.caption)

    # Build component default attributes
    component_attrs = (class = SafeString(join(table_classes, " ")),)

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {class = join(wrapper_classes, " ")} begin
        if !isnothing(caption)
            @p {class = caption_class} caption
        end

        @div {class = SafeString(join(container_classes, " "))} begin
            @table {merged_attrs...} begin
                @__slot__()
            end
        end
    end
end

@deftag macro Table end
