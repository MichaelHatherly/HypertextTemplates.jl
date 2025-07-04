"""
    @DropdownDivider

Visual separator between dropdown items.

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes
"""
@component function DropdownDivider(; class::String = "", attrs...)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract dropdown_divider theme safely
    dropdown_divider_theme = if isa(theme, NamedTuple) && haskey(theme, :dropdown_divider)
        theme.dropdown_divider
    else
        HypertextTemplates.Library.default_theme().dropdown_divider
    end

    # Get base class with fallback
    base_class = get(
        dropdown_divider_theme,
        :base,
        HypertextTemplates.Library.default_theme().dropdown_divider.base,
    )

    # Combine base class with user-provided class
    final_class = "$base_class $class"

    component_attrs = (class = final_class, role = "separator")

    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...}
end

@deftag macro DropdownDivider end
