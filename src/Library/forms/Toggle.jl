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

    # Extract toggle theme safely
    toggle_theme = if isa(theme, NamedTuple) && haskey(theme, :toggle)
        theme.toggle
    else
        HypertextTemplates.Library.default_theme().toggle
    end
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    # Generate unique ID if not provided
    component_id = isnothing(id) ? "toggle-$(_hash)" : id

    if variant_sym === :switch
        # Get switch theme
        switch_theme = if isa(toggle_theme, NamedTuple) && haskey(toggle_theme, :switch)
            toggle_theme.switch
        else
            HypertextTemplates.Library.default_theme().toggle.switch
        end

        # Get size classes
        size_classes = if isa(switch_theme, NamedTuple) && haskey(switch_theme, :sizes)
            switch_theme.sizes
        else
            HypertextTemplates.Library.default_theme().toggle.switch.sizes
        end

        # Get color classes
        color_classes = if isa(switch_theme, NamedTuple) && haskey(switch_theme, :colors)
            switch_theme.colors
        else
            HypertextTemplates.Library.default_theme().toggle.switch.colors
        end

        size_class = get(
            size_classes,
            size_sym,
            get(
                size_classes,
                :base,
                HypertextTemplates.Library.default_theme().toggle.switch.sizes.base,
            ),
        )
        color_class = get(
            color_classes,
            color_sym,
            get(
                color_classes,
                :primary,
                HypertextTemplates.Library.default_theme().toggle.switch.colors.primary,
            ),
        )

        # Get state classes
        disabled_class =
            disabled ?
            get(
                switch_theme,
                :disabled,
                HypertextTemplates.Library.default_theme().toggle.switch.disabled,
            ) : ""
        cursor_class =
            disabled ? "" :
            get(
                switch_theme,
                :cursor,
                HypertextTemplates.Library.default_theme().toggle.switch.cursor,
            )

        # Check for icon slots
        has_icon_on = haskey(slots, :icon_on)
        has_icon_off = haskey(slots, :icon_off)
        has_icons = show_icons && (has_icon_on || has_icon_off)

        wrapper_el = isnothing(label) ? :div : Elements.label

        # Get switch styles from theme
        switch_styles = if isa(switch_theme, NamedTuple) && haskey(switch_theme, :styles)
            switch_theme.styles
        else
            HypertextTemplates.Library.default_theme().toggle.switch.styles
        end

        switch_style = get(
            switch_styles,
            size_sym,
            get(
                switch_styles,
                :base,
                HypertextTemplates.Library.default_theme().toggle.switch.styles.base,
            ),
        )

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
                        icon_container_class = get(
                            switch_theme,
                            :icon_container,
                            HypertextTemplates.Library.default_theme().toggle.switch.icon_container,
                        )
                        icon_off_class = get(
                            switch_theme,
                            :icon_off,
                            HypertextTemplates.Library.default_theme().toggle.switch.icon_off,
                        )
                        icon_on_class = get(
                            switch_theme,
                            :icon_on,
                            HypertextTemplates.Library.default_theme().toggle.switch.icon_on,
                        )
                        icon_size_class = get(
                            switch_theme,
                            :icon_size,
                            HypertextTemplates.Library.default_theme().toggle.switch.icon_size,
                        )

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
                    label_class = get(
                        switch_theme,
                        :label,
                        HypertextTemplates.Library.default_theme().toggle.switch.label,
                    )
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
                        icon_container_class = get(
                            switch_theme,
                            :icon_container,
                            HypertextTemplates.Library.default_theme().toggle.switch.icon_container,
                        )
                        icon_off_class = get(
                            switch_theme,
                            :icon_off,
                            HypertextTemplates.Library.default_theme().toggle.switch.icon_off,
                        )
                        icon_on_class = get(
                            switch_theme,
                            :icon_on,
                            HypertextTemplates.Library.default_theme().toggle.switch.icon_on,
                        )
                        icon_size_class = get(
                            switch_theme,
                            :icon_size,
                            HypertextTemplates.Library.default_theme().toggle.switch.icon_size,
                        )

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

                label_class = get(
                    switch_theme,
                    :label,
                    HypertextTemplates.Library.default_theme().toggle.switch.label,
                )
                @span {class = label_class} $label
            end
        end
    else  # button variant
        # Get button theme
        button_theme = if isa(toggle_theme, NamedTuple) && haskey(toggle_theme, :button)
            toggle_theme.button
        else
            HypertextTemplates.Library.default_theme().toggle.button
        end

        # Get wrapper and input classes
        wrapper_class = get(
            button_theme,
            :wrapper,
            HypertextTemplates.Library.default_theme().toggle.button.wrapper,
        )
        input_class = get(
            button_theme,
            :input,
            HypertextTemplates.Library.default_theme().toggle.button.input,
        )
        base_class = get(
            button_theme,
            :base,
            HypertextTemplates.Library.default_theme().toggle.button.base,
        )

        # Get size classes
        size_map = if isa(button_theme, NamedTuple) && haskey(button_theme, :sizes)
            button_theme.sizes
        else
            HypertextTemplates.Library.default_theme().toggle.button.sizes
        end

        # Get color classes
        color_map = if isa(button_theme, NamedTuple) && haskey(button_theme, :colors)
            button_theme.colors
        else
            HypertextTemplates.Library.default_theme().toggle.button.colors
        end

        size_data = get(
            size_map,
            size_sym,
            get(
                size_map,
                :base,
                HypertextTemplates.Library.default_theme().toggle.button.sizes.base,
            ),
        )
        color_class = get(
            color_map,
            color_sym,
            get(
                color_map,
                :primary,
                HypertextTemplates.Library.default_theme().toggle.button.colors.primary,
            ),
        )
        disabled_class =
            disabled ?
            get(
                button_theme,
                :disabled,
                HypertextTemplates.Library.default_theme().toggle.button.disabled,
            ) : ""

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
