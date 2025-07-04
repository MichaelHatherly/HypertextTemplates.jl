"""
    @SelectDropdown

An enhanced dropdown select component with search functionality, keyboard navigation, and multiple selection support. Features type-ahead search, clear buttons, and full accessibility with Alpine.js integration.

# Props
- `options::Vector{Tuple{String,String}}`: Options as (value, label) tuples
- `placeholder::Union{String,Nothing}`: Placeholder text (default: "Select...")
- `searchable::Bool`: Enable search functionality (default: `false`)
- `multiple::Bool`: Enable multiple selection (default: `false`)
- `clearable::Bool`: Enable clear button to reset selection (default: `false`)
- `max_height::String`: Maximum height of dropdown (default: "300px")
- `size::Union{Symbol,String}`: Component size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `state::Union{Symbol,String}`: Component state (`:default`, `:error`, `:success`) (default: `:default`)
- `name::Union{String,Nothing}`: Form field name (optional)
- `value::Union{String,Vector{String},Nothing}`: Selected value(s) (optional)
- `disabled::Bool`: Whether component is disabled (default: `false`)
- `required::Bool`: Whether field is required (default: `false`)
- `id::Union{String,Nothing}`: Component ID (optional)

# Requirements
This component requires Alpine.js and Alpine Anchor for intelligent positioning:

```html
<script defer src="https://cdn.jsdelivr.net/npm/@alpinejs/anchor@latest/dist/cdn.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

**Browser Compatibility:** Modern browsers with ES6 support  
**Dependencies:** Tailwind CSS for styling classes

**Note:** JavaScript assets are automatically loaded via `@__once__` for optimal performance.

# Accessibility
**ARIA Patterns:** Uses `role="listbox"` with proper option roles, `aria-expanded` state, and `aria-selected` for selections.

**Keyboard Navigation:** Space/Enter to open, Arrow keys to navigate, Escape to close, type-ahead search support.

**Screen Reader Support:** Selection changes, option count, and search functionality are announced. Works with form validation.

**Visual Design:** High contrast focus indicators and touch-friendly spacing on mobile devices.
"""
@component function SelectDropdown(;
    options::Vector{Tuple{String,String}} = Tuple{String,String}[],
    placeholder::Union{String,Nothing} = "Select...",
    searchable::Bool = false,
    multiple::Bool = false,
    clearable::Bool = false,
    max_height::String = "300px",
    size::Union{Symbol,String} = :base,
    state::Union{Symbol,String} = :default,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Vector{String},Nothing} = nothing,
    disabled::Bool = false,
    required::Bool = false,
    id::Union{String,Nothing} = nothing,
    _hash = hash(time_ns()),
    attrs...,
)
    # Load JavaScript for dropdown functionality
    @__once__ begin
        @script @text SafeString(
            read(joinpath(@__DIR__, "../assets/select-dropdown.js"), String),
        )
    end
    # Convert to symbols
    size_sym = Symbol(size)
    state_sym = Symbol(state)

    # Get theme from context
    theme = @get_context(:theme)

    # Generate unique ID if not provided
    component_id = isnothing(id) ? "select-dropdown-$(_hash)" : id
    dropdown_id = "$(component_id)-dropdown"

    # Helper to escape JavaScript strings  
    escape_js(s::String) = replace(replace(s, "\\" => "\\\\"), "'" => "\\'")

    # Create configuration object for Alpine component
    # Using JSON-like syntax for better reliability
    options_json = "["
    for (i, (val, label)) in enumerate(options)
        if i > 1
            options_json *= ", "
        end
        options_json *= "['$(escape_js(val))', '$(escape_js(label))']"
    end
    options_json *= "]"

    # Build configuration string
    config_parts = String[]
    push!(config_parts, "options: $options_json")
    push!(config_parts, "multiple: $(multiple ? "true" : "false")")
    push!(config_parts, "searchable: $(searchable ? "true" : "false")")
    push!(config_parts, "clearable: $(clearable ? "true" : "false")")
    push!(config_parts, "disabled: $(disabled ? "true" : "false")")
    push!(config_parts, "maxHeight: '$(escape_js(max_height))'")

    if !isnothing(placeholder)
        push!(config_parts, "placeholder: '$(escape_js(placeholder))'")
    end

    if !isnothing(name)
        push!(config_parts, "name: '$(escape_js(name))'")
    end

    # Handle initial value
    if !isnothing(value)
        if multiple
            value_json = "[" * join(["'$(escape_js(v))'" for v in value], ", ") * "]"
            push!(config_parts, "value: $value_json")
        else
            push!(config_parts, "value: '$(escape_js(value))'")
        end
    end

    alpine_config = SafeString("{" * join(config_parts, ", ") * "}")

    # Get size class
    size_class = theme.select_dropdown.sizes[size_sym]

    # Get state class
    state_class = theme.select_dropdown.states[state_sym]

    # Get disabled/enabled class
    disabled_class = disabled ? theme.select_dropdown.disabled : theme.select_dropdown.enabled

    # Get theme classes
    container_class = theme.select_dropdown.container
    button_class = theme.select_dropdown.button
    placeholder_color = theme.select_dropdown.placeholder_color
    dropdown_arrow_class = theme.select_dropdown.dropdown_arrow

    # Build the component
    @div {
        var"x-data" = SafeString("selectDropdown($alpine_config)"),
        var"@keydown" = "handleKeydown(\$event)",
        class = container_class,
        attrs...,
    } begin
        # Hidden inputs container will be managed by Alpine component
        @div {var"data-select-inputs" = "", style = "display: none"}

        # Wrapper for button and clear button
        @div {class = "relative"} begin
            # Dropdown trigger button
            @button {
                type = "button",
                var"x-ref" = "button",
                var"@click" = "toggle()",
                var":aria-expanded" = "open.toString()",
                var"aria-haspopup" = "listbox",
                var"aria-controls" = dropdown_id,
                disabled = disabled,
                required = required,
                class = "$button_class $size_class $state_class $disabled_class",
            } begin
                @span {
                    var"x-text" = "selectedLabel",
                    var":class" = "{ '$placeholder_color': !hasSelection }",
                    class =
                        clearable ?
                        theme.select_dropdown.selected_label_padding.with_clear :
                        theme.select_dropdown.selected_label_padding.without_clear,
                } begin
                    if !isnothing(placeholder)
                        @text placeholder
                    end
                end

                # Dropdown arrow
                @svg {
                    class = dropdown_arrow_class,
                    var":class" = "{ 'rotate-180': open },",
                    xmlns = "http://www.w3.org/2000/svg",
                    viewBox = "0 0 20 20",
                    fill = "currentColor",
                } begin
                    @path {
                        var"fill-rule" = "evenodd",
                        d = "M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z",
                        var"clip-rule" = "evenodd",
                    }
                end
            end

            # Clear button (outside main button)
            if clearable
                clear_button_class = theme.select_dropdown.clear_button
                clear_icon_class = theme.select_dropdown.clear_icon

                @button {
                    type = "button",
                    var"@click.stop" = "clearSelection()",
                    var"x-show" = "hasSelection",
                    var"x-transition:enter" = "transition ease-out duration-150",
                    var"x-transition:enter-start" = "opacity-0 scale-75",
                    var"x-transition:enter-end" = "opacity-100 scale-100",
                    var"x-transition:leave" = "transition ease-in duration-100",
                    var"x-transition:leave-start" = "opacity-100 scale-100",
                    var"x-transition:leave-end" = "opacity-0 scale-75",
                    class = clear_button_class,
                    var"aria-label" = "Clear selection",
                } begin
                    @svg {
                        class = clear_icon_class,
                        xmlns = "http://www.w3.org/2000/svg",
                        viewBox = "0 0 20 20",
                        fill = "currentColor",
                    } begin
                        @path {
                            var"fill-rule" = "evenodd",
                            d = "M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z",
                            var"clip-rule" = "evenodd",
                        }
                    end
                end
            end
        end

        # Dropdown panel
        dropdown_panel_class = theme.select_dropdown.dropdown_panel

        @div {
            var"x-show" = "open",
            var"x-anchor.bottom-start.offset.4" = SafeString("\$refs.button"),
            var"x-transition:enter" = "transition ease-out duration-200",
            var"x-transition:enter-start" = "opacity-0 transform scale-95",
            var"x-transition:enter-end" = "opacity-100 transform scale-100",
            var"x-transition:leave" = "transition ease-in duration-150",
            var"x-transition:leave-start" = "opacity-100 transform scale-100",
            var"x-transition:leave-end" = "opacity-0 transform scale-95",
            var"@click.away" = "handleClickOutside()",
            id = dropdown_id,
            class = dropdown_panel_class,
            role = "listbox",
            var"aria-label" = placeholder,
        } begin
            # Search input (if searchable)
            if searchable
                search_wrapper_class = theme.select_dropdown.search_wrapper
                search_input_class = theme.select_dropdown.search_input

                @div {class = search_wrapper_class} begin
                    @input {
                        type = "text",
                        var"x-ref" = "search",
                        var"x-model" = "search",
                        var"@click.stop" = "",
                        placeholder = "Search...",
                        class = search_input_class,
                    }
                end
            end

            # Options list
            options_list_class = theme.select_dropdown.options_list

            @div {
                class = options_list_class,
                style = "max-height: $max_height",
                var"x-ref" = "optionsList",
            } begin
                @template {
                    var"x-for" = "(option, index) in filteredOptions",
                    var":key" = "option[0]",
                } begin
                    option_button_class = theme.select_dropdown.option_button
                    option_highlighted = theme.select_dropdown.option_highlighted
                    option_selected = theme.select_dropdown.option_selected
                    option_wrapper_class = theme.select_dropdown.option_wrapper

                    @button {
                        type = "button",
                        var"@click" = "selectOption(option[0])",
                        var":class" = """{
                            '$option_highlighted': highlighted === index,
                            '$option_selected': isSelected(option[0])
                        }""",
                        var"@mouseenter" = "highlighted = index",
                        var":data-index" = "index",
                        class = option_button_class,
                        role = "option",
                        var":aria-selected" = "isSelected(option[0])",
                    } begin
                        @div {class = option_wrapper_class} begin
                            if multiple
                                checkbox_wrapper_class = theme.select_dropdown.checkbox_wrapper
                                checkbox_class = theme.select_dropdown.checkbox
                                checkbox_unchecked = theme.select_dropdown.checkbox_unchecked
                                checkbox_checked = theme.select_dropdown.checkbox_checked
                                checkbox_icon_class = theme.select_dropdown.checkbox_icon

                                @div {class = checkbox_wrapper_class} begin
                                    @div {
                                        class = checkbox_class,
                                        var":class" = """{
                                            '$checkbox_checked': isSelected(option[0]),
                                            '$checkbox_unchecked': !isSelected(option[0])
                                        }""",
                                    } begin
                                        @svg {
                                            var"x-show" = "isSelected(option[0])",
                                            class = checkbox_icon_class,
                                            fill = "none",
                                            viewBox = "0 0 24 24",
                                            stroke = "currentColor",
                                        } begin
                                            @path {
                                                var"stroke-linecap" = "round",
                                                var"stroke-linejoin" = "round",
                                                var"stroke-width" = "3",
                                                d = "M5 13l4 4L19 7",
                                            }
                                        end
                                    end
                                end
                            end
                            option_text_class = theme.select_dropdown.option_text

                            @span {var"x-text" = "option[1]", class = option_text_class}
                        end
                    end
                end

                # No results message
                no_results_class = theme.select_dropdown.no_results

                @div {
                    var"x-show" = "search && filteredOptions.length === 0",
                    class = no_results_class,
                } "No options found"
            end
        end
    end
end

@deftag macro SelectDropdown end
