"""
    @ModalContent

The main content area of a modal dialog, providing proper spacing and scrolling behavior for body content.

# Props
- `scrollable::Bool`: Allow content to scroll if it exceeds modal height (default: `true`)

# Slots
- Modal body content - any components, text, forms, or other elements

# Example
```julia
@Modal {id = "example"} begin
    @ModalContent begin
        @Text "Your modal content here."
        @Text "Can include multiple paragraphs."
    end
end

# Non-scrollable content
@ModalContent {scrollable = false} begin
    @Text "Fixed height content."
end
```

# See also
- [`Modal`](@ref) - Parent modal component
- [`ModalHeader`](@ref) - Modal header section
- [`ModalFooter`](@ref) - Modal footer section
"""
@component function ModalContent(; scrollable::Bool = true, attrs...)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract modal_content theme safely
    modal_content_theme = if isa(theme, NamedTuple) && haskey(theme, :modal_content)
        theme.modal_content
    else
        HypertextTemplates.Library.default_theme().modal_content
    end

    # Get classes
    base_class = get(
        modal_content_theme,
        :base,
        HypertextTemplates.Library.default_theme().modal_content.base,
    )
    scroll_class =
        scrollable ?
        get(
            modal_content_theme,
            :scrollable,
            HypertextTemplates.Library.default_theme().modal_content.scrollable,
        ) :
        get(
            modal_content_theme,
            :fixed,
            HypertextTemplates.Library.default_theme().modal_content.fixed,
        )

    @div {class = "$base_class $scroll_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro ModalContent end
