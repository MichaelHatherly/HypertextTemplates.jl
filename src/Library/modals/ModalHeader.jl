"""
    @ModalHeader

A header section for modal dialogs containing the title and optional subtitle with consistent styling and spacing.

# Props
- `subtitle::Union{String,Nothing}`: Optional subtitle text (default: `nothing`)

# Slots
- Header content - typically plain text for title, or custom elements

# Example
```julia
@ModalHeader "Confirm Action"

@ModalHeader {subtitle = "This action cannot be undone"} "Delete Item"

# Custom header content
@ModalHeader begin
    @Heading {level = 2} "Custom Header"
    @Badge {variant = :warning} "Beta"
end
```

# See also
- [`Modal`](@ref) - Parent modal component
- [`ModalContent`](@ref) - Modal body section
- [`ModalFooter`](@ref) - Modal footer section
"""
@component function ModalHeader(; subtitle::Union{String,Nothing} = nothing, attrs...)
    @div {class = "px-6 py-4 border-b border-gray-200 dark:border-gray-700", attrs...} begin
        # Always wrap content in proper styling
        @div {class = "text-xl font-semibold text-gray-900 dark:text-gray-100"} begin
            @__slot__()
        end
        if !isnothing(subtitle)
            @Text {size = :sm, class = "mt-1 text-gray-600 dark:text-gray-400"} $subtitle
        end
    end
end

@deftag macro ModalHeader end
