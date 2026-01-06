"""
    @Card

A versatile content container with customizable styling, borders, and shadows. Cards provide clean visual separation for grouped content and can be used for content blocks, product listings, user profiles, or dashboard widgets.

# Props
- `padding::Union{Symbol,String}`: Padding size (`:none`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `shadow::Union{Symbol,String}`: Shadow type (`:none`, `:sm`, `:base`, `:md`, `:lg`) (default: `:sm`)
- `border::Bool`: Whether to show border (default: `true`)
- `rounded::Union{Symbol,String}`: Border radius (`:none`, `:sm`, `:base`, `:lg`) (default: `:base`)
- `variant::Union{Symbol,String}`: Card variant (`:default`, `:elevated`) (default: `:default`)
- `hoverable::Bool`: Whether card has hover effects (default: `false`)

# Slots
- Card content - can be any elements like text, images, buttons, or other components

# Example
```julia
# Basic card
@Card begin
    @Heading {level = 3} "Card Title"
    @Text "This is the card content."
    @Button {variant = :primary} "Action"
end

# Hoverable card
@Card {hoverable = true} begin
    @Text "Hover over me!"
end

# Elevated card
@Card {variant = :elevated, shadow = :md} begin
    @Badge "New"
    @Text "Elevated card"
end
```

# See also
- [`Badge`](@ref) - For status indicators within cards
- [`Alert`](@ref) - For notification messages
- [`Container`](@ref) - For page-level containers
- [`Stack`](@ref) - For arranging multiple cards
"""
@component function Card(;
    padding::Union{Symbol,String} = :base,
    shadow::Union{Symbol,String} = :sm,
    border::Bool = true,
    rounded::Union{Symbol,String} = :base,
    variant::Union{Symbol,String} = :default,
    hoverable::Bool = false,
    attrs...,
)
    # Convert to symbols
    padding_sym = Symbol(padding)
    shadow_sym = Symbol(shadow)
    rounded_sym = Symbol(rounded)
    variant_sym = Symbol(variant)

    padding_classes = (none = "", sm = "p-4", base = "p-5", lg = "p-6", xl = "p-8")

    # Refined shadow scale with precise values
    shadow_classes = (
        none = "",
        sm = "shadow-[0_1px_3px_rgba(0,0,0,0.06),0_1px_2px_rgba(0,0,0,0.04)]",
        base = "shadow-[0_1px_3px_rgba(0,0,0,0.06),0_1px_2px_rgba(0,0,0,0.04)]",
        md = "shadow-[0_4px_6px_-1px_rgba(0,0,0,0.05),0_2px_4px_-2px_rgba(0,0,0,0.03)]",
        lg = "shadow-[0_8px_16px_-4px_rgba(0,0,0,0.08),0_4px_6px_-2px_rgba(0,0,0,0.03)]",
    )

    # Restrained radius scale
    rounded_classes = (none = "", sm = "rounded", base = "rounded-lg", lg = "rounded-xl")

    variant_classes =
        (default = "bg-white dark:bg-slate-900", elevated = "bg-white dark:bg-slate-800")

    padding_class = get(padding_classes, padding_sym, padding_classes.base)
    shadow_class = get(shadow_classes, shadow_sym, shadow_classes.sm)
    rounded_class = get(rounded_classes, rounded_sym, rounded_classes.base)
    variant_class = get(variant_classes, variant_sym, variant_classes.default)
    border_class = border ? "border border-slate-200 dark:border-slate-800" : ""

    # Subtle hover effect - just shadow increase, no transform
    hover_class =
        hoverable ?
        "transition-shadow duration-200 hover:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.08),0_4px_6px_-2px_rgba(0,0,0,0.03)]" :
        ""

    @div {
        class = "$variant_class $padding_class $shadow_class $border_class $rounded_class $hover_class",
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Card end
