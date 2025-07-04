"""
    @Spinner

A loading spinner component that provides visual feedback during asynchronous operations. Spinners are crucial for maintaining user engagement during loading states, preventing users from thinking the application has frozen or crashed. This simple yet effective component uses smooth rotation animation and comes in multiple sizes and colors to fit various contexts, from small inline loading indicators to full-page loading states. The spinner automatically includes proper ARIA attributes for accessibility.

# Props
- `size::Union{Symbol,String}`: Spinner size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Spinner color (`:slate`, `:primary`, `:white`) (default: `:primary`)
"""
@component function Spinner(;
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    size_classes = (sm = "h-4 w-4", md = "h-6 w-6", lg = "h-8 w-8")

    color_classes = (
        slate = "text-slate-600 dark:text-slate-400",
        primary = "text-slate-900 dark:text-slate-100",
        white = "text-white",
    )

    size_class = get(size_classes, size_sym, size_classes.md)
    color_class = get(color_classes, color_sym, color_classes.primary)

    @div {
        class = "inline-flex items-center",
        role = "status",
        "aria-label" = "Loading",
        attrs...,
    } begin
        @text HypertextTemplates.SafeString(
            """<svg class="animate-spin $size_class $color_class" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" aria-hidden="true">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
</svg>""",
        )
    end
end

@deftag macro Spinner end
