# Icon components

using HypertextTemplates: SafeString
using ..Library: merge_attrs

# Module-level icon cache to avoid repeated file I/O
const ICON_CACHE = Dict{String,Union{String,Nothing}}()

"""
    load_icon(name::String) -> Union{String, Nothing}

Load an icon SVG from the filesystem with caching.
Returns the SVG content or nothing if the icon doesn't exist.
"""
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

Icon wrapper component for consistent sizing and styling.

# Props
- `size::Union{Symbol,String}`: Icon size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `color::Union{String,Nothing}`: Icon color class (optional)
- `name::Union{String,Nothing}`: Icon name for built-in icons (optional)
- `aria_label::Union{String,Nothing}`: ARIA label for interactive icons (optional)
- `decorative::Bool`: Whether icon is purely decorative (default: `true`)

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

# Usage
```julia
# Using a built-in icon
@Icon {name="check", size=:lg}

# Using a custom SVG
@Icon {size=:sm, color="text-blue-500"} begin
    @svg {viewBox="0 0 24 24"} begin
        # Custom SVG content
    end
end
```
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
