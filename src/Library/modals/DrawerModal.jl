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
        @script @text SafeString(read(joinpath(@__DIR__, "../assets/modal.js"), String))
        @style @text SafeString(
            read(joinpath(@__DIR__, "../assets/drawer-modal.css"), String),
        )
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
            class = "relative bg-white dark:bg-slate-800 shadow-[0_8px_30px_rgba(0,0,0,0.12)] border-0 $(pos_config[:drawer]) $size_class flex flex-col",
        } begin
            # Close button
            @button {
                type = "button",
                var"@click" = "close()",
                class = "absolute top-4 right-4 z-10 p-2 text-slate-400 hover:text-slate-600 dark:text-slate-500 dark:hover:text-slate-300 transition-colors duration-150",
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
