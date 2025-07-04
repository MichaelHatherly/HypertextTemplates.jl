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
**ARIA:** Uses `role="tabpanel"` with proper `aria-controls`/`id` relationships.

**Keyboard:** Normal tab order through panel content, Shift+Tab returns to tab button.

**Guidelines:** Panel content should start with a heading for structure.

# See also
- [`Tabs`](@ref) - Parent tabs container
"""
@component function TabPanel(; id::String, class::String = "", attrs...)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract tab_panel theme safely
    tab_panel_theme = if isa(theme, NamedTuple) && haskey(theme, :tab_panel)
        theme.tab_panel
    else
        HypertextTemplates.Library.default_theme().tab_panel
    end

    # Get base class with fallback
    base_class = get(
        tab_panel_theme,
        :base,
        HypertextTemplates.Library.default_theme().tab_panel.base,
    )

    # Combine base class with user-provided class
    final_class =
        isempty(base_class) ? class : (isempty(class) ? base_class : "$base_class $class")

    # Build component attributes with Alpine.js directives
    component_attrs = (
        id = "tabpanel-$id",
        role = "tabpanel",
        var"x-show" = "activeTab === '$id'",
        var"x-transition:enter" = "transition ease-out duration-150",
        var"x-transition:enter-start" = "opacity-0",
        var"x-transition:enter-end" = "opacity-100",
        class = final_class,
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        @__slot__()
    end
end

@deftag macro TabPanel end
