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
        class = "px-6 py-4 border-t border-slate-200 dark:border-slate-700 flex items-center gap-3 $justify_class",
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro ModalFooter end
