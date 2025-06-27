"""
    @Heading

A styled heading component with consistent sizing and weight.

# Props
- `level::Int`: Heading level (`1`-`6`) (default: `1`)
- `size::Union{Symbol,String,Nothing}`: Override size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`, `"2xl"`, `"3xl"`, `"4xl"`, `"5xl"`) (optional)
- `weight::Union{Symbol,String}`: Font weight (`:normal`, `:medium`, `:semibold`, `:bold`) (default: `:semibold`)
- `color::Union{String,Nothing}`: Text color class (optional)
"""
@component function Heading(;
    level::Int = 1,
    size::Union{Symbol,String,Nothing} = nothing,
    weight::Union{Symbol,String} = :semibold,
    color::Union{String,Nothing} = nothing,
    attrs...,
)
    # Default sizes for each heading level
    default_sizes = Dict(
        1 => "text-4xl sm:text-5xl",
        2 => "text-3xl sm:text-4xl",
        3 => "text-2xl sm:text-3xl",
        4 => "text-xl sm:text-2xl",
        5 => "text-lg sm:text-xl",
        6 => "text-base sm:text-lg",
    )

    # Convert to symbols
    size_sym = isnothing(size) ? size : Symbol(size)
    weight_sym = Symbol(weight)

    # Size overrides
    size_classes = Dict(
        :xs => "text-xs",
        :sm => "text-sm",
        :base => "text-base",
        :lg => "text-lg",
        :xl => "text-xl",
        Symbol("2xl") => "text-2xl",
        Symbol("3xl") => "text-3xl",
        Symbol("4xl") => "text-4xl",
        Symbol("5xl") => "text-5xl",
    )

    weight_classes = Dict(
        :normal => "font-normal",
        :medium => "font-medium",
        :semibold => "font-semibold",
        :bold => "font-bold",
    )

    size_class =
        isnothing(size_sym) ? get(default_sizes, level, "text-2xl") :
        get(size_classes, size_sym, "text-2xl")
    weight_class = get(weight_classes, weight_sym, "font-semibold")
    color_class = isnothing(color) ? "text-slate-900 dark:text-slate-100" : color

    elements = Dict(
        1 => Elements.h1,
        2 => Elements.h2,
        3 => Elements.h3,
        4 => Elements.h4,
        5 => Elements.h5,
        6 => Elements.h6,
    )
    element = get(elements, level, Elements.h1)

    @<element {class = "$size_class $weight_class $color_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Heading end

function Text end

"""
    @Text

Body text component with various styles.

# Props
- `variant::Union{Symbol,String}`: Text variant (`:body`, `:lead`, `:small`) (default: `:body`)
- `size::Union{Symbol,String,Nothing}`: Override size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (optional)
- `weight::Union{Symbol,String}`: Font weight (`:normal`, `:medium`, `:semibold`, `:bold`) (default: `:normal`)
- `color::Union{String,Nothing}`: Text color class (optional)
- `align::Union{Symbol,String}`: Text alignment (`:left`, `:center`, `:right`, `:justify`) (default: `:left`)
"""
@component function Text(;
    variant::Union{Symbol,String} = :body,
    size::Union{Symbol,String,Nothing} = nothing,
    weight::Union{Symbol,String} = :normal,
    color::Union{String,Nothing} = nothing,
    align::Union{Symbol,String} = :left,
    attrs...,
)
    variant_classes = Dict(
        :body => "text-base leading-relaxed",
        :lead => "text-lg sm:text-xl leading-relaxed",
        :small => "text-sm leading-normal",
    )

    size_classes = Dict(
        :xs => "text-xs",
        :sm => "text-sm",
        :base => "text-base",
        :lg => "text-lg",
        :xl => "text-xl",
    )

    weight_classes = Dict(
        :normal => "font-normal",
        :medium => "font-medium",
        :semibold => "font-semibold",
        :bold => "font-bold",
    )

    align_classes = Dict(
        :left => "text-left",
        :center => "text-center",
        :right => "text-right",
        :justify => "text-justify",
    )

    # Convert to symbols
    size_sym = isnothing(size) ? size : Symbol(size)
    variant_sym = Symbol(variant)
    weight_sym = Symbol(weight)
    align_sym = Symbol(align)

    base_class = get(variant_classes, variant_sym, "text-base")
    size_class = isnothing(size_sym) ? "" : get(size_classes, size_sym, "")
    weight_class = get(weight_classes, weight_sym, "font-normal")
    color_class = isnothing(color) ? "text-slate-600 dark:text-slate-400" : color
    align_class = get(align_classes, align_sym, "text-left")

    @p {class = "$base_class $size_class $weight_class $color_class $align_class", attrs...} begin
        @__slot__()
    end
end

@deftag macro Text end

"""
    @Link

Styled anchor element with hover effects.

# Props
- `href::String`: Link destination (required)
- `variant::Union{Symbol,String}`: Link variant (`:default`, `:underline`, `:hover_underline`) (default: `:default`)
- `color::Union{String,Nothing}`: Text color class (optional)
- `external::Bool`: Whether this is an external link (adds target="_blank") (default: `false`)
"""
@component function Link(;
    href::String,
    variant::Union{Symbol,String} = :default,
    color::Union{String,Nothing} = nothing,
    external::Bool = false,
    attrs...,
)
    # Convert to symbol
    variant_sym = Symbol(variant)

    variant_classes = Dict(
        :default => "transition-colors",
        :underline => "underline transition-colors",
        :hover_underline => "hover:underline transition-all",
    )

    variant_class = get(variant_classes, variant_sym, "transition-colors")
    color_class =
        isnothing(color) ?
        "text-slate-900 hover:text-slate-700 dark:text-slate-100 dark:hover:text-slate-300" :
        color

    if external
        @a {
            href = href,
            target = "_blank",
            rel = "noopener noreferrer",
            class = "$variant_class $color_class",
            attrs...,
        } begin
            @__slot__()
        end
    else
        @a {href = href, class = "$variant_class $color_class", attrs...} begin
            @__slot__()
        end
    end
end

@deftag macro Link end
