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

    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Direct theme access
    padding_class = theme.card.padding[padding_sym]
    shadow_class = theme.card.shadow[shadow_sym]
    border_class = theme.card.border[border_sym]
    rounded_class = theme.card.rounded[rounded_sym]
    variant_class = theme.card.variants[variant_sym]
    hover_class = hoverable ? theme.card.states.hoverable : ""

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
