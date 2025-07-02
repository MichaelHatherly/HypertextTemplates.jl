# Icon components

using HypertextTemplates: SafeString
using ..Library: merge_attrs

# Module-level icon cache to avoid repeated file I/O
const ICON_CACHE = Dict{String,Union{String,Nothing}}()

function load_icon(name::String)
    # Check cache first
    haskey(ICON_CACHE, name) && return ICON_CACHE[name]

    # Try to load from file
    icon_path = joinpath(@__DIR__, "assets", "icons", "$name.svg")
    if isfile(icon_path)
        icon_content = read(icon_path, String)
        ICON_CACHE[name] = icon_content
        return icon_content
    end

    # Cache the miss to avoid repeated file checks
    ICON_CACHE[name] = nothing
    return nothing
end

"""
    @Icon

A flexible icon component that supports both built-in icons and custom SVG content. Icons are essential visual elements that enhance user interfaces by providing quick visual recognition of actions, states, and categories. This component offers a comprehensive library of built-in icons covering common UI needs, while also allowing custom SVG content for specialized requirements. With consistent sizing options and color inheritance, icons integrate seamlessly into buttons, links, navigation elements, and standalone contexts. The component ensures proper accessibility through ARIA attributes, making icons work well for both decorative and interactive purposes.

# Props
- `size::Union{Symbol,String}`: Icon size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `color::Union{String,Nothing}`: Icon color class (optional)
- `name::Union{String,Nothing}`: Icon name for built-in icons (optional)
- `aria_label::Union{String,Nothing}`: ARIA label for interactive icons (optional)
- `decorative::Bool`: Whether icon is purely decorative (default: `true`)

# Slots
- Custom SVG content - used when `name` prop is not provided or when the named icon is not found

# Available Icons
Icons are loaded from SVG files in the `assets/icons/` directory. Available icons include:
- Navigation: home, arrow-up/down/left/right, chevron-up/down/left/right, external-link
- Actions: edit, trash, save, download, upload, copy, refresh
- Communication: mail, phone, chat
- Media: play, pause, stop, camera, image
- Status: info, info-circle, warning, exclamation-triangle, error, x-circle, question, bell, check-circle
- Files: file, document, code
- UI Controls: filter, sort, grid, list, eye, eye-off, lock, unlock
- Time: calendar, clock
- E-commerce: cart, credit-card, tag
- Social: heart, star, bookmark, share
- UI: check, x, plus, minus, menu, search, user, settings, logout, folder, dots-vertical, dots-horizontal, spinner

# Example
```julia
# Using a built-in icon
@Icon {name = "check", size = :lg}
@Icon {name = "heart", color = "text-red-500"}

# Interactive icon with ARIA label
@Icon {name = "trash", aria_label = "Delete item", decorative = false}

# Custom SVG icon
@Icon {size = :xl, color = "text-purple-500"} begin
    @svg {viewBox = "0 0 24 24", fill = "currentColor"} begin
        @path {d = "M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"}
    end
end

# Fallback when icon not found
@Icon {name = "nonexistent"} begin
    @text "?"  # Fallback content
end
```

# See also
- [`Button`](@ref) - Commonly used with icons
- [`Link`](@ref) - For icon links
- [`Badge`](@ref) - Can contain icons
- [`DropdownItem`](@ref) - Supports icon props
"""
@component function Icon(;
    size::Union{Symbol,String} = :md,
    color::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    aria_label::Union{String,Nothing} = nothing,
    decorative::Bool = true,
    attrs...,
)
    # Convert to symbol
    size_sym = Symbol(size)

    size_classes =
        (xs = "h-3 w-3", sm = "h-4 w-4", md = "h-5 w-5", lg = "h-6 w-6", xl = "h-8 w-8")

    size_class = get(size_classes, size_sym, size_classes.md)
    color_class = isnothing(color) ? "text-current" : color

    # Set aria-hidden for decorative icons, or aria-label for interactive ones
    aria_hidden = decorative && isnothing(aria_label) ? "true" : nothing

    @span {
        class = "inline-flex items-center justify-center $size_class $color_class",
        "aria-hidden" = aria_hidden,
        "aria-label" = aria_label,
        attrs...,
    } begin
        if !isnothing(name)
            icon_svg = load_icon(name)
            if !isnothing(icon_svg)
                @text SafeString(icon_svg)
            else
                # Icon not found - render nothing or fall back to slot
                @__slot__()
            end
        else
            # No name provided - use slot for custom icon content
            @__slot__()
        end
    end
end

@deftag macro Icon end
