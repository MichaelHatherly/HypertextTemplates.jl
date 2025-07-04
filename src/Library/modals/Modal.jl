"""
    @Modal

A modal dialog component built on the native HTML `<dialog>` element with enhanced functionality for displaying content that requires user attention while temporarily blocking page interaction.

# Props
- `id::String`: Unique identifier for the modal (optional, auto-generated if not provided)
- `size::Union{Symbol,String}`: Modal size (`:sm`, `:md`, `:lg`, `:xl`, `:fullscreen`) (default: `:md`)
- `persistent::Bool`: Prevent closing on backdrop click (default: `false`)
- `show_close::Bool`: Show close button in top-right (default: `true`)

# Slots
- Modal content - typically contains ModalHeader, ModalContent, and ModalFooter components

# Example
```julia
# Basic modal with trigger
@ModalTrigger {target = "example-modal"} begin
    @Button "Open Modal"
end

@Modal {id = "example-modal"} begin
    @ModalHeader "Dialog Title"
    @ModalContent begin
        @Text "Modal content goes here."
    end
    @ModalFooter begin
        @Button {var"@click" = "close()"} "Close"
    end
end

# Persistent modal (no backdrop close)
@Modal {id = "persistent-modal", persistent = true} begin
    @ModalContent "This modal requires explicit close action."
end

# Large modal without close button
@Modal {id = "large-modal", size = :lg, show_close = false} begin
    @ModalContent "Large modal content."
end
```

# Accessibility
**ARIA:** Uses native `<dialog>` semantics with automatic focus trapping and keyboard navigation.

**Keyboard:** Escape key closes modal, Tab cycles through focusable elements, Enter activates buttons.

**Focus Management:** Automatically focuses first interactive element on open, returns focus to trigger on close.

**Screen Reader:** Native dialog role and content are properly announced.

# See also
- [`ModalTrigger`](@ref) - Button to open modals
- [`ModalContent`](@ref) - Modal body content
- [`ModalHeader`](@ref) - Modal header with title
- [`ModalFooter`](@ref) - Modal footer with actions
- [`DrawerModal`](@ref) - Slide-in drawer variant

**Note:** Requires Alpine.js for enhanced functionality. Browser support: Chrome 37+, Firefox 98+, Safari 15.4+. JavaScript assets are loaded automatically.
"""
@component function Modal(;
    id::String = "",
    size::Union{Symbol,String} = :md,
    persistent::Bool = false,
    show_close::Bool = true,
    attrs...,
)
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Inject CSS variables if theme provides them
    if haskey(theme.modal, :css_vars)
        @__once__ #="modal-theme-vars"=# begin
            @style @text SafeString(
                """
    :root {
        $(join(["$k: $v;" for (k,v) in pairs(theme.modal.css_vars)], "\n                    "))
    }
""",
            )
        end
    end

    # Load JavaScript and CSS once per render
    @__once__ begin
        @script @text SafeString(read(joinpath(@__DIR__, "../assets/modal.js"), String))
        @style @text SafeString(read(joinpath(@__DIR__, "../assets/modal.css"), String))
    end

    # Generate unique ID if not provided
    modal_id =
        isempty(id) ?
        "modal-" * string(hash(string(size, persistent, show_close)), base = 16)[1:8] : id

    # Configuration object for Alpine.js
    config = SafeString("""{
        persistent: $(persistent ? "true" : "false"),
        returnFocus: true
    }""")

    # Convert size to symbol
    size_sym = Symbol(size)

    # Direct theme access
    size_class = theme.modal.sizes[size_sym]
    dialog_classes = theme.modal.dialog
    content_base = theme.modal.content
    content_classes = "$content_base $size_class"
    close_button_classes = theme.modal.close_button

    @dialog {
        id = modal_id,
        var"x-data" = SafeString("modal($config)"),
        var"x-ref" = "dialog",
        var"@keydown" = "handleKeydown",
        class = dialog_classes,
        attrs...,
    } begin
        @div {class = content_classes} begin
            # Close button (conditional)
            if show_close
                @button {
                    type = "button",
                    var"@click" = "close()",
                    class = close_button_classes,
                    "aria-label" = "Close modal",
                } begin
                    @Icon {name = "x", size = :md}
                end
            end

            # Modal content slot
            @__slot__()
        end
    end
end

@deftag macro Modal end
