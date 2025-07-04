"""
    @ThemeToggle

A theme toggle button component that enables users to switch between light, dark, and system-based color schemes with a single click. Theme toggles have become essential for modern web applications, respecting user preferences and improving accessibility for users who need specific contrast levels or reduced eye strain. This component provides a smooth cycling through theme options with visual feedback, remembers user preferences across sessions, and integrates with system-level theme settings. The button adapts its appearance to the current theme and provides clear indication of the active mode through both icons and optional text labels.

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
This component requires Alpine.js to be included in your page:

```html
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

**Browser Compatibility:** Modern browsers with ES6 support  
**Dependencies:** Tailwind CSS for styling classes

**Note:** JavaScript assets are automatically loaded via `@__once__` for optimal performance.

# Accessibility
This component implements comprehensive accessibility for theme switching:

**ARIA Patterns:**
- Uses semantic `<button>` element with descriptive `title` attribute
- Button text dynamically updates to reflect current theme state
- Screen readers announce theme changes when selection occurs
- Maintains button semantics while providing theme functionality

**Keyboard Navigation:**
- **Enter/Space**: Cycles through theme options (light → dark → system)
- **Tab**: Moves focus to theme toggle button
- **Shift+Tab**: Moves focus to previous element
- All theme switching is accessible via keyboard

**Screen Reader Support:**
- Current theme state is announced through button text
- Theme changes are communicated when they occur
- Button purpose is clear through descriptive labeling
- Icon-only mode includes screen reader text for context

**Visual Design:**
- Focus indicators are clearly visible with high contrast
- Button variants maintain sufficient color contrast (4.5:1 minimum)
- Theme icons provide visual feedback for current state
- Hover and active states give clear interactive feedback

**Theme Persistence:**
- Theme preference is stored in localStorage for consistency
- System theme preference is respected and monitored
- Theme changes are applied immediately for visual feedback
- Works across browser sessions and page refreshes

**Usage Guidelines:**
- Place theme toggle in consistent, discoverable location
- Consider using icon + text for maximum clarity
- Test with all three theme states (light, dark, system)
- Ensure theme toggle itself is visible in all themes
"""
@component function ThemeToggle(;
    id::String = "theme-toggle",
    variant::Union{Symbol,String} = :default,
    size::Union{Symbol,String} = :md,
    show_label::Bool = true,
    class::String = "",
    attrs...,
)
    # Load JavaScript for theme functionality
    @__once__ begin
        @script @text SafeString(
            read(joinpath(@__DIR__, "../assets/theme-toggle.js"), String),
        )
    end

    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    # Base classes
    base_classes = "inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-slate-400 dark:focus:ring-slate-600"

    # Variant classes
    variant_classes = (
        default = "bg-slate-100 dark:bg-slate-700 hover:bg-slate-200 dark:hover:bg-slate-600 text-slate-700 dark:text-slate-300",
        ghost = "hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300",
        outline = "border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300",
    )

    # Size classes
    size_classes = (
        sm = "px-2.5 py-1.5 text-sm rounded",
        md = "px-3 py-2 text-sm rounded-lg",
        lg = "px-4 py-2.5 text-base rounded-lg",
    )

    variant_class = get(variant_classes, variant_sym, variant_classes.default)
    size_class = get(size_classes, size_sym, size_classes.md)

    # Build component attributes with Alpine.js
    component_attrs = (
        id = id,
        type = "button",
        var"x-data" = "themeToggle()",
        var"@click" = "toggle()",
        class = "$base_classes $variant_class $size_class $class",
        title = "Toggle theme",
    )

    # Merge with user attributes
    merged_attrs = merge_attrs(component_attrs, attrs)

    @button {merged_attrs...} begin
        if show_label
            @span {var"x-text" = "`\${currentIcon} \${currentLabel}`"} "💻 System"
        else
            # Icon only - still needs text for screen readers
            @span {"aria-hidden" = "true", var"x-text" = "currentIcon"} "💻"
            @span {class = "sr-only"} "Toggle theme"
        end
    end
end

@deftag macro ThemeToggle end
