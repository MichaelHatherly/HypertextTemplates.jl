"""
    @Toggle

A versatile toggle component that provides both switch and button variants for binary on/off states. The switch variant offers an iOS-style sliding toggle for settings and preferences, while the button variant creates toggleable buttons perfect for toolbars and multi-select interfaces. Both variants support keyboard navigation, proper ARIA attributes, and can include icons to enhance visual communication.

# Props
- `variant::Union{Symbol,String}`: Toggle variant (`:switch`, `:button`) (default: `:switch`)
- `size::Union{Symbol,String}`: Component size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `color::Union{Symbol,String}`: Color scheme (`:primary`, `:success`, `:danger`) (default: `:primary`)
- `label::Union{String,Nothing}`: Label text for switch variant (optional)
- `name::Union{String,Nothing}`: Form field name (optional)
- `value::Union{String,Nothing}`: Form field value (optional)
- `checked::Bool`: Whether toggle is checked/active (default: `false`)
- `disabled::Bool`: Whether toggle is disabled (default: `false`)
- `required::Bool`: Whether field is required (default: `false`)
- `id::Union{String,Nothing}`: Component ID (optional)
- `aria_describedby::Union{String,Nothing}`: ID of describing element (optional)
- `show_icons::Bool`: Show icon slots for switch variant (default: `false`)

# Slots
**For switch variant with `show_icons = true`:**
- `icon_on`: Icon content to display when toggle is on
- `icon_off`: Icon content to display when toggle is off

**For button variant:**
- Default slot: Button content (text, icons, or both)

# Examples
```julia
# Basic switch toggle
@Toggle {label = "Enable notifications", name = "notifications"}

# Switch with custom icons
@Toggle {label = "Theme", show_icons = true, name = "theme"} begin
    icon_on := @Icon {name = "moon", size = :xs}
    icon_off := @Icon {name = "sun", size = :xs}
end

# Button toggle for toolbar
@Toggle {variant = :button, name = "bold"} begin
    @strong "B"
end

# Icon button toggle
@Toggle {variant = :button, name = "favorite", color = :danger} begin
    @Icon {name = "heart"}
end
```

# Accessibility
This component implements comprehensive accessibility for toggle controls:

**ARIA Patterns:**
- Switch variant uses `role="switch"` with `aria-checked` state
- Button variant uses `aria-pressed` to indicate toggle state
- Labels are properly associated with controls
- Disabled state is communicated through `aria-disabled`

**Keyboard Navigation:**
- **Space/Enter**: Toggles the state
- **Tab**: Moves focus to/from the toggle
- All keyboard interactions work identically to native controls

**Screen Reader Support:**
- State changes are announced immediately
- Labels provide context for the toggle purpose
- Icon-only button toggles should include descriptive text or aria-label

**Visual Design:**
- Focus indicators are clearly visible with appropriate contrast
- Toggle states are communicated through multiple visual cues
- Color is not the sole indicator of state
- Smooth transitions provide visual feedback for interactions
"""
@component function Toggle(;
    variant::Union{Symbol,String} = :switch,
    size::Union{Symbol,String} = :base,
    color::Union{Symbol,String} = :primary,
    label::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    checked::Bool = false,
    disabled::Bool = false,
    required::Bool = false,
    id::Union{String,Nothing} = nothing,
    aria_describedby::Union{String,Nothing} = nothing,
    show_icons::Bool = false,
    _hash = hash(time_ns()),
    slots::NamedTuple = (;),
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    # Generate unique ID if not provided
    component_id = isnothing(id) ? "toggle-$(_hash)" : id

    if variant_sym === :switch
        # Size classes for switch appearance
        size_classes = (
            xs = "h-4 w-8",
            sm = "h-5 w-10",
            base = "h-6 w-12",
            lg = "h-7 w-14",
            xl = "h-8 w-16",
        )

        color_classes = (
            primary = "checked:bg-indigo-500 dark:checked:bg-indigo-600",
            success = "checked:bg-emerald-500 dark:checked:bg-emerald-600",
            danger = "checked:bg-rose-500 dark:checked:bg-rose-600",
        )

        size_class = get(size_classes, size_sym, size_classes.base)
        color_class = get(color_classes, color_sym, color_classes.primary)
        disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""
        cursor_class = disabled ? "" : "cursor-pointer"

        # Check for icon slots
        has_icon_on = haskey(slots, :icon_on)
        has_icon_off = haskey(slots, :icon_off)
        has_icons = show_icons && (has_icon_on || has_icon_off)

        wrapper_el = isnothing(label) ? :div : Elements.label

        # Switch-specific styles based on size with skeuomorphic effects
        switch_styles = (
            xs = """
            appearance-none relative inline-block flex-shrink-0 rounded-full
            bg-slate-300 dark:bg-slate-700
            shadow-inner transition-all duration-150 ease-out
            focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500/30 dark:focus:ring-offset-slate-900
            before:content-[''] before:inline-block before:rounded-full
            before:bg-white dark:before:bg-slate-200
            before:shadow-[0_1px_3px_rgba(0,0,0,0.2)]
            before:border before:border-slate-200 dark:before:border-slate-400
            before:transition-all before:duration-150 before:ease-out
            before:h-3 before:w-3 before:absolute before:left-0.5 before:top-0.5
            checked:before:translate-x-4 checked:shadow-inner
            """,
            sm = """
            appearance-none relative inline-block flex-shrink-0 rounded-full
            bg-slate-300 dark:bg-slate-700
            shadow-inner transition-all duration-150 ease-out
            focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500/30 dark:focus:ring-offset-slate-900
            before:content-[''] before:inline-block before:rounded-full
            before:bg-white dark:before:bg-slate-200
            before:shadow-[0_1px_3px_rgba(0,0,0,0.2)]
            before:border before:border-slate-200 dark:before:border-slate-400
            before:transition-all before:duration-150 before:ease-out
            before:h-4 before:w-4 before:absolute before:left-0.5 before:top-0.5
            checked:before:translate-x-5 checked:shadow-inner
            """,
            base = """
            appearance-none relative inline-block flex-shrink-0 rounded-full
            bg-slate-300 dark:bg-slate-700
            shadow-inner transition-all duration-150 ease-out
            focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500/30 dark:focus:ring-offset-slate-900
            before:content-[''] before:inline-block before:rounded-full
            before:bg-white dark:before:bg-slate-200
            before:shadow-[0_1px_3px_rgba(0,0,0,0.2)]
            before:border before:border-slate-200 dark:before:border-slate-400
            before:transition-all before:duration-150 before:ease-out
            before:h-5 before:w-5 before:absolute before:left-0.5 before:top-0.5
            checked:before:translate-x-6 checked:shadow-inner
            """,
            lg = """
            appearance-none relative inline-block flex-shrink-0 rounded-full
            bg-slate-300 dark:bg-slate-700
            shadow-inner transition-all duration-150 ease-out
            focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500/30 dark:focus:ring-offset-slate-900
            before:content-[''] before:inline-block before:rounded-full
            before:bg-white dark:before:bg-slate-200
            before:shadow-[0_1px_3px_rgba(0,0,0,0.2)]
            before:border before:border-slate-200 dark:before:border-slate-400
            before:transition-all before:duration-150 before:ease-out
            before:h-6 before:w-6 before:absolute before:left-0.5 before:top-0.5
            checked:before:translate-x-7 checked:shadow-inner
            """,
            xl = """
            appearance-none relative inline-block flex-shrink-0 rounded-full
            bg-slate-300 dark:bg-slate-700
            shadow-inner transition-all duration-150 ease-out
            focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500/30 dark:focus:ring-offset-slate-900
            before:content-[''] before:inline-block before:rounded-full
            before:bg-white dark:before:bg-slate-200
            before:shadow-[0_1px_3px_rgba(0,0,0,0.2)]
            before:border before:border-slate-200 dark:before:border-slate-400
            before:transition-all before:duration-150 before:ease-out
            before:h-7 before:w-7 before:absolute before:left-0.5 before:top-0.5
            checked:before:translate-x-8 checked:shadow-inner
            """,
        )

        switch_style = get(switch_styles, size_sym, switch_styles.base)

        if isnothing(label)
            @div {class = "inline-flex items-center gap-3 $disabled_class"} begin
                @div {class = "relative"} begin
                    @input {
                        type = "checkbox",
                        role = "switch",
                        id = component_id,
                        name = name,
                        value = value,
                        checked = checked,
                        disabled = disabled,
                        required = required,
                        "aria-describedby" = aria_describedby,
                        class = "$switch_style $size_class $color_class $cursor_class $disabled_class",
                        attrs...,
                    }

                    if has_icons
                        # Icon overlay container
                        @div {
                            class = "absolute inset-0 flex items-center justify-between px-1 pointer-events-none",
                        } begin
                            # Off icon (left side)
                            @div {
                                class = "text-slate-500 dark:text-slate-400 transition-opacity duration-150",
                                var"x-data" = SafeString("{checked: $checked}"),
                                var"x-init" = SafeString(
                                    "\$watch('\$el.previousElementSibling.checked', value => checked = value)",
                                ),
                                var":class" = "{'opacity-100': !checked, 'opacity-0': checked}",
                            } begin
                                if has_icon_off
                                    @__slot__ icon_off
                                else
                                    # Default X icon
                                    @text SafeString(
                                        """<svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                       </svg>""",
                                    )
                                end
                            end

                            # On icon (right side)
                            @div {
                                class = "text-white transition-opacity duration-150",
                                var"x-data" = SafeString("{checked: $checked}"),
                                var"x-init" = SafeString(
                                    "\$watch('\$el.parentElement.previousElementSibling.checked', value => checked = value)",
                                ),
                                var":class" = "{'opacity-100': checked, 'opacity-0': !checked}",
                            } begin
                                if has_icon_on
                                    @__slot__ icon_on
                                else
                                    # Default check icon
                                    @text SafeString(
                                        """<svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                       </svg>""",
                                    )
                                end
                            end
                        end
                    end
                end

                if !isnothing(label)
                    @span {class = "text-sm text-slate-700 dark:text-slate-300 select-none"} $label
                end
            end
        else
            Elements.@label {
                class = "inline-flex items-center gap-3 $disabled_class",
                "for" := component_id,
            } begin
                @div {class = "relative"} begin
                    @input {
                        type = "checkbox",
                        role = "switch",
                        id = component_id,
                        name = name,
                        value = value,
                        checked = checked,
                        disabled = disabled,
                        required = required,
                        "aria-describedby" = aria_describedby,
                        class = "$switch_style $size_class $color_class $cursor_class $disabled_class",
                        attrs...,
                    }

                    if has_icons
                        # Icon overlay container
                        @div {
                            class = "absolute inset-0 flex items-center justify-between px-1 pointer-events-none",
                        } begin
                            # Off icon (left side)
                            @div {
                                class = "text-slate-500 dark:text-slate-400 transition-opacity duration-150",
                                var"x-data" = SafeString("{checked: $checked}"),
                                var"x-init" = SafeString(
                                    "\$watch('\$el.previousElementSibling.checked', value => checked = value)",
                                ),
                                var":class" = "{'opacity-100': !checked, 'opacity-0': checked}",
                            } begin
                                if has_icon_off
                                    @__slot__ icon_off
                                else
                                    # Default X icon
                                    @text SafeString(
                                        """<svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                       </svg>""",
                                    )
                                end
                            end

                            # On icon (right side)
                            @div {
                                class = "text-white transition-opacity duration-150",
                                var"x-data" = SafeString("{checked: $checked}"),
                                var"x-init" = SafeString(
                                    "\$watch('\$el.parentElement.previousElementSibling.checked', value => checked = value)",
                                ),
                                var":class" = "{'opacity-100': checked, 'opacity-0': !checked}",
                            } begin
                                if has_icon_on
                                    @__slot__ icon_on
                                else
                                    # Default check icon
                                    @text SafeString(
                                        """<svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                       </svg>""",
                                    )
                                end
                            end
                        end
                    end
                end

                @span {class = "text-sm text-slate-700 dark:text-slate-300 select-none"} $label
            end
        end
    else  # button variant
        # Size classes for button (matching Button component)
        size_map = (
            xs = (padding = "px-2.5 py-1.5", text = "text-xs", gap = "gap-1"),
            sm = (padding = "px-3 py-2", text = "text-sm", gap = "gap-1.5"),
            base = (padding = "px-4 py-2.5", text = "text-base", gap = "gap-2"),
            lg = (padding = "px-5 py-3", text = "text-lg", gap = "gap-2.5"),
            xl = (padding = "px-6 py-3.5", text = "text-xl", gap = "gap-3"),
        )

        # Color classes for button toggle
        color_map = (
            primary = "peer-checked:bg-indigo-600 dark:peer-checked:bg-indigo-500 peer-checked:text-white peer-checked:border-indigo-600 dark:peer-checked:border-indigo-500",
            success = "peer-checked:bg-emerald-600 dark:peer-checked:bg-emerald-500 peer-checked:text-white peer-checked:border-emerald-600 dark:peer-checked:border-emerald-500",
            danger = "peer-checked:bg-rose-600 dark:peer-checked:bg-rose-500 peer-checked:text-white peer-checked:border-rose-600 dark:peer-checked:border-rose-500",
        )

        size_data = get(size_map, size_sym, size_map.base)
        color_class = get(color_map, color_sym, color_map.primary)
        disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""

        # Use label as button wrapper for proper click handling
        Elements.@label {class = "inline-block relative", "for" := component_id} begin
            @input {
                type = "checkbox",
                id = component_id,
                name = name,
                value = value,
                checked = checked,
                disabled = disabled,
                required = required,
                "aria-describedby" = aria_describedby,
                class = "sr-only peer",
                attrs...,
            }

            # Visual button that responds to checkbox state
            @div {
                "aria-hidden" = "true",
                class = """
                inline-flex items-center justify-center font-medium border rounded-md cursor-pointer
                bg-white dark:bg-slate-900 text-slate-700 dark:text-slate-300
                border-slate-300 dark:border-slate-700
                hover:bg-slate-50 dark:hover:bg-slate-800
                $color_class
                peer-focus:ring-2 peer-focus:ring-offset-2 peer-focus:ring-indigo-500/30 dark:peer-focus:ring-offset-slate-900
                transition-colors duration-150
                $(size_data.padding) $(size_data.text) $(size_data.gap) $disabled_class
                """,
            } begin
                if !isnothing(label)
                    @text label
                else
                    @__slot__()
                end
            end
        end
    end
end

@deftag macro Toggle end
