"""
    @Divider

A horizontal or vertical separator component that creates visual boundaries between sections of content. Dividers are subtle yet important design elements that help organize interfaces by creating clear visual separation without adding clutter. They guide the eye through layouts, group related content, and provide breathing room between different sections. This component supports both horizontal and vertical orientations with customizable spacing and colors, adapting seamlessly to light and dark themes while maintaining appropriate visual weight for non-intrusive content separation.

# Props
- `orientation::Union{Symbol,String}`: Divider orientation (`:horizontal`, `:vertical`) (default: `:horizontal`)
- `spacing::Union{String,Nothing}`: Custom spacing class (optional)
- `color::Union{String,Nothing}`: Border color class (optional)
"""
@component function Divider(;
    orientation::Union{Symbol,String} = :horizontal,
    spacing::Union{String,Nothing} = nothing,
    color::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbol
    orientation_sym = Symbol(orientation)

    default_spacing = orientation_sym === :horizontal ? "my-4" : "mx-4"
    spacing_class = isnothing(spacing) ? default_spacing : spacing
    color_class = isnothing(color) ? "border-slate-200 dark:border-slate-800" : color

    if orientation_sym === :horizontal
        @hr {class = "border-t $color_class $spacing_class", role = "separator", attrs...}
    else
        @div {
            class = "inline-block min-h-[1em] w-0.5 self-stretch bg-slate-200 dark:bg-slate-800 $spacing_class",
            role = "separator",
            "aria-orientation" = "vertical",
            attrs...,
        }
    end
end

@deftag macro Divider end
