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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbols
    variant_sym = Symbol(variant)
    spacing_sym = Symbol(spacing)

    # Direct theme access
    base_classes = theme.list.base
    spacing_class = theme.list.spacing[spacing_sym]
    variant_class = theme.list.variants[variant_sym]

    # Build final classes
    final_classes = "$variant_class $base_classes $spacing_class"

    if variant_sym === :bullet
        @ul {class = final_classes, attrs...} begin
            @__slot__()
        end
    elseif variant_sym === :number
        @ol {class = final_classes, attrs...} begin
            @__slot__()
        end
    else # :check or :none
        @ul {class = final_classes, attrs...} begin
            @__slot__()
        end
    end
end

@deftag macro List end
