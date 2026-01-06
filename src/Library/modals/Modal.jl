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

    # Size classes
    size_classes = Dict(
        :sm => "max-w-sm",
        :md => "max-w-md",
        :lg => "max-w-lg",
        :xl => "max-w-xl",
        :fullscreen => "max-w-none w-full h-full m-0",
    )

    size_class = get(size_classes, Symbol(size), size_classes[:md])

    # Dialog styling - ensure proper centering and sizing
    dialog_classes = "p-0 bg-transparent backdrop:bg-black/50 backdrop:backdrop-blur-sm"
    content_classes = "relative p-0 bg-white dark:bg-slate-800 rounded-lg shadow-[0_8px_30px_rgba(0,0,0,0.12)] border border-slate-200 dark:border-slate-700 max-h-[90vh] overflow-hidden $size_class"

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
                    class = "absolute top-4 right-4 z-10 p-2 text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-slate-300 transition-colors duration-150",
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
