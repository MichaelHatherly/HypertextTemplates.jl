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

    # Size classes (matching Input component)
    size_classes = (
        xs = "px-2.5 py-1.5 text-xs",
        sm = "px-3 py-2 text-sm",
        base = "px-4 py-2.5 text-base",
        lg = "px-5 py-3 text-lg",
        xl = "px-6 py-3.5 text-xl",
    )

    state_classes = (
        default = "border-slate-300 focus:border-indigo-500 focus:ring-indigo-500/20 dark:border-slate-600 dark:focus:border-indigo-400",
        error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500/20 dark:border-rose-600 dark:focus:border-rose-400",
        success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500/20 dark:border-emerald-600 dark:focus:border-emerald-400",
    )

    size_class = get(size_classes, size_sym, size_classes.base)
    state_class = get(state_classes, state_sym, state_classes.default)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : "cursor-pointer"

    # Build the component
    @div {
        var"x-data" = SafeString("selectDropdown($alpine_config)"),
        var"@keydown" = "handleKeydown(\$event)",
        class = "relative",
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
                class = "w-full flex items-center justify-between rounded-md border bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-offset-0 transition-colors duration-150 hover:border-slate-400 dark:hover:border-slate-500 $size_class $state_class $disabled_class",
            } begin
                @span {
                    var"x-text" = "selectedLabel",
                    var":class" = "{ 'text-slate-500 dark:text-slate-400': !hasSelection }",
                    class = clearable ? "pr-12" : "pr-8",
                } begin
                    if !isnothing(placeholder)
                        @text placeholder
                    end
                end

                # Dropdown arrow
                @svg {
                    class = "absolute right-3 h-5 w-5 text-slate-400 transition-transform duration-150 pointer-events-none",
                    var":class" = "{ 'rotate-180': open }",
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
                    class = "absolute right-10 top-1/2 -translate-y-1/2 p-1 rounded-md hover:bg-slate-100 dark:hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-indigo-500/30",
                    var"aria-label" = "Clear selection",
                } begin
                    @svg {
                        class = "h-4 w-4 text-slate-500 dark:text-slate-400",
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
        @div {
            var"x-show" = "open",
            var"x-anchor.bottom-start.offset.4" = SafeString("\$refs.button"),
            var"x-transition:enter" = "transition ease-out duration-150",
            var"x-transition:enter-start" = "opacity-0 transform scale-95",
            var"x-transition:enter-end" = "opacity-100 transform scale-100",
            var"x-transition:leave" = "transition ease-in duration-100",
            var"x-transition:leave-start" = "opacity-100 transform scale-100",
            var"x-transition:leave-end" = "opacity-0 transform scale-95",
            var"@click.away" = "handleClickOutside()",
            id = dropdown_id,
            class = "absolute z-50 w-full rounded-lg bg-white dark:bg-slate-900 shadow-[0_4px_12px_rgba(0,0,0,0.08)] ring-1 ring-slate-200 dark:ring-slate-700 overflow-hidden",
            role = "listbox",
            var"aria-label" = placeholder,
        } begin
            # Search input (if searchable)
            if searchable
                @div {class = "p-2 border-b border-slate-200 dark:border-slate-700"} begin
                    @input {
                        type = "text",
                        var"x-ref" = "search",
                        var"x-model" = "search",
                        var"@click.stop" = "",
                        placeholder = "Search...",
                        class = "w-full px-3 py-2 text-sm rounded-md border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100 placeholder:text-slate-400 dark:placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500",
                    }
                end
            end

            # Options list
            @div {
                class = "overflow-y-auto",
                style = "max-height: $max_height",
                var"x-ref" = "optionsList",
            } begin
                @template {
                    var"x-for" = "(option, index) in filteredOptions",
                    var":key" = "option[0]",
                } begin
                    @button {
                        type = "button",
                        var"@click" = "selectOption(option[0])",
                        var":class" = """{
                            'bg-indigo-50 dark:bg-indigo-900/20': highlighted === index,
                            'bg-indigo-100 dark:bg-indigo-900/40': isSelected(option[0])
                        }""",
                        var"@mouseenter" = "highlighted = index",
                        var":data-index" = "index",
                        class = "w-full px-4 py-2.5 text-left text-sm hover:bg-slate-50 dark:hover:bg-slate-800 focus:outline-none focus:bg-slate-50 dark:focus:bg-slate-800 transition-colors duration-150",
                        role = "option",
                        var":aria-selected" = "isSelected(option[0])",
                    } begin
                        @div {class = "flex items-center"} begin
                            if multiple
                                @div {class = "mr-3"} begin
                                    @div {
                                        class = "h-4 w-4 rounded border-2 transition-colors duration-150",
                                        var":class" = """{
                                            'border-indigo-500 bg-indigo-500': isSelected(option[0]),
                                            'border-slate-300 dark:border-slate-600': !isSelected(option[0])
                                        }""",
                                    } begin
                                        @svg {
                                            var"x-show" = "isSelected(option[0])",
                                            class = "h-3 w-3 text-white",
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
                            @span {
                                var"x-text" = "option[1]",
                                class = "text-slate-900 dark:text-slate-100",
                            }
                        end
                    end
                end

                # No results message
                @div {
                    var"x-show" = "search && filteredOptions.length === 0",
                    class = "px-4 py-8 text-center text-sm text-slate-500 dark:text-slate-400",
                } "No options found"
            end
        end
    end
end

@deftag macro SelectDropdown end
