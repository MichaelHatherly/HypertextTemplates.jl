module Styles

export SIZES,
    COLORS,
    SPACING,
    RADIUS,
    TRANSITIONS,
    SHADOWS,
    get_size_classes,
    get_color_classes,
    get_transition_classes,
    get_focus_classes,
    get_disabled_classes

# Standardized size scale
const SIZES = Dict(
    :xs => (padding = "p-2", text = "text-xs", height = "h-8", gap = "gap-1"),
    :sm => (padding = "p-3", text = "text-sm", height = "h-10", gap = "gap-2"),
    :base => (padding = "p-4", text = "text-base", height = "h-12", gap = "gap-3"),
    :lg => (padding = "p-5", text = "text-lg", height = "h-14", gap = "gap-4"),
    :xl => (padding = "p-6", text = "text-xl", height = "h-16", gap = "gap-5"),
)

# Enhanced color system with accent colors
const COLORS = Dict(
    :primary => (
        base = "bg-blue-600 text-white",
        hover = "hover:bg-blue-700",
        focus = "focus:ring-blue-500",
        dark_base = "dark:bg-blue-500",
        dark_hover = "dark:hover:bg-blue-400",
    ),
    :secondary => (
        base = "bg-indigo-600 text-white",
        hover = "hover:bg-indigo-700",
        focus = "focus:ring-indigo-500",
        dark_base = "dark:bg-indigo-500",
        dark_hover = "dark:hover:bg-indigo-400",
    ),
    :neutral => (
        base = "bg-slate-200 text-slate-900",
        hover = "hover:bg-slate-300",
        focus = "focus:ring-slate-400",
        dark_base = "dark:bg-slate-700 dark:text-slate-100",
        dark_hover = "dark:hover:bg-slate-600",
    ),
    :success => (
        base = "bg-green-600 text-white",
        hover = "hover:bg-green-700",
        focus = "focus:ring-green-500",
        dark_base = "dark:bg-green-500",
        dark_hover = "dark:hover:bg-green-400",
    ),
    :warning => (
        base = "bg-amber-600 text-white",
        hover = "hover:bg-amber-700",
        focus = "focus:ring-amber-500",
        dark_base = "dark:bg-amber-500",
        dark_hover = "dark:hover:bg-amber-400",
    ),
    :danger => (
        base = "bg-red-600 text-white",
        hover = "hover:bg-red-700",
        focus = "focus:ring-red-500",
        dark_base = "dark:bg-red-500",
        dark_hover = "dark:hover:bg-red-400",
    ),
)

# Gradient definitions
const GRADIENTS = Dict(
    :primary => "bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700",
    :secondary => "bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700",
    :subtle => "bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-800 dark:to-slate-900",
    :glass => "backdrop-blur-sm bg-white/80 dark:bg-slate-900/80",
)

# Consistent spacing patterns
const SPACING =
    Dict(:compact => "p-2", :normal => "p-4", :relaxed => "p-6", :spacious => "p-8")

# Border radius scale
const RADIUS = Dict(
    :none => "rounded-none",
    :sm => "rounded",
    :base => "rounded-md",
    :lg => "rounded-lg",
    :xl => "rounded-xl",
    :full => "rounded-full",
)

# Transition effects
const TRANSITIONS = Dict(
    :base => "transition-all duration-200 ease-in-out",
    :fast => "transition-all duration-150 ease-in-out",
    :slow => "transition-all duration-300 ease-in-out",
    :colors => "transition-colors duration-200 ease-in-out",
    :transform => "transition-transform duration-200 ease-in-out",
    :motion_safe => "motion-safe:transition-all motion-safe:duration-200",
)

# Enhanced shadow effects
const SHADOWS = Dict(
    :sm => "shadow-sm hover:shadow-md",
    :base => "shadow hover:shadow-lg",
    :lg => "shadow-lg hover:shadow-xl",
    :inner => "shadow-inner",
    :colored => "shadow-lg shadow-blue-500/25 dark:shadow-blue-400/25",
    :glass => "shadow-lg backdrop-blur-sm",
)

# Utility functions

function get_size_classes(size::Symbol, properties::Vector{Symbol} = [:padding, :text])
    size_data = get(SIZES, size, SIZES[:base])
    return join([size_data[prop] for prop in properties if haskey(size_data, prop)], " ")
end

function get_color_classes(color::Symbol, include_dark::Bool = true)
    color_data = get(COLORS, color, COLORS[:neutral])
    classes = [color_data.base, color_data.hover, color_data.focus]
    if include_dark
        push!(classes, color_data.dark_base, color_data.dark_hover)
    end
    return join(classes, " ")
end

function get_transition_classes(type::Symbol = :base, motion_safe::Bool = true)
    base_transition = get(TRANSITIONS, type, TRANSITIONS[:base])
    if motion_safe && type != :motion_safe
        return base_transition * " " * TRANSITIONS[:motion_safe]
    end
    return base_transition
end

function get_focus_classes(color::Symbol = :primary, enhanced::Bool = true)
    color_data = get(COLORS, color, COLORS[:primary])
    base_focus = "focus:outline-none " * color_data.focus
    if enhanced
        return base_focus *
               " focus:ring-2 focus:ring-offset-2 dark:focus:ring-offset-slate-900"
    end
    return base_focus * " focus:ring-2"
end

function get_disabled_classes()
    return "disabled:opacity-60 disabled:cursor-not-allowed disabled:pointer-events-none"
end

end # module Styles
