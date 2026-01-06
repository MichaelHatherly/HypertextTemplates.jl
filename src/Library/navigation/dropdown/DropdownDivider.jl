"""
    @DropdownDivider

Visual separator between dropdown items.

# Props
- `class::String`: Additional CSS classes
- `attrs...`: Additional attributes
"""
@component function DropdownDivider(; class::String = "", attrs...)
    component_attrs =
        (class = "my-1 h-px bg-slate-200 dark:bg-slate-700 $class", role = "separator")

    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...}
end

@deftag macro DropdownDivider end
