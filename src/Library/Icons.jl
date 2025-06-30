# Icon components

using HypertextTemplates: SafeString
using ..Library: merge_attrs

"""
    @Icon

Icon wrapper component for consistent sizing and styling.

# Props
- `size::Union{Symbol,String}`: Icon size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `color::Union{String,Nothing}`: Icon color class (optional)
- `name::Union{String,Nothing}`: Icon name for built-in icons (optional)
- `aria_label::Union{String,Nothing}`: ARIA label for interactive icons (optional)
- `decorative::Bool`: Whether icon is purely decorative (default: `true`)
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

    size_classes = Dict(
        :xs => "h-3 w-3",
        :sm => "h-4 w-4",
        :md => "h-5 w-5",
        :lg => "h-6 w-6",
        :xl => "h-8 w-8",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    color_class = isnothing(color) ? "text-current" : color

    # Built-in icons
    icons = Dict(
        "check" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>""",
        "x" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>""",
        "arrow-right" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>""",
        "arrow-left" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>""",
        "chevron-down" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" /></svg>""",
        "chevron-up" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 15l7-7 7 7" /></svg>""",
        "menu" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" /></svg>""",
        "search" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>""",
        "plus" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" /></svg>""",
        "minus" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 12H4" /></svg>""",
        "user" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>""",
        "settings" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" /><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /></svg>""",
        "logout" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" /></svg>""",
        "folder" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" /></svg>""",
        "dots-vertical" => """<svg width="100%" height="100%" fill="currentColor" viewBox="0 0 24 24"><path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z" /></svg>""",
        "dots-horizontal" => """<svg width="100%" height="100%" fill="currentColor" viewBox="0 0 24 24"><path d="M6 10c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm12 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm-6 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z" /></svg>""",
    )

    # Set aria-hidden for decorative icons, or aria-label for interactive ones
    aria_hidden = decorative && isnothing(aria_label) ? "true" : nothing

    @span {
        class = "inline-flex items-center justify-center $size_class $color_class",
        "aria-hidden" = aria_hidden,
        "aria-label" = aria_label,
        attrs...,
    } begin
        if !isnothing(name) && haskey(icons, name)
            @text HypertextTemplates.SafeString(icons[name])
        else
            # Slot for custom icon content
            @__slot__()
        end
    end
end

@deftag macro Icon end
