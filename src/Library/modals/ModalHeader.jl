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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract modal_header theme safely
    modal_header_theme = if isa(theme, NamedTuple) && haskey(theme, :modal_header)
        theme.modal_header
    else
        HypertextTemplates.Library.default_theme().modal_header
    end

    # Get classes
    base_class = get(
        modal_header_theme,
        :base,
        HypertextTemplates.Library.default_theme().modal_header.base,
    )
    title_class = get(
        modal_header_theme,
        :title,
        HypertextTemplates.Library.default_theme().modal_header.title,
    )
    subtitle_class = get(
        modal_header_theme,
        :subtitle,
        HypertextTemplates.Library.default_theme().modal_header.subtitle,
    )

    @div {class = base_class, attrs...} begin
        # Always wrap content in proper styling
        @div {class = title_class} begin
            @__slot__()
        end
        if !isnothing(subtitle)
            @Text {size = :sm, class = subtitle_class} $subtitle
        end
    end
end

@deftag macro ModalHeader end
