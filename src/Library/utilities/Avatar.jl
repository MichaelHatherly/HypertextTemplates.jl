"""
    @Avatar

A user profile image component that displays user avatars with automatic fallbacks and consistent styling. Avatars are essential for personalizing user interfaces, making them feel more human and helping users quickly identify accounts, authors, or participants in conversations. This component handles the common challenges of avatar display including missing images, different aspect ratios, and the need for fallback representations. It provides multiple size options and shape variants (circular or square) while ensuring images load smoothly and fallbacks appear gracefully when no image is available.

# Props
- `src::Union{String,Nothing}`: Image source URL (optional)
- `alt::String`: Alternative text (required when src is provided, ignored otherwise)
- `size::Union{Symbol,String}`: Avatar size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `shape::Union{Symbol,String}`: Avatar shape (`:circle`, `:square`) (default: `:circle`)
- `fallback::Union{String,Nothing}`: Fallback content when no src provided (optional)
"""
@component function Avatar(;
    src::Union{AbstractString,Nothing} = nothing,
    alt::Union{AbstractString,Nothing} = nothing,
    size::Union{Symbol,String} = :md,
    shape::Union{Symbol,String} = :circle,
    fallback::Union{AbstractString,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    shape_sym = Symbol(shape)

    size_classes = (
        xs = "h-6 w-6 text-xs",
        sm = "h-8 w-8 text-sm",
        md = "h-10 w-10 text-base",
        lg = "h-12 w-12 text-lg",
        xl = "h-16 w-16 text-xl",
    )

    size_class = get(size_classes, size_sym, size_classes.md)
    shape_class = shape_sym === :circle ? "rounded-full" : "rounded-lg"

    # Default background color for fallback avatars
    default_bg = if !isnothing(src)
        "bg-slate-100 dark:bg-slate-800"
    else
        "bg-blue-500 dark:bg-blue-600"
    end

    # Build component default attributes
    component_attrs = (
        class = "relative inline-flex $size_class $shape_class overflow-hidden $default_bg",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        if !isnothing(src)
            # Require meaningful alt text for images
            if isnothing(alt)
                error("Avatar: alt text is required when src is provided")
            end
            @img {src = src, alt = alt, class = "h-full w-full object-cover"}
        else
            # Fallback content
            @div {
                class = "flex h-full w-full items-center justify-center font-medium text-white",
            } begin
                if !isnothing(fallback)
                    @text fallback
                else
                    # Default user icon
                    @text HypertextTemplates.SafeString(
                        """<svg class="h-1/2 w-1/2" fill="currentColor" viewBox="0 0 24 24"><path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" /></svg>""",
                    )
                end
            end
        end
    end
end

@deftag macro Avatar end
