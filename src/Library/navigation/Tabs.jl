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
**ARIA:** Uses `role="tab"`, `role="tablist"`, and `aria-controls` with proper `aria-selected` states.

**Keyboard:** Arrow Left/Right navigate tabs, Home/End jump to first/last, Tab moves to panel content.

**Focus Management:** Automatic tab switching follows focus with clear visual indicators.

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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract tabs theme safely
    tabs_theme = if isa(theme, NamedTuple) && haskey(theme, :tabs)
        theme.tabs
    else
        HypertextTemplates.Library.default_theme().tabs
    end

    # Get all theme values with fallbacks
    container_class = get(
        tabs_theme,
        :container,
        HypertextTemplates.Library.default_theme().tabs.container,
    )
    panels_container_class = get(
        tabs_theme,
        :panels_container,
        HypertextTemplates.Library.default_theme().tabs.panels_container,
    )

    # Nav theme
    nav_theme = if isa(tabs_theme, NamedTuple) && haskey(tabs_theme, :nav)
        tabs_theme.nav
    else
        HypertextTemplates.Library.default_theme().tabs.nav
    end
    nav_base_class =
        get(nav_theme, :base, HypertextTemplates.Library.default_theme().tabs.nav.base)
    aria_label_default = get(
        nav_theme,
        :aria_label_default,
        HypertextTemplates.Library.default_theme().tabs.nav.aria_label_default,
    )

    # Button theme
    button_theme = if isa(tabs_theme, NamedTuple) && haskey(tabs_theme, :button)
        tabs_theme.button
    else
        HypertextTemplates.Library.default_theme().tabs.button
    end
    button_base_class = get(
        button_theme,
        :base,
        HypertextTemplates.Library.default_theme().tabs.button.base,
    )
    button_active_class = get(
        button_theme,
        :active,
        HypertextTemplates.Library.default_theme().tabs.button.active,
    )
    button_inactive_class = get(
        button_theme,
        :inactive,
        HypertextTemplates.Library.default_theme().tabs.button.inactive,
    )

    # Use first item as active if not specified
    active_id = isempty(active) && !isempty(items) ? items[1][1] : active

    # Build component default attributes with Alpine.js
    component_attrs = if isempty(container_class)
        (var"x-data" = SafeString("{ activeTab: '$(active_id)' }"),)
    else
        (var"x-data" = SafeString("{ activeTab: '$(active_id)' }"), class = container_class)
    end

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @nav {
            class = nav_base_class,
            "aria-label" = isnothing(aria_label) ? aria_label_default : aria_label,
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
                        """activeTab === '$id' ? '$(button_base_class) $(button_active_class)' : '$(button_base_class) $(button_inactive_class)'""",
                    ),
                    ":aria-selected" = "activeTab === '$id'",
                } $label
            end
        end

        # Tab panels container
        @div {class = panels_container_class} begin
            # The slot should contain @TabPanel components
            @__slot__()
        end
    end
end

@deftag macro Tabs end
