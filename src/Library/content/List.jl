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
    base_class = "text-slate-600 dark:text-slate-400 $spacing_class"

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
            class = "[&>li]:relative [&>li]:pl-6 [&>li:before]:content-['✓'] [&>li:before]:absolute [&>li:before]:left-0 [&>li:before]:text-emerald-600 dark:[&>li:before]:text-emerald-400 [&>li:before]:font-bold $base_class",
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
