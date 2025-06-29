module Styles

export SIZES,
    COLORS,
    GRADIENTS,
    SPACING,
    RADIUS,
    TRANSITIONS,
    SHADOWS,
    ANIMATIONS,
    GLASS_EFFECTS,
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

# Enhanced color system with modern vibrant colors
const COLORS = Dict(
    :primary => (
        base = "bg-blue-500 text-white",
        hover = "hover:bg-blue-600",
        focus = "focus:ring-blue-400",
        dark_base = "dark:bg-blue-400",
        dark_hover = "dark:hover:bg-blue-300",
        light = "bg-blue-50 text-blue-700 dark:bg-blue-950 dark:text-blue-300",
    ),
    :secondary => (
        base = "bg-purple-500 text-white",
        hover = "hover:bg-purple-600",
        focus = "focus:ring-purple-400",
        dark_base = "dark:bg-purple-400",
        dark_hover = "dark:hover:bg-purple-300",
        light = "bg-purple-50 text-purple-700 dark:bg-purple-950 dark:text-purple-300",
    ),
    :neutral => (
        base = "bg-gray-100 text-gray-900",
        hover = "hover:bg-gray-200",
        focus = "focus:ring-gray-300",
        dark_base = "dark:bg-gray-800 dark:text-gray-100",
        dark_hover = "dark:hover:bg-gray-700",
        light = "bg-gray-50 text-gray-700 dark:bg-gray-900 dark:text-gray-300",
    ),
    :success => (
        base = "bg-emerald-500 text-white",
        hover = "hover:bg-emerald-600",
        focus = "focus:ring-emerald-400",
        dark_base = "dark:bg-emerald-400",
        dark_hover = "dark:hover:bg-emerald-300",
        light = "bg-emerald-50 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300",
    ),
    :warning => (
        base = "bg-amber-500 text-white",
        hover = "hover:bg-amber-600",
        focus = "focus:ring-amber-400",
        dark_base = "dark:bg-amber-400",
        dark_hover = "dark:hover:bg-amber-300",
        light = "bg-amber-50 text-amber-700 dark:bg-amber-950 dark:text-amber-300",
    ),
    :danger => (
        base = "bg-rose-500 text-white",
        hover = "hover:bg-rose-600",
        focus = "focus:ring-rose-400",
        dark_base = "dark:bg-rose-400",
        dark_hover = "dark:hover:bg-rose-300",
        light = "bg-rose-50 text-rose-700 dark:bg-rose-950 dark:text-rose-300",
    ),
)

# Modern gradient definitions
const GRADIENTS = Dict(
    :primary => "bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700",
    :secondary => "bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600",
    :sunset => "bg-gradient-to-r from-orange-400 to-pink-500 hover:from-orange-500 hover:to-pink-600",
    :ocean => "bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700",
    :forest => "bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700",
    :subtle => "bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800",
    :glass => "backdrop-blur-md bg-white/70 dark:bg-gray-900/70 backdrop-saturate-150",
    :mesh => "bg-[radial-gradient(at_top_left,_var(--tw-gradient-stops))] from-blue-100 via-transparent to-purple-100 dark:from-blue-900/20 dark:to-purple-900/20",
)

# Consistent spacing patterns
const SPACING =
    Dict(:compact => "p-2", :normal => "p-4", :relaxed => "p-6", :spacious => "p-8")

# Modern border radius scale
const RADIUS = Dict(
    :none => "rounded-none",
    :sm => "rounded-md",
    :base => "rounded-lg",
    :lg => "rounded-xl",
    :xl => "rounded-2xl",
    :xxl => "rounded-3xl",
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

# Modern shadow effects with colored variants
const SHADOWS = Dict(
    :sm => "shadow-sm hover:shadow transition-shadow",
    :base => "shadow-md hover:shadow-lg transition-shadow",
    :lg => "shadow-lg hover:shadow-xl transition-shadow",
    :xl => "shadow-xl hover:shadow-2xl transition-shadow",
    :inner => "shadow-inner",
    :glow => "shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40 dark:shadow-blue-400/25 dark:hover:shadow-blue-400/40",
    :glass => "shadow-xl ring-1 ring-black/5 dark:ring-white/5",
    :float => "shadow-2xl shadow-gray-200/50 dark:shadow-gray-900/50",
    :none => "",
)

# Modern animations
const ANIMATIONS = Dict(
    :pulse => "animate-pulse",
    :spin => "animate-spin",
    :bounce => "animate-bounce",
    :fade_in => "animate-[fadeIn_0.5s_ease-in-out]",
    :slide_up => "animate-[slideUp_0.3s_ease-out]",
    :scale => "animate-[scale_0.2s_ease-in-out]",
)

# Glassmorphism effects
const GLASS_EFFECTS = Dict(
    :light => "backdrop-blur-sm bg-white/30 border border-white/20",
    :medium => "backdrop-blur-md bg-white/40 border border-white/30",
    :strong => "backdrop-blur-lg bg-white/50 border border-white/40",
    :dark => "backdrop-blur-md bg-gray-900/40 border border-gray-700/30",
    :colored => "backdrop-blur-md bg-gradient-to-br from-blue-500/10 to-purple-500/10 border border-white/20",
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
               " focus:ring-2 focus:ring-offset-2 focus:ring-opacity-50 dark:focus:ring-offset-gray-900"
    end
    return base_focus * " focus:ring-2 focus:ring-opacity-50"
end

function get_disabled_classes()
    return "disabled:opacity-60 disabled:cursor-not-allowed disabled:pointer-events-none"
end

end # module Styles
