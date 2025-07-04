"""
    @Section

A semantic section component with consistent vertical spacing for page structure. Section provides a standardized way to divide your page into distinct content areas with appropriate padding and optional background colors. It helps maintain visual hierarchy and breathing room between different parts of your page, making it perfect for hero sections, feature showcases, content blocks, and any logical grouping of related information.

# Props
- `spacing::Union{Symbol,String}`: Vertical spacing size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `background::Union{String,Nothing}`: Background color class (optional)

# Slots
- Section content

# Example
```julia
# Hero section
@Section {spacing = :lg, background = "bg-gray-50 dark:bg-gray-900"} begin
    @Container begin
        @Heading {level = 1} "Welcome to our site"
        @Text {variant = :lead} "Discover amazing features"
    end
end

# Content section
@Section begin
    @Container begin
        @Grid {cols = 1, md = 2} begin
            @div "Feature 1"
            @div "Feature 2"
        end
    end
end
```

# See also
- [`Container`](@ref) - For constraining content within sections
- [`Stack`](@ref) - For organizing section content
- [`Grid`](@ref) - For section grid layouts
"""
@component function Section(;
    spacing::Union{Symbol,String} = :md,
    background::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbol
    spacing_sym = Symbol(spacing)

    spacing_classes = (
        sm = "py-8 sm:py-12",
        md = "py-12 sm:py-16 md:py-20",
        lg = "py-16 sm:py-20 md:py-24 lg:py-32",
    )

    spacing_class = get(spacing_classes, spacing_sym, "py-12 sm:py-16 md:py-20")
    bg_class = isnothing(background) ? "" : background

    @section {class = "$spacing_class $bg_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Section end
