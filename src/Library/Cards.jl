"""
    @Card

A content container with border and shadow.

# Props
- `padding::Union{Symbol,String}`: Padding size (`:none`, `:sm`, `:md`, `:lg`) (default: `:md`)
- `shadow::Union{Symbol,String}`: Shadow size (`:none`, `:sm`, `:md`, `:lg`) (default: `:sm`)
- `border::Bool`: Whether to show border (default: `true`)
- `rounded::Union{Symbol,String}`: Border radius (`:none`, `:sm`, `:md`, `:lg`) (default: `:lg`)
"""
@component function Card(;
    padding::Union{Symbol,String} = :md,
    shadow::Union{Symbol,String} = :sm,
    border::Bool = true,
    rounded::Union{Symbol,String} = :lg,
    attrs...,
)
    # Convert to symbols
    padding_sym = Symbol(padding)
    shadow_sym = Symbol(shadow)
    rounded_sym = Symbol(rounded)

    padding_classes = Dict(:none => "", :sm => "p-4", :md => "p-6", :lg => "p-8")

    shadow_classes =
        Dict(:none => "", :sm => "shadow-sm", :md => "shadow-md", :lg => "shadow-lg")

    rounded_classes =
        Dict(:none => "", :sm => "rounded", :md => "rounded-md", :lg => "rounded-lg")

    padding_class = get(padding_classes, padding_sym, "p-6")
    shadow_class = get(shadow_classes, shadow_sym, "shadow-sm")
    border_class = border ? "border border-slate-200 dark:border-slate-800" : ""
    rounded_class = get(rounded_classes, rounded_sym, "rounded-lg")

    @div {
        class = "bg-white dark:bg-slate-900 $padding_class $shadow_class $border_class $rounded_class",
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Card end

"""
    @Badge

Small status indicator component.

# Props
- `variant::Union{Symbol,String}`: Badge variant (`:default`, `:primary`, `:success`, `:warning`, `:danger`) (default: `:default`)
- `size::Union{Symbol,String}`: Badge size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `role::Union{String,Nothing}`: ARIA role (e.g., "status" for dynamic updates) (optional)
"""
@component function Badge(;
    variant::Union{Symbol,String} = :default,
    size::Union{Symbol,String} = :md,
    role::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    variant_classes = Dict(
        :default => "bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-300",
        :primary => "bg-slate-900 text-white dark:bg-slate-100 dark:text-slate-900",
        :success => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
        :warning => "bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200",
        :danger => "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200",
    )

    size_classes = Dict(
        :sm => "px-2 py-0.5 text-xs",
        :md => "px-2.5 py-1 text-sm",
        :lg => "px-3 py-1.5 text-base",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes[:default])
    size_class = get(size_classes, size_sym, size_classes[:md])

    @span {
        class = "inline-flex items-center font-medium rounded-full $variant_class $size_class",
        role = role,
        attrs...,
    } begin
        @__slot__()
    end
end

@deftag macro Badge end
