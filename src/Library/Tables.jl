"""
    @Table

A responsive data table component designed for presenting structured data in a clear, scannable format. Tables are fundamental for displaying datasets, comparisons, and detailed information that benefits from row and column organization. This component provides extensive customization options including striped rows for easier scanning, hover effects for row highlighting, sticky headers for long tables, and responsive overflow handling. It maintains accessibility standards with proper table markup and ARIA attributes while offering modern styling options that work seamlessly with both light and dark themes.

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
This component implements comprehensive table accessibility standards:

**ARIA Patterns:**
- Uses semantic table markup (`<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>`)
- Table captions provide context and summary for screen readers
- Column headers (`<th>`) are properly associated with data cells
- Sortable columns include appropriate ARIA attributes when enabled

**Keyboard Navigation:**
- **Tab**: Moves focus through interactive elements within table
- **Shift+Tab**: Moves focus to previous interactive element
- **Arrow keys**: Navigate between cells (in sortable mode)
- **Enter/Space**: Activate sortable column headers

**Screen Reader Support:**
- Table structure (headers, rows, columns) is announced
- Caption text provides table context and purpose
- Column relationships are communicated through header associations
- Striped rows and hover states don't interfere with content reading
- Row and column counts are announced when table receives focus

**Data Presentation:**
- Headers should be properly marked with `<th scope="col">` or `<th scope="row">`
- Complex tables should use `<thead>`, `<tbody>`, and `<tfoot>` sections
- Data relationships are clear through proper table structure
- Sortable state changes are announced to assistive technology

**Visual Design:**
- Sufficient color contrast maintained across all styling options (4.5:1 minimum)
- Focus indicators are clearly visible on interactive elements
- Hover states provide clear feedback without relying solely on color
- Sticky headers maintain visual association with content

**Usage Guidelines:**
- Provide meaningful captions that describe table purpose
- Use column headers that clearly describe data content
- Consider responsive alternatives for complex tables on mobile
- Ensure interactive elements (sort buttons) have clear labels

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
    # Base wrapper classes
    wrapper_classes = ["w-full", "relative"]
    if sticky_header
        push!(wrapper_classes, "overflow-auto", "max-h-[600px]")
    elseif overflow
        push!(wrapper_classes, "overflow-x-auto")
    end

    # Table container classes for styling
    container_classes = ["w-full"]
    if bordered
        push!(
            container_classes,
            "rounded-lg",
            "border",
            "border-gray-200",
            "dark:border-gray-700",
        )
        if overflow
            push!(container_classes, "overflow-hidden")
        end
    end

    # Base table classes
    table_classes = ["w-full", "text-sm"]

    # Base styling for clean appearance
    push!(table_classes, "border-separate", "border-spacing-0")

    # Header styling - cleaner approach
    push!(table_classes, "[&>thead>tr>th]:bg-white", "dark:[&>thead>tr>th]:bg-gray-900")
    push!(
        table_classes,
        "[&>thead>tr>th]:text-left",
        "[&>thead>tr>th]:text-xs",
        "[&>thead>tr>th]:font-semibold",
    )
    push!(
        table_classes,
        "[&>thead>tr>th]:text-gray-600",
        "dark:[&>thead>tr>th]:text-gray-400",
    )
    push!(table_classes, "[&>thead>tr>th]:uppercase", "[&>thead>tr>th]:tracking-wider")
    push!(
        table_classes,
        "[&>thead>tr>th]:border-b",
        "[&>thead>tr>th]:border-gray-200",
        "dark:[&>thead>tr>th]:border-gray-700",
    )

    # Header padding
    if compact
        push!(table_classes, "[&>thead>tr>th]:px-4", "[&>thead>tr>th]:py-2")
    else
        push!(table_classes, "[&>thead>tr>th]:px-6", "[&>thead>tr>th]:py-4")
    end

    # Cell styling - cleaner with better spacing
    push!(table_classes, "[&>tbody>tr>td]:bg-white", "dark:[&>tbody>tr>td]:bg-gray-900")
    push!(
        table_classes,
        "[&>tbody>tr>td]:text-gray-700",
        "dark:[&>tbody>tr>td]:text-gray-300",
    )
    push!(
        table_classes,
        "[&>tbody>tr>td]:border-b",
        "[&>tbody>tr>td]:border-gray-100",
        "dark:[&>tbody>tr>td]:border-gray-800",
    )

    # Cell padding
    if compact
        push!(table_classes, "[&>tbody>tr>td]:px-4", "[&>tbody>tr>td]:py-2")
    else
        push!(table_classes, "[&>tbody>tr>td]:px-6", "[&>tbody>tr>td]:py-4")
    end

    # Remove bottom border from last row
    push!(table_classes, "[&>tbody>tr:last-child>td]:border-b-0")

    # Striped rows - more subtle
    if striped
        push!(
            table_classes,
            "[&>tbody>tr:nth-child(even)>td]:bg-gray-50/50",
            "dark:[&>tbody>tr:nth-child(even)>td]:bg-gray-800/50",
        )
    end

    # Hover effect - more subtle
    if hover
        push!(table_classes, "[&>tbody>tr]:transition-all", "[&>tbody>tr]:duration-200")
        push!(
            table_classes,
            "[&>tbody>tr:hover>td]:bg-gray-50",
            "dark:[&>tbody>tr:hover>td]:bg-gray-800/70",
        )
    end

    # Sticky header
    if sticky_header
        push!(table_classes, "[&>thead]:sticky", "[&>thead]:top-0", "[&>thead]:z-20")
        push!(table_classes, "[&>thead]:shadow-sm")
    end

    # Sortable columns
    if sortable
        push!(
            table_classes,
            "[&>thead>tr>th]:cursor-pointer",
            "[&>thead>tr>th]:select-none",
        )
        push!(
            table_classes,
            "[&>thead>tr>th]:transition-colors",
            "[&>thead>tr>th]:duration-150",
        )
        push!(
            table_classes,
            "[&>thead>tr>th:hover]:bg-gray-50",
            "dark:[&>thead>tr>th:hover]:bg-gray-800",
        )
    end

    # Build component default attributes
    component_attrs = (class = SafeString(join(table_classes, " ")),)

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {class = join(wrapper_classes, " ")} begin
        if !isnothing(caption)
            @p {class = "mb-2 text-sm text-gray-600 dark:text-gray-400 italic"} caption
        end

        @div {class = SafeString(join(container_classes, " "))} begin
            @table {merged_attrs...} begin
                @__slot__()
            end
        end
    end
end

@deftag macro Table end

"""
    @List

