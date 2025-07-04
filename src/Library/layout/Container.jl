"""
    @Container

A responsive container component that constrains content width and provides consistent padding. This component serves as the primary layout wrapper for page content, ensuring readable line lengths and appropriate spacing across different screen sizes. It automatically centers content and applies responsive breakpoints to maintain optimal viewing experiences from mobile devices to large desktop displays.

# Props
- `size::Union{Symbol,String}`: Container size (`:sm`, `:md`, `:lg`, `:xl`, `"2xl"`, `:full`) (default: `:xl`)
- `padding::Bool`: Whether to include horizontal padding (default: `true`)
- `centered::Bool`: Whether to center the container (default: `true`)
- `role::Union{String,Nothing}`: ARIA role for the container (e.g., "main") (optional)
- `glass::Bool`: Whether to apply glassmorphism effect (default: `false`)

# Slots
- Content to be contained within the responsive wrapper

# Example
```julia
@Container {size = :lg} begin
    @Heading "Welcome"
    @Text "This content is constrained to a large container width."
end

# With glass effect
@Container {glass = true, size = :md} begin
    @Card "Glassmorphic content"
end
```

# See also
- [`Section`](@ref) - For page sections with vertical spacing
- [`Stack`](@ref) - For stacking elements with consistent gaps
- [`Grid`](@ref) - For grid-based layouts
"""
@component function Container(;
    size::Union{Symbol,String} = :xl,
    padding::Bool = true,
    centered::Bool = true,
    role::Union{String,Nothing} = nothing,
    glass::Bool = false,
    attrs...,
)
    # Convert to symbol
    size_sym = Symbol(size)

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract container theme safely
    container_theme = if isa(theme, NamedTuple) && haskey(theme, :container)
        theme.container
    else
        HypertextTemplates.Library.default_theme().container
    end

    # Get base classes
    base_class = get(
        container_theme,
        :base,
        HypertextTemplates.Library.default_theme().container.base,
    )

    # Get size class with fallback
    size_class =
        if haskey(container_theme, :sizes) && haskey(container_theme.sizes, size_sym)
            container_theme.sizes[size_sym]
        else
            HypertextTemplates.Library.default_theme().container.sizes[size_sym]
        end

    # Get conditional classes
    padding_class =
        padding ?
        get(
            container_theme,
            :padding,
            HypertextTemplates.Library.default_theme().container.padding,
        ) : ""
    centered_class =
        centered ?
        get(
            container_theme,
            :centered,
            HypertextTemplates.Library.default_theme().container.centered,
        ) : ""
    glass_class =
        glass ?
        get(
            container_theme,
            :glass,
            HypertextTemplates.Library.default_theme().container.glass,
        ) : ""

    @div {
        class = "$size_class $padding_class $centered_class $glass_class $base_class",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Container end
