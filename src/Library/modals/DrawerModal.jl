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
    # Convert to symbols
    position_sym = Symbol(position)
    size_sym = Symbol(size)

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Inject CSS variables if theme provides them
    if haskey(theme.drawer_modal, :css_vars)
        @__once__ #="drawer-theme-vars"=# begin
            @style @text SafeString(
                """
    :root {
        $(join(["$k: $v;" for (k,v) in pairs(theme.drawer_modal.css_vars)], "\n                    "))
    }
""",
            )
        end
    end

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

    # Position classes for different slide directions
    position_classes = Dict(
        :left => Dict(
            :container => "items-stretch justify-start",
            :drawer => "h-full max-h-none my-0 ml-0 rounded-none",
            :sizes => Dict(:sm => "w-64", :md => "w-80", :lg => "w-96"),
        ),
        :right => Dict(
            :container => "items-stretch justify-end",
            :drawer => "h-full max-h-none my-0 mr-0 rounded-none",
            :sizes => Dict(:sm => "w-64", :md => "w-80", :lg => "w-96"),
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

    pos_config = get(position_classes, position_sym, position_classes[:right])

    # Direct theme access
    size_class = get(theme.drawer_modal.sizes, size_sym, get(pos_config[:sizes], size_sym, pos_config[:sizes][:md]))
    dialog_classes = theme.drawer_modal.dialog
    content_classes = theme.drawer_modal.content
    close_position = theme.drawer_modal.positions[position_sym].close_position
    close_button_base = theme.drawer_modal.close_button
    close_button_classes = replace(close_button_base, "right-4" => close_position)

    # Add position-specific class for CSS targeting
    position_class = "drawer-" * string(position)

    @dialog {
        id = id,
        var"x-data" = SafeString("modal($config)"),
        var"x-ref" = "dialog",
        var"@keydown" = "handleKeydown",
        class = "drawer-modal $position_class fixed inset-0 z-[10001] w-full h-full $dialog_classes flex $(pos_config[:container])",
        attrs...,
    } begin
        @div {
            class = "relative $content_classes border-0 $(pos_config[:drawer]) $size_class flex flex-col",
        } begin
            # Close button
            @button {
                type = "button",
                var"@click" = "close()",
                class = close_button_classes,
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
