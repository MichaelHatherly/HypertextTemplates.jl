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

    size_classes = (
        sm = "max-w-screen-sm",
        md = "max-w-screen-md",
        lg = "max-w-screen-lg",
        xl = "max-w-screen-xl",
        var"2xl" = "max-w-screen-2xl",
        full = "max-w-full",
    )

    size_class = get(size_classes, size_sym, "max-w-screen-xl")
    padding_class = padding ? "px-4 sm:px-6 lg:px-8" : ""
    centered_class = centered ? "mx-auto" : ""
    glass_class =
        glass ?
        "backdrop-blur-sm bg-white/80 dark:bg-slate-900/80 rounded-xl shadow-[0_8px_30px_rgba(0,0,0,0.12)] ring-1 ring-black/5 dark:ring-white/5 p-6" :
        ""

    @div {
        class = "$size_class $padding_class $centered_class $glass_class transition-colors duration-150",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Container end
