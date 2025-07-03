# Import required utilities
using HypertextTemplates: SafeString
using HypertextTemplates.Elements: @dialog
using ..Library: merge_attrs

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
        @script @text SafeString(read(joinpath(@__DIR__, "assets/modal.js"), String))
        @style @text SafeString(read(joinpath(@__DIR__, "assets/modal.css"), String))
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
    content_classes = "relative p-0 bg-white dark:bg-gray-800 rounded-lg shadow-xl border border-gray-200 dark:border-gray-700 max-h-[90vh] overflow-hidden $size_class"

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
                    class = "absolute top-4 right-4 z-10 p-2 text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300 transition-colors duration-200",
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

"""
    @ModalTrigger

A button component that opens a modal dialog when clicked, inheriting all standard Button functionality with added modal triggering capability.

# Props
- `target::String`: ID of the modal to open (required)
- `variant::Union{Symbol,String}`: Button variant (default: `:secondary`)
- `size::Union{Symbol,String}`: Button size (default: `:base`)
- All other standard Button props (disabled, loading, etc.)

# Slots
- Button content - text, icons, or other elements

# Example
```julia
@ModalTrigger {target = "my-modal", variant = :primary} "Open Modal"

@ModalTrigger {target = "confirm-dialog", variant = :danger, size = :sm} "Delete Item"

# With icon
@ModalTrigger {target = "settings-modal"} begin
    @Icon {name = "cog"}
    @text " Settings"
end
```

# Accessibility
**ARIA:** Uses `aria-haspopup="dialog"` and `aria-controls` to indicate modal relationship.

**Keyboard:** Enter and Space activate the trigger, same as standard button behavior.

# See also
- [`Modal`](@ref) - The modal component to trigger
- [`Button`](@ref) - Base button component with all available props
"""
@component function ModalTrigger(;
    target::String,
    variant::Union{Symbol,String} = :secondary,
    size::Union{Symbol,String} = :base,
    attrs...,
)
    # Build the onclick handler with proper string interpolation
    onclick_handler =
        "window.dispatchEvent(new CustomEvent('modal-open', { detail: { id: '" *
        target *
        "' } }))"

    # Pass through to Button component with the onclick handler
    @Button {
        variant = variant,
        size = size,
        var"onclick" = onclick_handler,
        var"aria-haspopup" = "dialog",
        var"aria-controls" = target,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro ModalTrigger end

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
    justify_classes = Dict(
        :start => "justify-start",
        :center => "justify-center",
        :end => "justify-end",
        :between => "justify-between",
    )

    justify_class = get(justify_classes, Symbol(justify), justify_classes[:end])

    @div {
        class = "px-6 py-4 border-t border-gray-200 dark:border-gray-700 flex items-center gap-3 $justify_class",
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro ModalFooter end

"""
    @DrawerModal

A modal that slides in from the edge of the screen, ideal for navigation menus, settings panels, or secondary content that benefits from a slide-in presentation.

# Props
- `id::String`: Unique identifier for the modal (required)
- `position::Union{Symbol,String}`: Slide direction (`:left`, `:right`, `:top`, `:bottom`) (default: `:right`)
- `size::Union{Symbol,String}`: Drawer size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `persistent::Bool`: Prevent closing on backdrop click (default: `false`)

# Slots
- Drawer content - typically contains ModalHeader and ModalContent components

# Example
```julia
# Right-side drawer (default)
@DrawerModal {id = "settings-drawer", size = :lg} begin
    @ModalHeader "Settings"
    @ModalContent begin
        @Text "Settings content here..."
    end
end

# Left-side navigation drawer
@DrawerModal {id = "nav-drawer", position = :left} begin
    @ModalContent begin
        @nav begin
            @Link {href = "/"} "Home"
            @Link {href = "/about"} "About"
            @Link {href = "/contact"} "Contact"
        end
    end
end

# Bottom drawer for mobile-friendly forms
@DrawerModal {id = "filter-drawer", position = :bottom} begin
    @ModalHeader "Filter Options"
    @ModalContent begin
        @FormGroup {label = "Sort By"} begin
            @Select {options = [("date", "Date"), ("name", "Name")]}
        end
    end
end
```

# Accessibility
**ARIA:** Uses native `<dialog>` semantics with automatic focus trapping.

**Keyboard:** Escape closes drawer, Tab cycles through focusable elements.

**Touch:** Designed for mobile interaction with proper touch targets.

# See also
- [`Modal`](@ref) - Standard centered modal
- [`ModalHeader`](@ref) - Drawer header section
- [`ModalContent`](@ref) - Drawer body content
- [`ModalTrigger`](@ref) - Button to open drawers

**Note:** Requires Alpine.js. Drawer corners are sharp (no rounding) for edge-to-edge appearance.
"""
@component function DrawerModal(;
    id::String,
    position::Union{Symbol,String} = :right,
    size::Union{Symbol,String} = :md,
    persistent::Bool = false,
    attrs...,
)
    # Position classes for different slide directions
    position_classes = Dict(
        :left => Dict(
            :container => "items-stretch justify-start",
            :drawer => "h-full max-h-none my-0 ml-0 rounded-none",
            :sizes => Dict(:sm => "max-w-xs", :md => "max-w-sm", :lg => "max-w-md"),
        ),
        :right => Dict(
            :container => "items-stretch justify-end",
            :drawer => "h-full max-h-none my-0 mr-0 rounded-none",
            :sizes => Dict(:sm => "max-w-xs", :md => "max-w-sm", :lg => "max-w-md"),
        ),
        :top => Dict(
            :container => "items-start justify-center",
            :drawer => "w-full max-w-none mx-0 mt-0 rounded-none",
            :sizes => Dict(:sm => "max-h-48", :md => "max-h-64", :lg => "max-h-80"),
        ),
        :bottom => Dict(
            :container => "items-end justify-center",
            :drawer => "w-full max-w-none mx-0 mb-0 rounded-none",
            :sizes => Dict(
                :sm => "max-h-[50vh]",
                :md => "max-h-[60vh]",
                :lg => "max-h-[70vh]",
            ),
        ),
    )

    pos_config = get(position_classes, Symbol(position), position_classes[:right])
    size_class = get(pos_config[:sizes], Symbol(size), pos_config[:sizes][:md])

    # Load JavaScript and CSS once per render
    @__once__ begin
        @script @text SafeString(read(joinpath(@__DIR__, "assets/modal.js"), String))
        @style @text SafeString(read(joinpath(@__DIR__, "assets/drawer-modal.css"), String))
    end

    # Configuration object for Alpine.js
    config = SafeString("""{
        persistent: $(persistent ? "true" : "false"),
        returnFocus: true
    }""")

    # Add position-specific class for CSS targeting
    position_class = "drawer-" * string(position)

    @dialog {
        id = id,
        var"x-data" = SafeString("modal($config)"),
        var"x-ref" = "dialog",
        var"@keydown" = "handleKeydown",
        class = "drawer-modal $position_class fixed inset-0 z-[10001] w-full h-full bg-transparent flex $(pos_config[:container])",
        attrs...,
    } begin
        @div {
            class = "relative bg-white dark:bg-gray-800 shadow-xl border-0 $(pos_config[:drawer]) $size_class flex flex-col",
        } begin
            # Close button
            @button {
                type = "button",
                var"@click" = "close()",
                class = "absolute top-4 right-4 z-10 p-2 text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300 transition-colors duration-200",
                "aria-label" = "Close drawer",
            } begin
                @Icon {name = "x", size = :md}
            end

            # Drawer content slot with overflow
            @div {class = "overflow-y-auto flex-1"} begin
                @__slot__()
            end
        end
    end
end

@deftag macro DrawerModal end
