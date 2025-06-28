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

    padding_classes = Dict(
        :none => "",
        :sm => "p-4",
        :base => "p-6",
        :md => "p-6",  # For backward compatibility
        :lg => "p-8",
        :xl => "p-10"
    )

    shadow_classes = Dict(
        :none => "",
        :sm => "shadow-sm",
        :base => "shadow",
        :md => "shadow",  # For backward compatibility
        :lg => "shadow-lg",
        :colored => "shadow-lg shadow-blue-500/10 dark:shadow-blue-400/10"
    )

    rounded_classes = Dict(
        :none => "",
        :sm => "rounded",
        :base => "rounded-lg",
        :md => "rounded-lg",  # For backward compatibility
        :lg => "rounded-xl",
        :xl => "rounded-2xl"
    )

    border_classes = Dict(
        :none => "",
        :default => "border border-slate-200 dark:border-slate-800",
        :gradient => "border border-transparent bg-gradient-to-r from-blue-500 to-indigo-500 p-[1px]"
    )

    variant_classes = Dict(
        :default => "bg-white dark:bg-slate-900",
        :glass => "backdrop-blur-sm bg-white/80 dark:bg-slate-900/80 border-white/20 dark:border-slate-700/50",
        :gradient => "bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-800 dark:to-slate-900"
    )

    padding_class = get(padding_classes, padding_sym, padding_classes[:base])
    shadow_class = get(shadow_classes, shadow_sym, shadow_classes[:base])
    border_class = get(border_classes, border_sym, "")
    rounded_class = get(rounded_classes, rounded_sym, rounded_classes[:lg])
    variant_class = get(variant_classes, variant_sym, variant_classes[:default])
    
    hover_class = hoverable ? "transition-all duration-200 hover:shadow-xl hover:-translate-y-0.5 motion-safe:hover:-translate-y-0.5" : ""
    
    # Handle gradient border special case
    if border_sym == :gradient
        @div {
            class = "$border_class $rounded_class $shadow_class $hover_class",
            attrs...,
        } begin
            @div {
                class = "$variant_class $padding_class $rounded_class"
            } begin
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

Small status indicator component.

# Props
- `variant::Union{Symbol,String}`: Badge variant (`:default`, `:primary`, `:secondary`, `:success`, `:warning`, `:danger`) (default: `:default`)
- `size::Union{Symbol,String}`: Badge size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `role::Union{String,Nothing}`: ARIA role (e.g., "status" for dynamic updates) (optional)
"""
@component function Badge(;
    variant::Union{Symbol,String} = :default,
    size::Union{Symbol,String} = :base,
    role::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    variant_classes = Dict(
        :default => "bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-300",
        :primary => "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200",
        :secondary => "bg-indigo-100 text-indigo-800 dark:bg-indigo-900 dark:text-indigo-200",
        :success => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
        :warning => "bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200",
        :danger => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
    )

    size_classes = Dict(
        :xs => "px-1.5 py-0.5 text-xs",
        :sm => "px-2 py-0.5 text-xs",
        :base => "px-2.5 py-1 text-sm",
        :md => "px-2.5 py-1 text-sm",  # For backward compatibility
        :lg => "px-3 py-1.5 text-base",
        :xl => "px-4 py-2 text-lg",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes[:default])
    size_class = get(size_classes, size_sym, size_classes[:base])

    @span {
        class = "inline-flex items-center font-medium rounded-full $variant_class $size_class",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Badge end
