"""
    @Card

A content container with border and shadow.

# Props
- `padding::Union{Symbol,String}`: Padding size (`:none`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `shadow::Union{Symbol,String}`: Shadow type (`:none`, `:sm`, `:base`, `:lg`, `:colored`) (default: `:base`)
- `border::Union{Bool,Symbol}`: Border style (`true`, `false`, `:gradient`) (default: `true`)
- `rounded::Union{Symbol,String}`: Border radius (`:none`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:lg`)
- `variant::Union{Symbol,String}`: Card variant (`:default`, `:glass`, `:gradient`) (default: `:default`)
- `hoverable::Bool`: Whether card has hover effects (default: `false`)
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

"""
    @Badge

Small status indicator component with modern styling.

# Props
- `variant::Union{Symbol,String}`: Badge variant (`:default`, `:primary`, `:secondary`, `:success`, `:warning`, `:danger`, `:gradient`) (default: `:default`)
- `size::Union{Symbol,String}`: Badge size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `role::Union{String,Nothing}`: ARIA role (e.g., "status" for dynamic updates) (optional)
- `animated::Bool`: Whether badge has subtle animation (default: `false`)
- `outline::Bool`: Whether badge has outline style (default: `false`)
"""
@component function Badge(;
    variant::Union{Symbol,String} = :default,
    size::Union{Symbol,String} = :base,
    role::Union{String,Nothing} = nothing,
    animated::Bool = false,
    outline::Bool = false,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    variant_classes = (
        default = "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300",
        primary = "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
        secondary = "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300",
        success = "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300",
        warning = "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
        danger = "bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-300",
        gradient = "bg-gradient-to-r from-blue-500 to-purple-600 text-white",
    )

    outline_classes = (
        default = "bg-transparent border border-gray-300 text-gray-700 dark:border-gray-600 dark:text-gray-300",
        primary = "bg-transparent border border-blue-300 text-blue-700 dark:border-blue-600 dark:text-blue-300",
        secondary = "bg-transparent border border-purple-300 text-purple-700 dark:border-purple-600 dark:text-purple-300",
        success = "bg-transparent border border-emerald-300 text-emerald-700 dark:border-emerald-600 dark:text-emerald-300",
        warning = "bg-transparent border border-amber-300 text-amber-700 dark:border-amber-600 dark:text-amber-300",
        danger = "bg-transparent border border-rose-300 text-rose-700 dark:border-rose-600 dark:text-rose-300",
        gradient = "bg-transparent border-2 border-transparent bg-gradient-to-r from-blue-500 to-purple-600 bg-clip-text text-transparent",
    )

    size_classes = (
        xs = "px-2 py-0.5 text-xs",
        sm = "px-2.5 py-0.5 text-xs",
        base = "px-3 py-1 text-sm",
        md = "px-3 py-1 text-sm",  # For backward compatibility
        lg = "px-3.5 py-1.5 text-base",
        xl = "px-4 py-2 text-lg",
    )

    variant_class =
        outline ? get(outline_classes, variant_sym, outline_classes.default) :
        get(variant_classes, variant_sym, variant_classes.default)
    size_class = get(size_classes, size_sym, size_classes.base)
    animation_class = animated ? "animate-pulse" : ""
    transition_class = "transition-all duration-200"

    @span {
        class = "inline-flex items-center font-medium rounded-full $variant_class $size_class $animation_class $transition_class",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Badge end
