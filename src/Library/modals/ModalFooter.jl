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
    # Convert to symbol
    justify_sym = Symbol(justify)

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract modal_footer theme safely
    modal_footer_theme = if isa(theme, NamedTuple) && haskey(theme, :modal_footer)
        theme.modal_footer
    else
        HypertextTemplates.Library.default_theme().modal_footer
    end

    # Get classes
    base_class = get(
        modal_footer_theme,
        :base,
        HypertextTemplates.Library.default_theme().modal_footer.base,
    )

    # Get justify class with fallback
    justify_class =
        if haskey(modal_footer_theme, :justify) &&
           haskey(modal_footer_theme.justify, justify_sym)
            modal_footer_theme.justify[justify_sym]
        else
            HypertextTemplates.Library.default_theme().modal_footer.justify[justify_sym]
        end

    @div {class = "$base_class $justify_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro ModalFooter end
