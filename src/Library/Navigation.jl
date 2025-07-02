# Import required utilities
using HypertextTemplates: SafeString
using ..Library: merge_attrs

"""
    @Breadcrumb

A navigation breadcrumb component that displays the hierarchical path to the current page. Breadcrumbs are crucial wayfinding elements that help users understand their location within a website's structure and provide quick navigation to parent pages. This component automatically handles the visual styling of links versus the current page, includes proper ARIA attributes for accessibility, and uses semantic HTML markup. The customizable separator and responsive text sizing ensure breadcrumbs remain readable and functional across all device sizes.

# Props
- `items::Vector{Tuple{String,String}}`: Breadcrumb items as (href, label) tuples
- `separator::String`: Separator character/string (default: `"/"`)

# Accessibility
This component implements WAI-ARIA breadcrumb navigation pattern:

**ARIA Patterns:**
- Uses `<nav aria-label="Breadcrumb">` for proper navigation identification
- Current page marked with `aria-current="page"` for screen reader context
- Ordered list structure (`<ol>`) conveys hierarchical relationship
- Separators marked with `aria-hidden="true"` to avoid redundant announcements

**Keyboard Navigation:**
- **Tab**: Moves focus through breadcrumb links
- **Shift+Tab**: Moves focus to previous breadcrumb link
- **Enter**: Follows breadcrumb link navigation
- Current page (non-link) is skipped in tab order

**Screen Reader Support:**
- Navigation structure is announced as "breadcrumb navigation"
- Each link's purpose and hierarchy level are communicated
- Current page is identified and distinguished from links
- Separators are treated as visual elements only

**Visual Design:**
- Clear visual hierarchy showing navigation path
- Current page has distinct styling (no link, different color)
- Focus indicators are clearly visible on interactive links
- Sufficient color contrast maintained for all text elements

**Usage Guidelines:**
- Include home/root page as first breadcrumb item
- Use descriptive page titles rather than URLs
- Keep breadcrumb text concise but meaningful
- Consider mobile responsive behavior for long paths
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

A page navigation component that provides intuitive controls for navigating through paginated content. Pagination is essential for managing large datasets by breaking them into digestible chunks, improving both performance and user experience. This component intelligently displays page numbers with ellipsis for large ranges, always shows first and last pages, and includes previous/next navigation buttons. It handles edge cases like disabled states at boundaries and provides proper ARIA labels for screen reader users. The responsive design ensures the pagination remains usable on mobile devices.

# Props
- `current::Int`: Current page number (default: `1`)
- `total::Int`: Total number of pages (default: `1`)
- `siblings::Int`: Number of sibling pages to show (default: `1`)
- `base_url::String`: Base URL for page links (default: `"#"`)

# Accessibility
This component implements comprehensive pagination accessibility:

**ARIA Patterns:**
- Uses `<nav aria-label="Pagination">` for proper navigation identification
- Current page marked with `aria-current="page"` for screen reader context
- Disabled buttons use `aria-disabled="true"` and `aria-label` for state communication
- Page numbers and navigation buttons have descriptive labels

**Keyboard Navigation:**
- **Tab**: Moves focus through pagination controls (Previous → Page Numbers → Next)
- **Shift+Tab**: Moves focus to previous pagination control
- **Enter**: Activates page navigation links
- Disabled controls are properly skipped in tab order

**Screen Reader Support:**
- Pagination structure is announced as "pagination navigation"
- Current page is identified distinctly from other page links
- Previous/Next button states (enabled/disabled) are communicated
- Page numbers include positional context ("Page 3 of 10")
- Ellipsis indicators are treated as visual elements only

**Visual Design:**
- Clear visual distinction between current page and other pages
- Disabled states have reduced opacity and are visually distinct
- Focus indicators are clearly visible with high contrast on all interactive elements
- Sufficient spacing for touch targets on mobile devices

**Usage Guidelines:**
- Provide meaningful `base_url` patterns for SEO and direct access
- Consider mobile responsive behavior for many pages
- Include total count context when helpful ("Page 3 of 10")
- Ensure pagination updates content and focus appropriately
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

An interactive tab navigation component powered by Alpine.js that organizes content into switchable panels. Tabs are powerful UI patterns for presenting related content in a compact space while allowing users to quickly switch between different views. This component manages the active tab state, provides smooth transitions between panels, and ensures proper ARIA attributes for accessibility. The tab interface supports keyboard navigation and maintains the selected state across the session. With customizable styling and responsive behavior, tabs adapt well to different screen sizes and content types.

# Props
- `items::Vector{Tuple{String,String}}`: Tab items as (id, label) tuples
- `active::String`: ID of the active tab (default: first item's ID)
- `aria_label::Union{String,Nothing}`: ARIA label for the tab list (optional)

# Requirements
This component requires Alpine.js for tab switching functionality:

```html
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

**Browser Compatibility:** Modern browsers with ES6 support  
**Dependencies:** Tailwind CSS for styling classes

**Note:** JavaScript assets are loaded automatically via `@__once__` for optimal performance.

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

# Accessibility
This component implements WAI-ARIA tab pattern for accessible content switching:

**ARIA Patterns:**
- Tab buttons use `role="tab"` with proper `aria-controls` associations
- Tab list container uses `role="tablist"` with appropriate `aria-label`
- Each tab maintains `aria-selected` state synchronized with active state
- Tab panels are associated via `id`/`aria-controls` relationships

**Keyboard Navigation:**
- **Arrow Left/Right**: Navigate between tab buttons
- **Home/End**: Jump to first/last tab
- **Enter/Space**: Activate focused tab
- **Tab**: Move focus to tab panel content

**Screen Reader Support:**
- Tab list structure and tab count are announced
- Active tab state changes are communicated
- Tab labels and associated panel content are linked
- Navigation between tabs provides positional feedback

**Focus Management:**
- Focus moves logically between tabs using arrow keys
- Tab activation follows focus (automatic tab switching)
- Focus moves to panel content when Tab key is pressed
- Visual focus indicators are clearly visible on tab buttons

# See also
- [`TabPanel`](@ref) - Tab content panels
- [`DropdownMenu`](@ref) - Alternative navigation pattern
- [`Breadcrumb`](@ref) - For navigation hierarchy
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

A tab panel component designed to work seamlessly within the Tabs container, automatically handling content visibility based on the active tab selection. Each TabPanel represents a distinct content section that appears when its corresponding tab is selected. The component manages smooth transitions between panels using Alpine.js, ensuring a polished user experience. It maintains proper ARIA relationships with tab buttons for accessibility and supports any type of content, from simple text to complex nested components.

# Props
- `id::String`: The tab ID this panel corresponds to (required)
- `class::String`: Additional CSS classes (optional)

# Slots
- Tab panel content - can contain any elements that should be displayed when this tab is active

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

# Accessibility
**ARIA Patterns:**
- Uses `role="tabpanel"` to identify as tab panel content
- Associates with tab button via `aria-controls`/`id` relationship
- Properly hidden/shown based on tab selection state

**Keyboard Navigation:**
- **Tab**: Allows normal tab order through panel content
- **Shift+Tab**: Returns focus to associated tab button
- Panel content participates in normal document tab flow

**Screen Reader Support:**
- Panel visibility changes are announced when tabs switch
- Panel content is only announced when visible
- Maintains semantic relationship with controlling tab
- Panel role and association are communicated to assistive technology

**Content Guidelines:**
- Panel content should start with a heading for structure
- Focus management within panels follows normal document flow
- Interactive elements in panels are keyboard accessible

# See also
- [`Tabs`](@ref) - Parent tabs container
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

A flexible dropdown menu component that creates contextual menus with support for nested submenus, powered by Alpine.js and Alpine Anchor for intelligent positioning. Dropdown menus are versatile UI elements used for navigation, actions, and options that would otherwise clutter the interface. This component provides a complete dropdown system with trigger buttons, menu items, dividers, and even nested submenus for complex hierarchies. It handles click-outside behavior, keyboard navigation, and automatic repositioning to stay within viewport bounds. The menu system coordinates multiple dropdowns on the same page, ensuring only one menu is open at a time.

# Requirements
This component requires Alpine.js and Alpine Anchor for intelligent positioning:

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/anchor@latest/dist/cdn.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

**Browser Compatibility:** Modern browsers with ES6 support  
**Dependencies:** Tailwind CSS for styling classes

**Note:** JavaScript assets are automatically loaded via `@__once__` for optimal performance.

# Accessibility
This component implements WAI-ARIA best practices for dropdown menus:

**ARIA Patterns:**
- Uses `role="menu"` on dropdown content with `aria-orientation="vertical"`
- Menu items have `role="menuitem"` with proper state attributes
- Trigger button uses `aria-haspopup="true"` and `aria-expanded` states
- Supports `aria-label` and `aria-describedby` for additional context

**Keyboard Navigation:**
- **Escape**: Closes dropdown and returns focus to trigger
- **Arrow Down/Up**: Navigate between menu items
- **Home/End**: Jump to first/last menu item
- **Enter/Space**: Activate menu item or trigger
- **Tab**: Move focus outside dropdown (closes menu)

**Screen Reader Support:**
- Menu state changes are announced ("expanded"/"collapsed")
- Menu items are read with their role and position
- Keyboard navigation is announced as users move through options
- Submenu relationships are properly communicated

**Focus Management:**
- Focus returns to trigger when menu closes
- Focus moves to first menu item when opened via keyboard
- Focus is trapped within dropdown during navigation
- Visual focus indicators are clearly visible

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Slots
- Should contain exactly one @DropdownTrigger and one @DropdownContent component

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

# See also
- [`DropdownTrigger`](@ref) - Dropdown trigger component
- [`DropdownContent`](@ref) - Dropdown content container
- [`DropdownItem`](@ref) - Individual menu items
- [`DropdownSubmenu`](@ref) - Nested dropdown menus
- [`Button`](@ref) - Common trigger element
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

The trigger element for dropdown menus that wraps any clickable element to control menu visibility. This component transforms its child element into an interactive trigger that opens the associated dropdown content on click. It automatically manages ARIA attributes for accessibility, including expanded state and menu ownership. The trigger can wrap various elements like buttons, links, or custom components, making it flexible for different design needs. It coordinates with the parent DropdownMenu to handle proper focus management and state synchronization.

# Props
- `attrs...`: Additional attributes passed to the wrapper

# Slots
- Clickable element that triggers the dropdown (typically a Button)

# Example
```julia
@DropdownTrigger begin
    @Button {variant = :secondary} "Menu"
end
```

# Accessibility
**ARIA Patterns:**
- Uses `aria-haspopup="true"` to indicate dropdown relationship
- Maintains `aria-expanded` state synchronized with dropdown visibility
- Properly associates trigger with dropdown content via ARIA

**Keyboard Navigation:**
- **Enter/Space**: Opens dropdown and moves focus to first item
- **Arrow Down**: Opens dropdown and moves focus to first item
- **Escape**: Closes dropdown (handled by parent DropdownMenu)

**Screen Reader Support:**
- Button role and expanded state are announced
- Changes in dropdown state are communicated
- Maintains semantic relationship with dropdown content

# See also
- [`DropdownMenu`](@ref) - Parent dropdown container
- [`DropdownContent`](@ref) - Dropdown content that appears
- [`Button`](@ref) - Common trigger element
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

The container for dropdown menu items that appears when the dropdown is triggered, providing the visual menu panel. This component creates a floating panel that positions itself intelligently relative to the trigger using Alpine Anchor, automatically adjusting to stay within viewport bounds. It manages the menu's appearance with smooth transitions, handles keyboard navigation between items, and provides proper focus management. The content container supports various menu patterns including simple lists, grouped items with dividers, and complex layouts with nested submenus.

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Slots
- Dropdown menu items - should contain @DropdownItem, @DropdownDivider, and @DropdownSubmenu components

# Example
```julia
@DropdownContent begin
    @DropdownItem {href = "/profile"} "Profile"
    @DropdownItem {href = "/settings"} "Settings"
    @DropdownDivider
    @DropdownSubmenu {label = "More"} begin
        @DropdownItem "Option 1"
        @DropdownItem "Option 2"
    end
end
```

# Accessibility
**ARIA Patterns:**
- Uses `role="menu"` with `aria-orientation="vertical"`
- Maintains focus management within menu boundaries
- Provides proper ARIA relationships with trigger element

**Keyboard Navigation:**
- **Arrow Down/Up**: Navigate between menu items
- **Home/End**: Jump to first/last menu item
- **Escape**: Close dropdown and return focus to trigger
- **Tab**: Exit dropdown and continue normal tab order
- **Enter/Space**: Activate focused menu item

**Screen Reader Support:**
- Menu structure and item count are announced
- Navigation between items provides positional feedback
- Item states (selected, disabled) are communicated
- Menu open/close state changes are announced

**Focus Management:**
- Focus moves to first item when opened via keyboard
- Focus is trapped within menu during navigation
- Focus returns to trigger when menu closes
- Visual focus indicators are clearly visible on all items

# See also
- [`DropdownMenu`](@ref) - Parent dropdown container
- [`DropdownItem`](@ref) - Menu items
- [`DropdownDivider`](@ref) - Visual separator
- [`DropdownSubmenu`](@ref) - Nested menus
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

An individual menu item within dropdown menus that represents a selectable action or navigation option. Dropdown items are the core interactive elements of any menu, supporting various states like hover, disabled, and different semantic variants (default, danger, success). They can function as either buttons for actions or links for navigation, include optional icons for visual clarity, and maintain consistent styling across different uses. The component ensures proper keyboard accessibility and provides visual feedback through smooth hover transitions.

# Props
- `href::Union{String,Nothing}`: Optional link URL
- `disabled::Bool`: Whether item is disabled (default: `false`)
- `icon::Union{String,Nothing}`: Optional icon name
- `variant::Symbol`: Item variant (`:default`, `:danger`, `:success`)
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Slots
- Menu item text or content

# Example
```julia
# Basic item
@DropdownItem "Settings"

# Link item with icon
@DropdownItem {href = "/profile", icon = "user"} "My Profile"

# Danger variant
@DropdownItem {variant = :danger} "Delete Account"

# Disabled item
@DropdownItem {disabled = true} "Coming Soon"
```

# Accessibility
**ARIA Patterns:**
- Uses `role="menuitem"` for proper menu item semantics
- Maintains disabled state with `aria-disabled` when applicable
- Supports focus and selection states for screen readers

**Keyboard Navigation:**
- **Enter/Space**: Activates the menu item action
- **Arrow Down/Up**: Navigate to next/previous menu item (handled by parent)
- All items participate in menu's keyboard navigation flow

**Screen Reader Support:**
- Item text and any icons are announced together
- Disabled state is communicated when applicable
- Item type (link vs button) is announced appropriately
- Variant states (danger, success) are conveyed through color contrast

**Visual Design:**
- Sufficient color contrast for all variants (4.5:1 minimum)
- Focus indicators are clearly visible and distinct
- Disabled items have reduced opacity and pointer events disabled
- Hover states provide clear interactive feedback

# See also
- [`DropdownContent`](@ref) - Parent content container
- [`DropdownSubmenu`](@ref) - For nested items
- [`DropdownDivider`](@ref) - For separating items
- [`Icon`](@ref) - For item icons
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
    elseif variant === :danger
        "text-red-600 hover:bg-red-50 hover:text-red-700 dark:text-red-400 dark:hover:bg-red-950/20 dark:hover:text-red-300"
    elseif variant === :success
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

A nested submenu component that creates hierarchical flyout menus within dropdowns for organizing complex menu structures. Submenus are essential for creating multi-level navigation without overwhelming users with too many options at once. This component manages its own open state while coordinating with the parent dropdown, positions itself to the side of the parent menu item, and includes visual indicators like chevrons to show that it contains nested options. The submenu supports the same rich content as regular dropdown menus, enabling deep menu hierarchies while maintaining usability.

# Props
- `label::String`: The label for the submenu trigger
- `icon::Union{String,Nothing}`: Optional icon name
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes

# Slots
- Submenu items - typically @DropdownItem components

# Example
```julia
@DropdownSubmenu {label = "Export As"} begin
    @DropdownItem {icon = "document"} "PDF"
    @DropdownItem {icon = "file"} "CSV"
    @DropdownItem {icon = "code"} "JSON"
end
```

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

# Accessibility
**ARIA Patterns:**
- Nested menu structure maintains proper ARIA hierarchy
- Submenu trigger indicates expandable content to screen readers
- Parent-child menu relationships are properly established

**Keyboard Navigation:**
- **Arrow Right**: Opens submenu and moves focus to first item
- **Arrow Left**: Closes submenu and returns focus to trigger
- **Escape**: Closes all menus and returns to root trigger
- Full keyboard navigation through nested menu levels

**Screen Reader Support:**
- Submenu structure and nesting level are announced
- Menu expansion state changes are communicated
- Navigation between menu levels provides clear feedback
- Chevron indicators are marked as decorative (`aria-hidden`)

**Focus Management:**
- Focus moves logically between menu levels
- Submenu focus is trapped until closed or escaped
- Focus returns to parent menu item when submenu closes
- Visual focus indicators work across all nesting levels

# See also
- [`DropdownMenu`](@ref) - Root dropdown component
- [`DropdownContent`](@ref) - Parent content container
- [`DropdownItem`](@ref) - Menu items within submenu
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
