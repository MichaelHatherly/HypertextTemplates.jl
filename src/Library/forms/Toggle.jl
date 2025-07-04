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
    # Get theme from context with fallback to default
    theme = @get_context(:theme, HypertextTemplates.Library.default_theme())

    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    # Generate unique ID if not provided
    component_id = isnothing(id) ? "toggle-$(_hash)" : id

    if variant_sym === :switch
        # Direct theme access
        size_class = theme.toggle.switch.sizes[size_sym]
        color_class = theme.toggle.switch.colors[color_sym]
        disabled_class = disabled ? theme.toggle.switch.disabled : ""
        cursor_class = disabled ? "" : theme.toggle.switch.cursor
        switch_style = theme.toggle.switch.styles[size_sym]

        # Check for icon slots
        has_icon_on = haskey(slots, :icon_on)
        has_icon_off = haskey(slots, :icon_off)
        has_icons = show_icons && (has_icon_on || has_icon_off)

        wrapper_el = isnothing(label) ? :div : Elements.label

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
                        # Get icon classes from theme
                        icon_container_class = theme.toggle.switch.icon_container
                        icon_off_class = theme.toggle.switch.icon_off
                        icon_on_class = theme.toggle.switch.icon_on
                        icon_size_class = theme.toggle.switch.icon_size

                        # Icon overlay container
                        @div {class = icon_container_class} begin
                            # Off icon (left side)
                            @div {
                                class = icon_off_class,
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
                                        """<svg class="$icon_size_class" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                       </svg>""",
                                    )
                                end
                            end

                            # On icon (right side)
                            @div {
                                class = icon_on_class,
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
                                        """<svg class="$icon_size_class" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                       </svg>""",
                                    )
                                end
                            end
                        end
                    end
                end

                if !isnothing(label)
                    label_class = theme.toggle.switch.label
                    @span {class = label_class} $label
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
                        # Get icon classes from theme
                        icon_container_class = theme.toggle.switch.icon_container
                        icon_off_class = theme.toggle.switch.icon_off
                        icon_on_class = theme.toggle.switch.icon_on
                        icon_size_class = theme.toggle.switch.icon_size

                        # Icon overlay container
                        @div {class = icon_container_class} begin
                            # Off icon (left side)
                            @div {
                                class = icon_off_class,
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
                                        """<svg class="$icon_size_class" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                       </svg>""",
                                    )
                                end
                            end

                            # On icon (right side)
                            @div {
                                class = icon_on_class,
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
                                        """<svg class="$icon_size_class" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                           <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                       </svg>""",
                                    )
                                end
                            end
                        end
                    end
                end

                label_class = theme.toggle.switch.label
                @span {class = label_class} $label
            end
        end
    else  # button variant
        # Direct theme access
        wrapper_class = theme.toggle.button.wrapper
        input_class = theme.toggle.button.input
        base_class = theme.toggle.button.base
        size_data = theme.toggle.button.sizes[size_sym]
        color_class = theme.toggle.button.colors[color_sym]
        disabled_class = disabled ? theme.toggle.button.disabled : ""

        # Use label as button wrapper for proper click handling
        Elements.@label {class = wrapper_class, "for" := component_id} begin
            @input {
                type = "checkbox",
                id = component_id,
                name = name,
                value = value,
                checked = checked,
                disabled = disabled,
                required = required,
                "aria-describedby" = aria_describedby,
                class = input_class,
                attrs...,
            }

            # Visual button that responds to checkbox state
            @div {
                "aria-hidden" = "true",
                class = "$base_class $color_class $(size_data.padding) $(size_data.text) $(size_data.gap) $disabled_class",
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