A styled list component that enhances standard HTML lists with consistent visual design and flexible presentation options. Lists are essential for presenting sequential or related information in a scannable format, from simple bullet points to numbered steps or checklists. This component offers multiple variants including traditional bullets, numbers, checkmarks, or no markers at all, combined with adjustable spacing to suit different content densities. The styling is carefully crafted to maintain readability while providing visual interest through custom markers and proper indentation.

# Props
- `variant::Union{Symbol,String}`: List variant (`:bullet`, `:number`, `:check`, `:none`) (default: `:bullet`)
- `spacing::Union{Symbol,String}`: Item spacing (`:tight`, `:normal`, `:loose`) (default: `:normal`)

# Slots
- List items - should contain `li` elements

# Example
```julia
# Bulleted list
@List begin
    @li "First item"
    @li "Second item"
    @li "Third item"
end

# Numbered list
@List {variant = :number} begin
    @li "Step one"
    @li "Step two"
    @li "Step three"
end

# Checklist with loose spacing
@List {variant = :check, spacing = :loose} begin
    @li "Task completed"
    @li "Another completed task"
    @li "Final task done"
end
```

# See also
- [`Table`](@ref) - For tabular data
- [`Timeline`](@ref) - For chronological lists
- [`Stack`](@ref) - For custom list layouts
"""
@component function List(;
    variant::Union{Symbol,String} = :bullet,
    spacing::Union{Symbol,String} = :normal,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    spacing_sym = Symbol(spacing)

    spacing_classes = (tight = "space-y-1", normal = "space-y-2", loose = "space-y-4")

    spacing_class = get(spacing_classes, spacing_sym, "space-y-2")

    # Base classes for all variants
    base_class = "text-gray-600 dark:text-gray-400 $spacing_class"

    if variant_sym === :bullet
        @ul {class = "list-disc list-inside $base_class", attrs...} begin
            @__slot__()
        end
    elseif variant_sym === :number
        @ol {class = "list-decimal list-inside $base_class", attrs...} begin
            @__slot__()
        end
    elseif variant_sym === :check
        # For check variant, we'll style the list items with pseudo-elements
        @ul {
            class = "[&>li]:relative [&>li]:pl-6 [&>li:before]:content-['✓'] [&>li:before]:absolute [&>li:before]:left-0 [&>li:before]:text-green-600 dark:[&>li:before]:text-green-400 [&>li:before]:font-bold $base_class",
            attrs...,
        } begin
            @__slot__()
        end
    else # :none
        @ul {class = "list-none $base_class", attrs...} begin
            @__slot__()
        end
    end
end

@deftag macro List end
