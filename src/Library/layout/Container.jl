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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbol
    size_sym = Symbol(size)

    # Direct theme access
    base_class = theme.container.base
    size_class = theme.container.sizes[size_sym]
    padding_class = padding ? theme.container.padding : ""
    centered_class = centered ? theme.container.centered : ""
    glass_class = glass ? theme.container.glass : ""

    @div {
        class = "$size_class $padding_class $centered_class $glass_class $base_class",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Container end
