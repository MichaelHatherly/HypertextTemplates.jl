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

    # Extract card theme safely
    card_theme = if isa(theme, NamedTuple) && haskey(theme, :card)
        theme.card
    else
        HypertextTemplates.Library.default_theme().card
    end

    # Get padding class with fallback
    padding_class =
        if haskey(card_theme, :padding) && haskey(card_theme.padding, padding_sym)
            card_theme.padding[padding_sym]
        else
            HypertextTemplates.Library.default_theme().card.padding[padding_sym]
        end

    # Get shadow class with fallback
    shadow_class = if haskey(card_theme, :shadow) && haskey(card_theme.shadow, shadow_sym)
        card_theme.shadow[shadow_sym]
    else
        HypertextTemplates.Library.default_theme().card.shadow[shadow_sym]
    end

    # Get border class with fallback
    border_class = if haskey(card_theme, :border) && haskey(card_theme.border, border_sym)
        card_theme.border[border_sym]
    else
        HypertextTemplates.Library.default_theme().card.border[border_sym]
    end

    # Get rounded class with fallback
    rounded_class =
        if haskey(card_theme, :rounded) && haskey(card_theme.rounded, rounded_sym)
            card_theme.rounded[rounded_sym]
        else
            HypertextTemplates.Library.default_theme().card.rounded[rounded_sym]
        end

    # Get variant class with fallback
    variant_class =
        if haskey(card_theme, :variants) && haskey(card_theme.variants, variant_sym)
            card_theme.variants[variant_sym]
        else
            HypertextTemplates.Library.default_theme().card.variants[variant_sym]
        end

    # Get hoverable state
    states =
        get(card_theme, :states, HypertextTemplates.Library.default_theme().card.states)
    hover_class = hoverable ? get(states, :hoverable, "") : ""

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
