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

"""
    @DropdownMenu

Flexible dropdown menu component with support for nested submenus powered by Alpine Anchor.

# Requirements
This component requires Alpine.js and the Alpine Anchor plugin:
```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/anchor@latest/dist/cdn.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Usage
```julia
@DropdownMenu begin
    @DropdownTrigger begin
        @Button "Options" {variant=:secondary}
    end

    @DropdownContent begin
        @DropdownItem {href="/profile"} "Profile"
        @DropdownItem {href="/settings"} "Settings"
        @DropdownDivider
        @DropdownItem {variant=:danger} "Logout"
    end
end
```
"""
@component function DropdownMenu(; class::String = "", attrs...)
    # Load JavaScript and CSS for dropdown functionality
    @__once__ begin
        @script @text SafeString(read(joinpath(@__DIR__, "assets/dropdown.js"), String))
        # CSS for x-cloak to ensure hidden elements don't affect layout
        @style @text "[x-cloak] { display: none !important; }"
    end

    # Build Alpine.js data configuration
    # Uses Alpine.data reference pattern.
    alpine_data = SafeString("""dropdown()""")

    # Build component attributes
    # Event handlers use method calls defined in the Alpine.data component:
    # - @keydown.escape: Calls close() method
    # - @click.outside: Calls handleClickOutside() method for clicks completely outside container
    # - @click: Calls handleContainerClick() to handle clicks within the container that aren't
    #          on the trigger or content (e.g., empty space to the right of the button)
    # - @dropdown-open.window: Calls handleDropdownOpen() for dropdown coordination
    # 
    # The @click handler is crucial for proper UX: without it, clicking empty space within
    # the dropdown container wouldn't close the dropdown, which feels broken to users.
    component_attrs = (
        class = "inline-block text-left $class",
        var"x-data" = alpine_data,
        var"data-dropdown" = "true",
        var"@keydown.escape" = "close()",
        var"@click.outside" = "handleClickOutside",
        var"@click" = "handleContainerClick(\$event)",
        var"@dropdown-open.window" = "handleDropdownOpen",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro DropdownMenu end

"""
    @DropdownTrigger

Trigger element for dropdown menu. Can contain any clickable element.

# Props
- `attrs...`: Additional attributes passed to the wrapper
"""
@component function DropdownTrigger(; attrs...)
    component_attrs = (
        var"x-ref" = "trigger",
        var"@click" = "toggle()",
        var":aria-expanded" = "open",
        var"aria-haspopup" = "true",
        class = "inline-block",
    )

    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro DropdownTrigger end

"""
    @DropdownContent

Container for dropdown menu items.

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes
"""
@component function DropdownContent(; class::String = "", attrs...)
    # Hardcoded positioning: bottom-start with automatic flipping to top if no space
    # Alpine Anchor with Floating UI handles the automatic repositioning
    component_attrs = (
        var"x-ref" = "content",
        var"x-show" = "open",
        var"x-cloak" = "",
        var"x-anchor.bottom-start.offset.4" = "\$refs.trigger ? \$refs.trigger : null",
        var"x-transition:enter" = "transition ease-out duration-100",
        var"x-transition:enter-start" = "transform opacity-0 scale-95",
        var"x-transition:enter-end" = "transform opacity-100 scale-100",
        var"x-transition:leave" = "transition ease-in duration-75",
        var"x-transition:leave-start" = "transform opacity-100 scale-100",
        var"x-transition:leave-end" = "transform opacity-0 scale-95",
        var"@keydown" = "handleKeydown(\$event)",
        var"@focus" = "focusFirstItem",
        class = "absolute z-[9999] min-w-[12rem] rounded-lg border border-gray-200 bg-white shadow-lg dark:border-gray-700 dark:bg-gray-800 py-1 $class",
        role = "menu",
        var"aria-orientation" = "vertical",
        tabindex = "-1",
    )

    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro DropdownContent end

"""
    @DropdownItem

Individual menu item within dropdown.

# Props
- `href::Union{String,Nothing}`: Optional link URL
- `disabled::Bool`: Whether item is disabled (default: `false`)
- `icon::Union{String,Nothing}`: Optional icon name
- `variant::Symbol`: Item variant (`:default`, `:danger`, `:success`)
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes
"""
@component function DropdownItem(;
    href::Union{String,Nothing} = nothing,
    disabled::Bool = false,
    icon::Union{String,Nothing} = nothing,
    variant::Symbol = :default,
    class::String = "",
    attrs...,
)
    # Base classes
    base_classes = "block w-full text-left px-4 py-2 text-sm transition-colors duration-150"

    # Variant classes
    variant_classes = if disabled
        "text-gray-400 cursor-not-allowed dark:text-gray-500"
    elseif variant == :danger
        "text-red-600 hover:bg-red-50 hover:text-red-700 dark:text-red-400 dark:hover:bg-red-950/20 dark:hover:text-red-300"
    elseif variant == :success
        "text-green-600 hover:bg-green-50 hover:text-green-700 dark:text-green-400 dark:hover:bg-green-950/20 dark:hover:text-green-300"
    else
        "text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700"
    end

    # Combine classes
    item_class = "$base_classes $variant_classes $class"

    # Build component attributes
    component_attrs = (class = item_class, role = "menuitem", disabled = disabled)

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    # Render as link or button
    if !isnothing(href) && !disabled
        @a {href = href, merged_attrs...} begin
            if !isnothing(icon)
                @span {class = "inline-flex items-center gap-2"} begin
                    @Icon {name = icon, size = :sm}
                    @__slot__()
                end
            else
                @__slot__()
            end
        end
    else
        @button {type = "button", merged_attrs...} begin
            if !isnothing(icon)
                @span {class = "inline-flex items-center gap-2"} begin
                    @Icon {name = icon, size = :sm}
                    @__slot__()
                end
            else
                @__slot__()
            end
        end
    end
end

@deftag macro DropdownItem end

"""
    @DropdownDivider

Visual separator between dropdown items.

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes
"""
@component function DropdownDivider(; class::String = "", attrs...)
    component_attrs =
        (class = "my-1 h-px bg-gray-200 dark:bg-gray-700 $class", role = "separator")

    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...}
