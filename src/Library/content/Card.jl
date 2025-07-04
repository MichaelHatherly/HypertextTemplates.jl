"""
    @Card

A versatile content container with customizable styling, borders, and shadows. Cards provide clean visual separation for grouped content and can be used for content blocks, product listings, user profiles, or dashboard widgets.

# Props
- `padding::Union{Symbol,String}`: Padding size (`:none`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `shadow::Union{Symbol,String}`: Shadow type (`:none`, `:sm`, `:base`, `:lg`, `:colored`) (default: `:base`)
- `border::Union{Bool,Symbol}`: Border style (`true`, `false`, `:gradient`) (default: `true`)
- `rounded::Union{Symbol,String}`: Border radius (`:none`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:lg`)
- `variant::Union{Symbol,String}`: Card variant (`:default`, `:glass`, `:gradient`) (default: `:default`)
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

# Hoverable card with gradient border
@Card {border = :gradient, hoverable = true} begin
    @Text "Hover over me!"
end

# Glass morphism card
@Card {variant = :glass, shadow = :lg} begin
    @Badge "New"
    @Text "Glass effect card"
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
    shadow::Union{Symbol,String} = :base,
    border::Union{Bool,Symbol} = true,
    rounded::Union{Symbol,String} = :lg,
    variant::Union{Symbol,String} = :default,
    hoverable::Bool = false,
    attrs...,
)
    # Convert to symbols
    padding_sym = Symbol(padding)
    shadow_sym = Symbol(shadow)
    rounded_sym = Symbol(rounded)
    variant_sym = Symbol(variant)
    border_sym = border isa Symbol ? border : (border ? :default : :none)

    padding_classes = (
        none = "",
        sm = "p-3 md:p-4",
        base = "p-5 md:p-6",
        md = "p-5 md:p-6",  # For backward compatibility
        lg = "p-6 md:p-8",
        xl = "p-8 md:p-10",
    )

    shadow_classes = (
        none = "",
        sm = "shadow-sm",
        base = "shadow",
        md = "shadow",  # For backward compatibility
        lg = "shadow-lg",
        colored = "shadow-lg shadow-blue-500/10 dark:shadow-blue-400/10",
    )

    rounded_classes = (
        none = "",
        sm = "rounded",
        base = "rounded-lg",
        md = "rounded-lg",  # For backward compatibility
        lg = "rounded-xl",
        xl = "rounded-2xl",
    )

    border_classes = (
        none = "",
        default = "border border-slate-200 dark:border-slate-800",
        gradient = "border border-transparent bg-gradient-to-r from-blue-500 to-indigo-500 p-[1px]",
    )

    variant_classes = (
        default = "bg-white dark:bg-slate-900",
        glass = "backdrop-blur-sm bg-white/80 dark:bg-slate-900/80 border-white/20 dark:border-slate-700/50",
        gradient = "bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-800 dark:to-slate-900",
    )

    padding_class = get(padding_classes, padding_sym, padding_classes.base)
    shadow_class = get(shadow_classes, shadow_sym, shadow_classes.base)
    border_class = get(border_classes, border_sym, "")
    rounded_class = get(rounded_classes, rounded_sym, rounded_classes.lg)
    variant_class = get(variant_classes, variant_sym, variant_classes.default)

    hover_class =
        hoverable ?
        "transition-all duration-200 hover:shadow-xl hover:-translate-y-0.5 motion-safe:hover:-translate-y-0.5" :
        ""

    # Handle gradient border special case
    if border_sym === :gradient
        @div {class = "$border_class $rounded_class $shadow_class $hover_class", attrs...} begin
            @div {class = "$variant_class $padding_class $rounded_class"} begin
                @__slot__()
            end
        end
    else
        @div {
            class = "$variant_class $padding_class $shadow_class $border_class $rounded_class $hover_class",
            attrs...,
        } begin
            @__slot__()
        end
    end
end

@deftag macro Card end
