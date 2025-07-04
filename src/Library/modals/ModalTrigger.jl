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
