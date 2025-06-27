"""
    @Divider

Horizontal or vertical separator component.

# Props
- `orientation::Union{Symbol,String}`: Divider orientation (`:horizontal`, `:vertical`) (default: `:horizontal`)
- `spacing::Union{String,Nothing}`: Custom spacing class (optional)
- `color::Union{String,Nothing}`: Border color class (optional)
"""
@component function Divider(;
    orientation::Union{Symbol,String} = :horizontal,
    spacing::Union{String,Nothing} = nothing,
    color::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbol
    orientation_sym = Symbol(orientation)

    default_spacing = orientation_sym == :horizontal ? "my-4" : "mx-4"
    spacing_class = isnothing(spacing) ? default_spacing : spacing
    color_class = isnothing(color) ? "border-slate-200 dark:border-slate-800" : color

    if orientation_sym == :horizontal
        @hr {class="border-t $color_class $spacing_class", attrs...}
    else
        @div {
            class="inline-block min-h-[1em] w-0.5 self-stretch bg-slate-200 dark:bg-slate-800 $spacing_class",
            attrs...,
        }
    end
end

@deftag macro Divider end

"""
    @Avatar

User profile image component.

# Props
- `src::Union{String,Nothing}`: Image source URL (optional)
- `alt::String`: Alternative text (default: "Avatar")
- `size::Union{Symbol,String}`: Avatar size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `shape::Union{Symbol,String}`: Avatar shape (`:circle`, `:square`) (default: `:circle`)
- `fallback::Union{String,Nothing}`: Fallback content when no src provided (optional)
"""
@component function Avatar(;
    src::Union{String,Nothing} = nothing,
    alt::String = "Avatar",
    size::Union{Symbol,String} = :md,
    shape::Union{Symbol,String} = :circle,
    fallback::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    shape_sym = Symbol(shape)

    size_classes = Dict(
        :xs => "h-6 w-6 text-xs",
        :sm => "h-8 w-8 text-sm",
        :md => "h-10 w-10 text-base",
        :lg => "h-12 w-12 text-lg",
        :xl => "h-16 w-16 text-xl",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    shape_class = shape_sym == :circle ? "rounded-full" : "rounded-lg"

    @div {
        class="relative inline-block $size_class $shape_class overflow-hidden bg-slate-100 dark:bg-slate-800",
        attrs...,
    } begin
        if !isnothing(src)
            @img {src=src, alt=alt, class="h-full w-full object-cover"}
        else
            # Fallback content
            @div {
                class="flex h-full w-full items-center justify-center font-medium text-slate-600 dark:text-slate-400",
            } begin
                if !isnothing(fallback)
                    fallback
                else
                    # Default user icon
                    HypertextTemplates.SafeString(
                        """<svg class="h-1/2 w-1/2" fill="currentColor" viewBox="0 0 24 24"><path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" /></svg>""",
                    )
                end
            end
        end
    end
end

@deftag macro Avatar end

"""
    @Icon

Icon wrapper component for consistent sizing and styling.

# Props
- `size::Union{Symbol,String}`: Icon size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `color::Union{String,Nothing}`: Icon color class (optional)
- `name::Union{String,Nothing}`: Icon name for built-in icons (optional)
"""
@component function Icon(;
    size::Union{Symbol,String} = :md,
    color::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
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
        "check" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>""",
        "x" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>""",
        "arrow-right" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>""",
        "arrow-left" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>""",
        "chevron-down" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" /></svg>""",
        "chevron-up" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 15l7-7 7 7" /></svg>""",
        "menu" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" /></svg>""",
        "search" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>""",
        "plus" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" /></svg>""",
        "minus" => """<svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 12H4" /></svg>""",
    )

    @span {
        class="inline-flex items-center justify-center $size_class $color_class",
        attrs...,
    } begin
        if !isnothing(name) && haskey(icons, name)
            HypertextTemplates.SafeString(icons[name])
        else
            # Slot for custom icon content
            @__slot__()
        end
    end
end

@deftag macro Icon end
