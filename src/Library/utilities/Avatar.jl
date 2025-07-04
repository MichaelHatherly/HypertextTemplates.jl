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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract avatar theme safely
    avatar_theme = if isa(theme, NamedTuple) && haskey(theme, :avatar)
        theme.avatar
    else
        HypertextTemplates.Library.default_theme().avatar
    end

    # Get base classes and content
    base_class =
        get(avatar_theme, :base, HypertextTemplates.Library.default_theme().avatar.base)
    image_class =
        get(avatar_theme, :image, HypertextTemplates.Library.default_theme().avatar.image)
    fallback_container_class = get(
        avatar_theme,
        :fallback_container,
        HypertextTemplates.Library.default_theme().avatar.fallback_container,
    )
    default_icon = get(
        avatar_theme,
        :default_icon,
        HypertextTemplates.Library.default_theme().avatar.default_icon,
    )

    # Get nested themes
    sizes_theme = if isa(avatar_theme, NamedTuple) && haskey(avatar_theme, :sizes)
        avatar_theme.sizes
    else
        HypertextTemplates.Library.default_theme().avatar.sizes
    end

    shapes_theme = if isa(avatar_theme, NamedTuple) && haskey(avatar_theme, :shapes)
        avatar_theme.shapes
    else
        HypertextTemplates.Library.default_theme().avatar.shapes
    end

    backgrounds_theme =
        if isa(avatar_theme, NamedTuple) && haskey(avatar_theme, :backgrounds)
            avatar_theme.backgrounds
        else
            HypertextTemplates.Library.default_theme().avatar.backgrounds
        end

    # Convert to symbols
    size_sym = Symbol(size)
    shape_sym = Symbol(shape)

    size_class = get(
        sizes_theme,
        size_sym,
        get(sizes_theme, :md, HypertextTemplates.Library.default_theme().avatar.sizes.md),
    )
    shape_class = get(
        shapes_theme,
        shape_sym,
        get(
            shapes_theme,
            :circle,
            HypertextTemplates.Library.default_theme().avatar.shapes.circle,
        ),
    )

    # Default background color for fallback avatars
    default_bg = if !isnothing(src)
        get(
            backgrounds_theme,
            :with_image,
            HypertextTemplates.Library.default_theme().avatar.backgrounds.with_image,
        )
    else
        get(
            backgrounds_theme,
            :fallback,
            HypertextTemplates.Library.default_theme().avatar.backgrounds.fallback,
        )
    end

    # Build component default attributes
    component_attrs = (class = "$base_class $size_class $shape_class $default_bg",)

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        if !isnothing(src)
            # Require meaningful alt text for images
            if isnothing(alt)
                error("Avatar: alt text is required when src is provided")
            end
            @img {src = src, alt = alt, class = image_class}
        else
            # Fallback content
            @div {class = fallback_container_class} begin
                if !isnothing(fallback)
                    @text fallback
                else
                    # Default user icon
                    @text HypertextTemplates.SafeString(default_icon)
                end
            end
        end
    end
end

@deftag macro Avatar end
