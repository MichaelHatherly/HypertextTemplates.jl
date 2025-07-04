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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Extract theme_toggle theme safely
    theme_toggle_theme = if isa(theme, NamedTuple) && haskey(theme, :theme_toggle)
        theme.theme_toggle
    else
        HypertextTemplates.Library.default_theme().theme_toggle
    end

    # Get base classes and defaults
    base_classes = get(
        theme_toggle_theme,
        :base,
        HypertextTemplates.Library.default_theme().theme_toggle.base,
    )
    screen_reader_text_class = get(
        theme_toggle_theme,
        :screen_reader_text,
        HypertextTemplates.Library.default_theme().theme_toggle.screen_reader_text,
    )
    default_text = get(
        theme_toggle_theme,
        :default_text,
        HypertextTemplates.Library.default_theme().theme_toggle.default_text,
    )
    default_icon = get(
        theme_toggle_theme,
        :default_icon,
        HypertextTemplates.Library.default_theme().theme_toggle.default_icon,
    )

    # Get nested themes
    variants_theme =
        if isa(theme_toggle_theme, NamedTuple) && haskey(theme_toggle_theme, :variants)
            theme_toggle_theme.variants
        else
            HypertextTemplates.Library.default_theme().theme_toggle.variants
        end

    sizes_theme =
        if isa(theme_toggle_theme, NamedTuple) && haskey(theme_toggle_theme, :sizes)
            theme_toggle_theme.sizes
        else
            HypertextTemplates.Library.default_theme().theme_toggle.sizes
        end

    # Load JavaScript for theme functionality
    @__once__ begin
        @script @text SafeString(
            read(joinpath(@__DIR__, "../assets/theme-toggle.js"), String),
        )
    end

    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)

    variant_class = get(
        variants_theme,
        variant_sym,
        get(
            variants_theme,
            :default,
            HypertextTemplates.Library.default_theme().theme_toggle.variants.default,
        ),
    )
    size_class = get(
        sizes_theme,
        size_sym,
        get(
            sizes_theme,
            :md,
            HypertextTemplates.Library.default_theme().theme_toggle.sizes.md,
        ),
    )

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
            @span {var"x-text" = "`\${currentIcon} \${currentLabel}`"} default_text
        else
            # Icon only - still needs text for screen readers
            @span {"aria-hidden" = "true", var"x-text" = "currentIcon"} default_icon
            @span {class = screen_reader_text_class} "Toggle theme"
        end
    end
end

@deftag macro ThemeToggle end
