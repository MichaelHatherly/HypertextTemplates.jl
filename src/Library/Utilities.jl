"""
    @Divider

Horizontal or vertical separator component.

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

    default_spacing = orientation_sym == :horizontal ? "my-4" : "mx-4"
    spacing_class = isnothing(spacing) ? default_spacing : spacing
    color_class = isnothing(color) ? "border-slate-200 dark:border-slate-800" : color

    if orientation_sym == :horizontal
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

"""
    @Avatar

User profile image component.

# Props
- `src::Union{String,Nothing}`: Image source URL (optional)
- `alt::String`: Alternative text (required when src is provided, ignored otherwise)
- `size::Union{Symbol,String}`: Avatar size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `shape::Union{Symbol,String}`: Avatar shape (`:circle`, `:square`) (default: `:circle`)
- `fallback::Union{String,Nothing}`: Fallback content when no src provided (optional)
"""
@component function Avatar(;
    src::Union{AbstractString,Nothing} = nothing,
    alt::Union{AbstractString,Nothing} = nothing,
    size::Union{Symbol,String} = :md,
    shape::Union{Symbol,String} = :circle,
    fallback::Union{AbstractString,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    shape_sym = Symbol(shape)

    size_classes = Dict(
        :xs => "h-6 w-6 text-xs",
        :sm => "h-8 w-8 text-sm",
        :md => "h-10 w-10 text-base",
        :lg => "h-12 w-12 text-lg",
        :xl => "h-16 w-16 text-xl",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    shape_class = shape_sym == :circle ? "rounded-full" : "rounded-lg"

    # Default background color for fallback avatars
    default_bg = if !isnothing(src)
        "bg-slate-100 dark:bg-slate-800"
    else
        "bg-blue-500 dark:bg-blue-600"
    end

    # Build component default attributes
    component_attrs = (
        class = "relative inline-flex $size_class $shape_class overflow-hidden $default_bg",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @div {merged_attrs...} begin
        if !isnothing(src)
            # Require meaningful alt text for images
            if isnothing(alt)
                error("Avatar: alt text is required when src is provided")
            end
            @img {src = src, alt = alt, class = "h-full w-full object-cover"}
        else
            # Fallback content
            @div {
                class = "flex h-full w-full items-center justify-center font-medium text-white",
            } begin
                if !isnothing(fallback)
                    @text fallback
                else
                    # Default user icon
                    @text HypertextTemplates.SafeString(
                        """<svg class="h-1/2 w-1/2" fill="currentColor" viewBox="0 0 24 24"><path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" /></svg>""",
                    )
                end
            end
        end
    end
end

@deftag macro Avatar end

"""
    @Icon

Icon wrapper component for consistent sizing and styling.

# Props
- `size::Union{Symbol,String}`: Icon size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) (default: `:md`)
- `color::Union{String,Nothing}`: Icon color class (optional)
- `name::Union{String,Nothing}`: Icon name for built-in icons (optional)
- `aria_label::Union{String,Nothing}`: ARIA label for interactive icons (optional)
- `decorative::Bool`: Whether icon is purely decorative (default: `true`)
"""
@component function Icon(;
    size::Union{Symbol,String} = :md,
    color::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    aria_label::Union{String,Nothing} = nothing,
    decorative::Bool = true,
    attrs...,
)
    # Convert to symbol
    size_sym = Symbol(size)

    size_classes = Dict(
        :xs => "h-3 w-3",
        :sm => "h-4 w-4",
        :md => "h-5 w-5",
        :lg => "h-6 w-6",
        :xl => "h-8 w-8",
    )

    size_class = get(size_classes, size_sym, size_classes[:md])
    color_class = isnothing(color) ? "text-current" : color

    # Built-in icons
    icons = Dict(
        "check" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" /></svg>""",
        "x" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>""",
        "arrow-right" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M14 5l7 7m0 0l-7 7m7-7H3" /></svg>""",
        "arrow-left" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>""",
        "chevron-down" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" /></svg>""",
        "chevron-up" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 15l7-7 7 7" /></svg>""",
        "menu" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" /></svg>""",
        "search" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>""",
        "plus" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" /></svg>""",
        "minus" => """<svg width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 12H4" /></svg>""",
    )

    # Set aria-hidden for decorative icons, or aria-label for interactive ones
    aria_hidden = decorative && isnothing(aria_label) ? "true" : nothing

    @span {
        class = "inline-flex items-center justify-center $size_class $color_class",
        "aria-hidden" = aria_hidden,
        "aria-label" = aria_label,
        attrs...,
    } begin
        if !isnothing(name) && haskey(icons, name)
            @text HypertextTemplates.SafeString(icons[name])
        else
            # Slot for custom icon content
            @__slot__()
        end
    end
