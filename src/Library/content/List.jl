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

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract list theme safely
    list_theme = if isa(theme, NamedTuple) && haskey(theme, :list)
        theme.list
    else
        HypertextTemplates.Library.default_theme().list
    end

    # Get base classes
    base_classes =
        get(list_theme, :base, HypertextTemplates.Library.default_theme().list.base)

    # Get spacing class with fallback
    spacing_class =
        if haskey(list_theme, :spacing) && haskey(list_theme.spacing, spacing_sym)
            list_theme.spacing[spacing_sym]
        else
            HypertextTemplates.Library.default_theme().list.spacing[spacing_sym]
        end

    # Get variant class with fallback
    variant_class =
        if haskey(list_theme, :variants) && haskey(list_theme.variants, variant_sym)
            list_theme.variants[variant_sym]
        else
            HypertextTemplates.Library.default_theme().list.variants[variant_sym]
        end

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