end

@deftag macro DropdownDivider end

"""
    @DropdownSubmenu

Simple submenu component that works within the parent dropdown's Alpine context.

# Props
- `label::String`: The label for the submenu trigger
- `icon::Union{String,Nothing}`: Optional icon name
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Implementation Notes
The submenu uses Alpine Anchor for positioning. The key to making this work is the
x-anchor directive on the submenu content, which references its trigger button using
`\$el.previousElementSibling`. This works because:

1. The DOM structure places the trigger button immediately before the submenu content
2. `\$el` in the x-anchor context refers to the element with the directive (submenu content)
3. `previousElementSibling` reliably points to the trigger button
4. This avoids complex ref lookups that can fail due to Alpine scope boundaries

The submenu state is managed by the parent dropdown's Alpine component through the
`openSubmenus` object, allowing multiple submenus to be open simultaneously.
"""
@component function DropdownSubmenu(;
    label::AbstractString,
    icon::Union{AbstractString,Nothing} = nothing,
    class::AbstractString = "",
    attrs...,
)
    # Generate unique ID for this submenu to track its open/closed state
    submenu_id = "submenu-$(hash(label))"

    @div {class = "relative", "data-submenu-id" = submenu_id} begin
        # Trigger button - must come first in DOM for x-anchor to work
        @button {
            type = "button",
            class = "block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700 transition-colors duration-150 flex items-center justify-between",
            "@click" = "toggleSubmenu('$submenu_id', \$event)",
            "x-ref" = "submenu_trigger_$submenu_id",  # Ref is kept for potential future use
        } begin
            @span {class = "flex items-center gap-2"} begin
                if !isnothing(icon)
                    @Icon {name = icon, size = :sm}
                end
                @text label
            end
            # Chevron icon
            @text SafeString(
                """<svg class="w-4 h-4 ml-auto" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" /></svg>""",
            )
        end

        # Submenu content - positioned using Alpine Anchor
        # IMPORTANT: This div MUST come immediately after the trigger button in the DOM
        # for the x-anchor positioning to work correctly.
        @div {
            "x-ref" = "submenu_content_$submenu_id",
            "x-show" = "isSubmenuOpen('$submenu_id')",
            "x-cloak" = "",
            # Critical: x-anchor uses $el.previousElementSibling to find the trigger button
            # This works because:
            # 1. $el refers to this submenu content div
            # 2. previousElementSibling gets the immediately preceding element (the button above)
            # 3. Alpine Anchor then positions this div relative to that button
            # 4. The SafeString wrapper preserves the $ character from being escaped
            "x-anchor.right-start.offset.4" = SafeString("\$el.previousElementSibling"),
            "x-transition:enter" = "transition ease-out duration-100",
            "x-transition:enter-start" = "transform opacity-0 scale-95",
            "x-transition:enter-end" = "transform opacity-100 scale-100",
            "x-transition:leave" = "transition ease-in duration-75",
            "x-transition:leave-start" = "transform opacity-100 scale-100",
            "x-transition:leave-end" = "transform opacity-0 scale-95",
            class = "absolute z-[10000] min-w-[12rem] rounded-lg border border-gray-200 bg-white shadow-lg dark:border-gray-700 dark:bg-gray-800 py-1 $class",
            role = "menu",
            "@click.stop" = "",  # Prevent clicks from bubbling up
        } begin
            @__slot__()
        end
    end
end

@deftag macro DropdownSubmenu end