end

@deftag macro Icon end

"""
    @ThemeToggle

Theme toggle button component that cycles through light, dark, and system themes.

# Props
- `id::String`: HTML id for the button (default: `"theme-toggle"`)
- `variant::Union{Symbol,String}`: Button variant style (`:default`, `:ghost`, `:outline`) (default: `:default`)
- `size::Union{Symbol,String}`: Button size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `show_label::Bool`: Whether to show text label alongside icon (default: `true`)
- `class::String`: Additional CSS classes (optional)

# Example
```julia
@ThemeToggle {}
@ThemeToggle {variant = :ghost, size = :sm, show_label = false}
```

# Requirements
This component requires the theme management JavaScript to be included in your page.
"""
@component function ThemeToggle(;
    id::String = "theme-toggle",
    variant::Union{Symbol,String} = :default,
    size::Union{Symbol,String} = :md,
    show_label::Bool = true,
    class::String = "",
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    # Base classes
    base_classes = "inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-slate-400 dark:focus:ring-slate-600"

    # Variant classes
    variant_classes = Dict(
        :default => "bg-slate-100 dark:bg-slate-700 hover:bg-slate-200 dark:hover:bg-slate-600 text-slate-700 dark:text-slate-300",
        :ghost => "hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300",
        :outline => "border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300",
    )

    # Size classes
    size_classes = Dict(
        :sm => "px-2.5 py-1.5 text-sm rounded",
        :md => "px-3 py-2 text-sm rounded-lg",
        :lg => "px-4 py-2.5 text-base rounded-lg",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes[:default])
    size_class = get(size_classes, size_sym, size_classes[:md])

    @button {
        id = id,
        type = "button",
        onclick = "toggleTheme()",
        class = "$base_classes $variant_class $size_class $class",
        title = "Toggle theme",
        "data-show-label" = show_label ? "true" : "false",
        attrs...,
    } begin
        if show_label
            @text "💻 System"
        else
            # Icon only - still needs text for screen readers
            @span {"aria-hidden" = "true"} "💻"
            @span {class = "sr-only"} "Toggle theme"
        end
    end
end

@deftag macro ThemeToggle end

"""
    theme_toggle_script()

Returns the JavaScript code needed for the ThemeToggle component to function.
This should be included in your page's <head> section.

# Example
```julia
@script begin
    @text HypertextTemplates.SafeString(theme_toggle_script())
end
```
"""
function theme_toggle_script()
    return """
// Theme management
const getStoredTheme = () => localStorage.getItem('theme') || 'system';

const getSystemTheme = () => {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
};

const applyTheme = (theme) => {
    const effectiveTheme = theme === 'system' ? getSystemTheme() : theme;
    if (effectiveTheme === 'dark') {
        document.documentElement.classList.add('dark');
    } else {
        document.documentElement.classList.remove('dark');
    }
};

const setTheme = (theme) => {
    localStorage.setItem('theme', theme);
    applyTheme(theme);
};

// Set initial theme
setTheme(getStoredTheme());

// Listen for system theme changes
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
    if (getStoredTheme() === 'system') {
        applyTheme('system');
    }
});

// Theme toggle function (cycles through light -> dark -> system)
window.toggleTheme = () => {
    const currentTheme = getStoredTheme();
    let newTheme;
    if (currentTheme === 'light') {
        newTheme = 'dark';
    } else if (currentTheme === 'dark') {
        newTheme = 'system';
    } else {
        newTheme = 'light';
    }
    setTheme(newTheme);
    updateThemeButtons();
};

// Update all theme toggle buttons
window.updateThemeButtons = () => {
    const theme = getStoredTheme();
    const buttons = document.querySelectorAll('[onclick="toggleTheme()"]');
    const icons = {
        light: '☀️',
        dark: '🌙',
        system: '💻'
    };
    const labels = {
        light: 'Light',
        dark: 'Dark',
        system: 'System'
    };
    
    buttons.forEach(button => {
        const showLabel = button.dataset.showLabel === 'true';
        if (showLabel) {
            button.innerHTML = icons[theme] + ' ' + labels[theme];
        } else {
            button.querySelector('[aria-hidden]').textContent = icons[theme];
        }
    });
};

// Update buttons on load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', updateThemeButtons);
} else {
    updateThemeButtons();
}
"""
end
