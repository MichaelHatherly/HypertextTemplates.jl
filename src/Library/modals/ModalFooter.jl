"""
    @ModalFooter

A footer section for modal dialogs containing action buttons with consistent styling and flexible layout options.

# Props
- `justify::Union{Symbol,String}`: Button alignment (`:start`, `:center`, `:end`, `:between`) (default: `:end`)

# Slots
- Footer content - typically buttons or button groups

# Example
```julia
@ModalFooter begin
    @Button {variant = :secondary, var"@click" = "close()"} "Cancel"
    @Button {variant = :primary} "Save Changes"
end

# Center-aligned buttons
@ModalFooter {justify = :center} begin
    @Button "Understood"
end

# Space-between layout
@ModalFooter {justify = :between} begin
    @Button {variant = :ghost} "Learn More"
    @div {class = "space-x-3"} begin
        @Button {variant = :secondary} "Cancel"
        @Button {variant = :primary} "Continue"
    end
end
```

# See also
- [`Modal`](@ref) - Parent modal component
- [`ModalHeader`](@ref) - Modal header section
- [`ModalContent`](@ref) - Modal body section
- [`Button`](@ref) - Action buttons for footer
"""
@component function ModalFooter(; justify::Union{Symbol,String} = :end, attrs...)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbol
    justify_sym = Symbol(justify)

    # Direct theme access
    base_class = theme.modal_footer.base
    justify_class = theme.modal_footer.justify[justify_sym]

    @div {class = "$base_class $justify_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro ModalFooter end
