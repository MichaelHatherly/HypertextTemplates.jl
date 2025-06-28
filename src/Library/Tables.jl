"""
    @Table

A responsive data table component.

# Props
- `striped::Bool`: Whether to show striped rows (default: `false`)
- `bordered::Bool`: Whether to show borders (default: `true`)
- `hover::Bool`: Whether to show hover effect on rows (default: `true`)
- `compact::Bool`: Whether to use compact spacing (default: `false`)
- `sticky_header::Bool`: Whether table header should be sticky (default: `false`)
- `sortable::Bool`: Whether to show sortable column indicators (default: `false`)
- `caption::Union{String,Nothing}`: Table caption/description (optional)
"""
@component function Table(;
    striped::Bool = false,
    bordered::Bool = true,
    hover::Bool = true,
    compact::Bool = false,
    sticky_header::Bool = false,
    sortable::Bool = false,
    caption::Union{String,Nothing} = nothing,
    attrs...,
)
    striped_class =
        striped ?
        "[&>tbody>tr:nth-child(even)]:bg-slate-50 dark:[&>tbody>tr:nth-child(even)]:bg-slate-800/50" :
        ""

    hover_class =
        hover ?
        "[&>tbody>tr]:transition-colors [&>tbody>tr]:duration-150 [&>tbody>tr]:hover:bg-blue-50 dark:[&>tbody>tr]:hover:bg-blue-950/30 [&>tbody>tr]:hover:shadow-sm" :
        ""

    spacing_class =
        compact ? "[&_th]:px-3 [&_th]:py-2 [&_td]:px-3 [&_td]:py-2" :
        "[&_th]:px-6 [&_th]:py-3 [&_td]:px-6 [&_td]:py-4"

    sticky_header_class =
        sticky_header ?
        "[&>thead]:sticky [&>thead]:top-0 [&>thead]:z-10 [&>thead]:bg-white dark:[&>thead]:bg-slate-900 [&>thead]:shadow-sm" :
        ""

    sortable_class =
        sortable ?
        "[&_th]:cursor-pointer [&_th]:select-none [&_th]:hover:bg-slate-100 dark:[&_th]:hover:bg-slate-800 [&_th]:transition-colors [&_th]:relative [&_th]:pr-8" :
        ""

    header_style = "[&_th]:font-semibold [&_th]:text-left [&_th]:text-slate-900 dark:[&_th]:text-slate-100 [&_th]:uppercase [&_th]:text-xs [&_th]:tracking-wider"

    border_classes = if bordered
        "border border-slate-200 dark:border-slate-700 rounded-lg overflow-hidden [&_th]:border-b-2 [&_th]:border-slate-200 dark:[&_th]:border-slate-700 [&_td]:border-b [&_td]:border-slate-100 dark:[&_td]:border-slate-800 [&>tbody>tr:last-child>td]:border-b-0"
    else
        ""
    end

    wrapper_class =
        sticky_header ? "w-full overflow-x-auto max-h-[600px] overflow-y-auto" :
        "w-full overflow-x-auto"

    @div {class=wrapper_class} begin
        @table {
            class="min-w-full divide-y divide-slate-200 dark:divide-slate-700 $striped_class $hover_class $spacing_class $border_classes $sticky_header_class $sortable_class $header_style",
            attrs...,
        } begin
            if !isnothing(caption)
                @caption {class="mb-4 text-sm text-slate-600 dark:text-slate-400"} $caption
            end
            @__slot__()
        end
    end
end

@deftag macro Table end

"""
    @List

A styled list component with various markers.

# Props
- `variant::Union{Symbol,String}`: List variant (`:bullet`, `:number`, `:check`, `:none`) (default: `:bullet`)
- `spacing::Union{Symbol,String}`: Item spacing (`:tight`, `:normal`, `:loose`) (default: `:normal`)
"""
@component function List(;
    variant::Union{Symbol,String} = :bullet,
    spacing::Union{Symbol,String} = :normal,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    spacing_sym = Symbol(spacing)

    spacing_classes =
        Dict(:tight => "space-y-1", :normal => "space-y-2", :loose => "space-y-4")

    spacing_class = get(spacing_classes, spacing_sym, "space-y-2")

    # Base classes for all variants
    base_class = "text-slate-600 dark:text-slate-400 $spacing_class"

    if variant_sym == :bullet
        @ul {class="list-disc list-inside $base_class", attrs...} begin
            @__slot__()
        end
    elseif variant_sym == :number
        @ol {class="list-decimal list-inside $base_class", attrs...} begin
            @__slot__()
        end
    elseif variant_sym == :check
        # For check variant, we'll style the list items with pseudo-elements
        @ul {
            class="[&>li]:relative [&>li]:pl-6 [&>li:before]:content-['✓'] [&>li:before]:absolute [&>li:before]:left-0 [&>li:before]:text-green-600 dark:[&>li:before]:text-green-400 [&>li:before]:font-bold $base_class",
            attrs...,
        } begin
            @__slot__()
        end
    else # :none
        @ul {class="list-none $base_class", attrs...} begin
            @__slot__()
        end
    end
end

@deftag macro List end
