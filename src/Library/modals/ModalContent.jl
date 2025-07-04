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
    scroll_class = scrollable ? "overflow-y-auto" : "overflow-hidden"

    @div {class = "p-6 $scroll_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro ModalContent end
