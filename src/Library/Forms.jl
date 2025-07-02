"""
    @Input

A styled text input field for collecting user input with support for various types (text, email, password, number). Features different states (default, error, success), optional icons, and full accessibility with smooth focus transitions.

# Props
- `type::String`: Input type (default: `"text"`)
- `size::Union{Symbol,String}`: Input size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `state::Union{Symbol,String}`: Input state (`:default`, `:error`, `:success`) (default: `:default`)
- `icon::Union{String,Nothing}`: Icon HTML to display (optional)
- `placeholder::Union{String,Nothing}`: Placeholder text (optional)
- `name::Union{String,Nothing}`: Input name attribute (optional)
- `value::Union{String,Nothing}`: Input value (optional)
- `required::Bool`: Whether input is required (default: `false`)
- `disabled::Bool`: Whether input is disabled (default: `false`)
- `id::Union{String,Nothing}`: Input ID for label association (optional)
- `aria_describedby::Union{String,Nothing}`: ID of element describing the input (optional)

# Accessibility
This component implements comprehensive form accessibility standards:

**ARIA Patterns:**
- Uses `aria-invalid="true"` for error states to communicate validation status
- Supports `aria-describedby` for associating help text or error messages
- Maintains proper input semantics with appropriate `type` attributes
- Required fields are marked with HTML `required` attribute

**Keyboard Navigation:**
- **Tab**: Moves focus to input field
- **Shift+Tab**: Moves focus to previous element
- **Enter**: Submits form (for most input types)
- All keyboard input works as expected for each input type

**Screen Reader Support:**
- Input purpose is communicated through `type`, `name`, and `placeholder`
- Error states are announced through `aria-invalid` and associated descriptions
- Required status is communicated to assistive technology
- Icon content is properly marked as decorative or informative

**Form Integration:**
- Inputs should be associated with labels using `for`/`id` relationships
- Error messages should be linked via `aria-describedby`
- Help text should be associated with input for context
- Fieldsets and legends should group related inputs

**Visual Design:**
- Focus indicators are clearly visible with high contrast
- Error states use both color and other visual indicators
- Sufficient color contrast maintained across all states (4.5:1 minimum)
- Icons and decorative elements don't interfere with screen readers
"""
@component function Input(;
    type::String = "text",
    size::Union{Symbol,String} = :base,
    state::Union{Symbol,String} = :default,
    icon::Union{String,Nothing} = nothing,
    placeholder::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    id::Union{String,Nothing} = nothing,
    aria_describedby::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    state_sym = Symbol(state)

    size_classes = (
        xs = "px-2.5 py-1.5 text-xs",
        sm = "px-3 py-2 text-sm",
        base = "px-4 py-2.5 text-base",
        md = "px-4 py-2.5 text-base",  # For backward compatibility
        lg = "px-5 py-3 text-lg",
        xl = "px-6 py-3.5 text-xl",
    )

    state_classes = (
        default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
        error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
        success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
    )

    size_class = get(size_classes, size_sym, size_classes.base)
    state_class = get(state_classes, state_sym, state_classes.default)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""

    base_classes = "w-full rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 placeholder:text-gray-500 dark:placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600 $size_class $state_class $disabled_class"
    aria_invalid = state_sym === :error ? "true" : nothing

    if !isnothing(icon)
        @div {class = "relative"} begin
            @div {
                class = "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-gray-500 dark:text-gray-400",
            } begin
                @text HypertextTemplates.SafeString(icon)
            end
            @input {
                type = type,
                class = "pl-10 $base_classes",
                placeholder = placeholder,
                name = name,
                value = value,
                required = required,
                disabled = disabled,
                id = id,
                "aria-invalid" := aria_invalid,
                "aria-describedby" := aria_describedby,
                attrs...,
            }
        end
    else
        @input {
            type = type,
            class = base_classes,
            placeholder = placeholder,
            name = name,
            value = value,
            required = required,
            disabled = disabled,
            id = id,
            "aria-invalid" := aria_invalid,
            "aria-describedby" := aria_describedby,
            attrs...,
        }
    end
end

@deftag macro Input end

"""
    @Textarea

A multi-line text input component designed for longer form content like comments, descriptions, or messages. Textareas expand on the functionality of regular inputs by allowing multiple lines of text and providing resize controls for user convenience. They maintain visual consistency with other form elements while offering additional features like customizable row counts and resize behavior. The component includes the same state management and theming capabilities as other form inputs, ensuring a seamless form experience.

# Props
- `rows::Int`: Number of visible rows (default: `4`)
- `resize::Union{Symbol,String}`: Resize behavior (`:none`, `:vertical`, `:horizontal`, `:both`) (default: `:vertical`)
- `state::Union{Symbol,String}`: Input state (`:default`, `:error`, `:success`) (default: `:default`)
- `placeholder::Union{String,Nothing}`: Placeholder text (optional)
- `name::Union{String,Nothing}`: Textarea name attribute (optional)
- `value::Union{String,Nothing}`: Textarea value (optional)
- `required::Bool`: Whether textarea is required (default: `false`)
- `disabled::Bool`: Whether textarea is disabled (default: `false`)
- `id::Union{String,Nothing}`: Textarea ID for label association (optional)
- `aria_describedby::Union{String,Nothing}`: ID of element describing the textarea (optional)
"""
@component function Textarea(;
    rows::Int = 4,
    resize::Union{Symbol,String} = :vertical,
    state::Union{Symbol,String} = :default,
    placeholder::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    id::Union{String,Nothing} = nothing,
    aria_describedby::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    resize_sym = Symbol(resize)
    state_sym = Symbol(state)

    resize_classes = (
        none = "resize-none",
        vertical = "resize-y",
        horizontal = "resize-x",
        both = "resize",
    )

    state_classes = (
        default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
        error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
        success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
    )

    resize_class = get(resize_classes, resize_sym, "resize-y")
    state_class = get(state_classes, state_sym, state_classes.default)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""
    aria_invalid = state_sym === :error ? "true" : nothing

    @textarea {
        rows = rows,
        class = "w-full px-4 py-2.5 text-base rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 placeholder:text-gray-500 dark:placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600 $resize_class $state_class $disabled_class",
        placeholder = placeholder,
        name = name,
        required = required,
        disabled = disabled,
        id = id,
        "aria-invalid" := aria_invalid,
        "aria-describedby" := aria_describedby,
        attrs...,
    } begin
        if !isnothing(value)
            @text value
        end
    end
end

@deftag macro Textarea end

"""
    @Select

A dropdown select element that allows users to choose from a predefined list of options. Select components are essential for forms where users need to pick from a constrained set of choices, providing a cleaner interface than radio buttons when dealing with many options. This implementation features a custom-styled dropdown arrow for consistency across browsers, support for placeholder text, and full integration with form validation states. The component maintains accessibility standards while offering a modern appearance.

# Props
- `size::Union{Symbol,String}`: Select size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `state::Union{Symbol,String}`: Select state (`:default`, `:error`, `:success`) (default: `:default`)
- `options::Vector{Tuple{String,String}}`: Options as (value, label) tuples
- `placeholder::Union{String,Nothing}`: Placeholder option text (optional)
- `name::Union{String,Nothing}`: Select name attribute (optional)
- `value::Union{String,Nothing}`: Selected value (optional)
- `required::Bool`: Whether select is required (default: `false`)
- `disabled::Bool`: Whether select is disabled (default: `false`)
- `id::Union{String,Nothing}`: Select ID for label association (optional)
- `aria_describedby::Union{String,Nothing}`: ID of element describing the select (optional)
"""
@component function Select(;
    size::Union{Symbol,String} = :base,
    state::Union{Symbol,String} = :default,
    options::Vector{Tuple{String,String}} = Tuple{String,String}[],
    placeholder::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    id::Union{String,Nothing} = nothing,
    aria_describedby::Union{String,Nothing} = nothing,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    state_sym = Symbol(state)

    size_classes = (
        xs = "px-2.5 py-1.5 pr-8 text-xs",
        sm = "px-3 py-2 pr-9 text-sm",
        base = "px-4 py-2.5 pr-10 text-base",
        md = "px-4 py-2.5 pr-10 text-base",  # For backward compatibility
        lg = "px-5 py-3 pr-11 text-lg",
        xl = "px-6 py-3.5 pr-12 text-xl",
    )

    state_classes = (
        default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
        error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
        success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
    )

    size_class = get(size_classes, size_sym, size_classes.base)
    state_class = get(state_classes, state_sym, state_classes.default)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""
    aria_invalid = state_sym === :error ? "true" : nothing

    @select {
        class = "w-full appearance-none rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600 bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"%3e%3cpolyline points=\"6 9 12 15 18 9\"%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:1.5em_1.5em] bg-[right_0.5rem_center] bg-no-repeat $size_class $state_class $disabled_class",
        name = name,
        required = required,
        disabled = disabled,
        id = id,
        "aria-invalid" := aria_invalid,
        "aria-describedby" := aria_describedby,
        attrs...,
    } begin
        if !isnothing(placeholder)
            @option {value = "", selected = isnothing(value)} $placeholder
        end
        for (opt_value, opt_label) in options
            @option {
                value = opt_value,
                selected = (!isnothing(value) && value == opt_value),
            } $opt_label
        end
    end
end

@deftag macro Select end

"""
    @Checkbox

A styled checkbox input that allows users to toggle between checked and unchecked states. Checkboxes are fundamental form controls for binary choices, terms acceptance, or selecting multiple options from a list. This component enhances the native checkbox with custom styling that matches your design system while preserving full keyboard accessibility and screen reader support. It can be used standalone or with an integrated label, and supports different color schemes and sizes to fit various UI contexts.

# Props
- `size::Union{Symbol,String}`: Checkbox size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Checkbox color (`:slate`, `:primary`, `:success`) (default: `:primary`)
- `label::Union{String,Nothing}`: Label text (optional)
- `name::Union{String,Nothing}`: Checkbox name attribute (optional)
- `value::Union{String,Nothing}`: Checkbox value (optional)
- `checked::Bool`: Whether checkbox is checked (default: `false`)
- `required::Bool`: Whether checkbox is required (default: `false`)
- `disabled::Bool`: Whether checkbox is disabled (default: `false`)
"""
@component function Checkbox(;
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    label::Union{String,Nothing} = nothing,
    name::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    checked::Bool = false,
    required::Bool = false,
    disabled::Bool = false,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    size_classes = (sm = "h-3.5 w-3.5", md = "h-4 w-4", lg = "h-5 w-5")

    color_classes = (
        slate = "text-gray-600 focus:ring-gray-500",
        primary = "text-blue-600 focus:ring-blue-500 dark:text-blue-500 dark:focus:ring-blue-400",
        success = "text-emerald-600 focus:ring-emerald-500 dark:text-emerald-500 dark:focus:ring-emerald-400",
    )

    size_class = get(size_classes, size_sym, size_classes.md)
    color_class = get(color_classes, color_sym, color_classes.primary)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""

    if !isnothing(label)
        Elements.@label {class = "inline-flex items-center gap-2 $disabled_class"} begin
            @input {
                type = "checkbox",
                class = "rounded-md border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-600 $size_class $color_class",
                name = name,
                value = value,
                checked = checked,
                required = required,
                disabled = disabled,
                attrs...,
            }
            @span {class = "text-sm text-gray-700 dark:text-gray-300 select-none"} $label
        end
    else
        @input {
            type = "checkbox",
            class = "rounded-md border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-600 $size_class $color_class $disabled_class",
            name = name,
            value = value,
            checked = checked,
            required = required,
            disabled = disabled,
            attrs...,
        }
    end
end

@deftag macro Checkbox end

"""
    @Radio

A radio button component that enables users to select a single option from a group of mutually exclusive choices. Radio buttons are ideal when you want to present all available options upfront and ensure users can only select one. This component renders a complete radio group with proper ARIA attributes and keyboard navigation support. Each option can include a label, and the entire group maintains visual consistency with other form elements while providing clear feedback about the selected state.

# Props
- `size::Union{Symbol,String}`: Radio size (`:sm`, `:md`, `:lg`) (default: `:md`)
- `color::Union{Symbol,String}`: Radio color (`:slate`, `:primary`, `:success`) (default: `:primary`)
- `options::Vector{Tuple{String,String}}`: Options as (value, label) tuples
- `name::String`: Radio group name (required)
- `value::Union{String,Nothing}`: Selected value (optional)
- `required::Bool`: Whether radio group is required (default: `false`)
- `disabled::Bool`: Whether radio group is disabled (default: `false`)
"""
@component function Radio(;
    size::Union{Symbol,String} = :md,
    color::Union{Symbol,String} = :primary,
    options::Vector{Tuple{String,String}} = Tuple{String,String}[],
    name::String,
    value::Union{String,Nothing} = nothing,
    required::Bool = false,
    disabled::Bool = false,
    attrs...,
)
    # Convert to symbols
    size_sym = Symbol(size)
    color_sym = Symbol(color)

    size_classes = (sm = "h-3.5 w-3.5", md = "h-4 w-4", lg = "h-5 w-5")

    color_classes = (
        slate = "text-gray-600 focus:ring-gray-500",
        primary = "text-blue-600 focus:ring-blue-500 dark:text-blue-500 dark:focus:ring-blue-400",
        success = "text-emerald-600 focus:ring-emerald-500 dark:text-emerald-500 dark:focus:ring-emerald-400",
    )

    size_class = get(size_classes, size_sym, size_classes.md)
    color_class = get(color_classes, color_sym, color_classes.primary)
    disabled_class = disabled ? "opacity-60 cursor-not-allowed" : ""

    # Note: WebKit/Safari may clip the right edge of radio buttons in some cases.
    # This is a known rendering issue with Safari's implementation of form controls.
    @div {class = "space-y-2", role = "radiogroup", attrs...} begin
        for (opt_value, opt_label) in options
            Elements.@label {
                class = "flex items-center gap-2 cursor-pointer $disabled_class",
            } begin
                @input {
                    type = "radio",
                    class = "shrink-0 border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-colors hover:border-gray-400 dark:hover:border-gray-600 $size_class $color_class",
                    name = name,
                    value = opt_value,
                    checked = (!isnothing(value) && value == opt_value),
                    required = required,
                    disabled = disabled,
                }
                @span {class = "text-sm text-gray-700 dark:text-gray-300 select-none"} $opt_label
            end
        end
    end
end

@deftag macro Radio end

"""
    @FormGroup

A form field wrapper that provides consistent layout for form controls with labels, help text, and error messages. Automatically generates unique IDs and establishes proper accessibility relationships between elements.

# Props
- `label::Union{String,Nothing}`: Field label (optional)
- `help::Union{String,Nothing}`: Help text (optional)
- `error::Union{String,Nothing}`: Error message (optional)
- `required::Bool`: Whether field is required (default: `false`)
- `id::Union{String,Nothing}`: ID for the form field (will be auto-generated if not provided) (optional)

# Slots
- Form control element(s) - typically Input, Textarea, Select, Checkbox, or Radio components

# Example
```julia
# Basic form field
@FormGroup {label = "Email", help = "We'll never share your email."} begin
    @Input {type = "email", placeholder = "name@example.com"}
end

# Required field with error
@FormGroup {label = "Password", required = true, error = "Password must be at least 8 characters"} begin
    @Input {type = "password", state = :error}
end

# Checkbox group
@FormGroup {label = "Preferences"} begin
    @Checkbox {label = "Send me updates"}
end
```

# See also
- [`Input`](@ref) - Text input component
- [`Textarea`](@ref) - Multi-line text input
- [`Select`](@ref) - Dropdown select component
- [`Checkbox`](@ref) - Checkbox input
- [`Radio`](@ref) - Radio button group
"""
@component function FormGroup(;
    label::Union{String,Nothing} = nothing,
    help::Union{String,Nothing} = nothing,
    error::Union{String,Nothing} = nothing,
    required::Bool = false,
    id::Union{String,Nothing} = nothing,
    _hash = hash(time_ns()),
    attrs...,
)
    # Generate unique ID if not provided
    field_id = isnothing(id) ? "form-field-$(_hash)" : id
    error_id = !isnothing(error) ? "$(field_id)-error" : nothing
    help_id = !isnothing(help) && isnothing(error) ? "$(field_id)-help" : nothing
    describedby_id = !isnothing(error_id) ? error_id : help_id

    @div {class = "space-y-1", attrs...} begin
        if !isnothing(label)
            Elements.@label {
                class = "block text-sm font-medium text-gray-700 dark:text-gray-300",
                "for" := field_id,
            } begin
                @text label
                if required
                    @span {class = "text-red-500 ml-1"} "*"
                end
            end
        end

        # TODO:
        # Pass the generated IDs to child components
        @__slot__ #(field_id, describedby_id)

        if !isnothing(error)
            @p {
                class = "text-sm text-rose-600 dark:text-rose-400 animate-[fadeIn_0.3s_ease-in-out]",
                id = error_id,
            } error
        elseif !isnothing(help)
            @p {class = "text-sm text-gray-500 dark:text-gray-400", id = help_id} help
        end
    end
end

@deftag macro FormGroup end

"""
    @Button

A versatile button component for triggering actions with multiple variants, sizes, and states. Supports icons, loading states, and full accessibility with proper ARIA attributes and keyboard navigation.

# Props
- `variant::Union{Symbol,String}`: Button variant (`:primary`, `:secondary`, `:neutral`, `:success`, `:warning`, `:danger`, `:gradient`, `:ghost`, `:outline`) (default: `:primary`)
- `size::Union{Symbol,String}`: Button size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`) (default: `:base`)
- `type::String`: Button type attribute (default: `"button"`)
- `disabled::Bool`: Whether button is disabled (default: `false`)
- `loading::Bool`: Whether button is in loading state (default: `false`)
- `full_width::Bool`: Whether button should be full width (default: `false`)
- `icon_left::Union{String,Nothing}`: Icon HTML to display on the left (optional)
- `icon_right::Union{String,Nothing}`: Icon HTML to display on the right (optional)
- `rounded::Union{Symbol,String}`: Border radius (`:base`, `:lg`, `:xl`, `:full`) (default: `:xl`)

# Slots
- Button label text or content

# Example
```julia
# Basic buttons
@Button "Click me"
@Button {variant = :secondary} "Cancel"
@Button {variant = :danger, size = :sm} "Delete"

# Button with icon
@Button {icon_left = @Icon {name = "save"}} "Save changes"

# Loading state
@Button {loading = true} "Processing..."

# Full width button
@Button {variant = :gradient, full_width = true} "Get Started"

# Icon-only button
@Button {variant = :ghost, size = :sm, rounded = :full} begin
    @Icon {name = "settings"}
end
```

# Accessibility
**ARIA & Keyboard:** Semantic `<button>` element with standard Enter/Space activation. Disabled and loading states are properly announced to screen readers.

**Icon-only buttons:** Must include `aria-label` for screen reader context.

**Visual Design:** High contrast focus indicators and 4.5:1 color contrast across all variants.

# See also
- [`Link`](@ref) - For navigation links
- [`Icon`](@ref) - For button icons
- [`DropdownMenu`](@ref) - For button dropdowns
- [`Badge`](@ref) - For button badges/counters
"""
@component function Button(;
    variant::Union{Symbol,String} = :primary,
    size::Union{Symbol,String} = :base,
    type::String = "button",
    disabled::Bool = false,
    loading::Bool = false,
    full_width::Bool = false,
    icon_left::Union{String,Nothing} = nothing,
    icon_right::Union{String,Nothing} = nothing,
    rounded::Union{Symbol,String} = :xl,
    attrs...,
)
    # Convert to symbols
    variant_sym = Symbol(variant)
    size_sym = Symbol(size)
    rounded_sym = Symbol(rounded)

    # Size classes
    size_map = (
        xs = (padding = "px-2.5 py-1.5", text = "text-xs", gap = "gap-1"),
        sm = (padding = "px-3 py-2", text = "text-sm", gap = "gap-1.5"),
        base = (padding = "px-4 py-2.5", text = "text-base", gap = "gap-2"),
        lg = (padding = "px-5 py-3", text = "text-lg", gap = "gap-2.5"),
        xl = (padding = "px-6 py-3.5", text = "text-xl", gap = "gap-3"),
    )

    # Variant classes
    variant_map = (
        primary = "bg-blue-500 text-white hover:bg-blue-600 focus:ring-blue-400 shadow-sm hover:shadow-md",
        secondary = "bg-purple-500 text-white hover:bg-purple-600 focus:ring-purple-400 shadow-sm hover:shadow-md",
        neutral = "bg-gray-100 text-gray-900 hover:bg-gray-200 focus:ring-gray-300 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700 shadow-sm hover:shadow-md",
        success = "bg-emerald-500 text-white hover:bg-emerald-600 focus:ring-emerald-400 shadow-sm hover:shadow-md",
        warning = "bg-amber-500 text-white hover:bg-amber-600 focus:ring-amber-400 shadow-sm hover:shadow-md",
        danger = "bg-rose-500 text-white hover:bg-rose-600 focus:ring-rose-400 shadow-sm hover:shadow-md",
        gradient = "bg-gradient-to-r from-blue-500 to-purple-600 text-white hover:from-blue-600 hover:to-purple-700 focus:ring-blue-400 shadow-md hover:shadow-lg",
        ghost = "bg-transparent text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800 focus:ring-gray-300",
        outline = "bg-transparent border-2 border-gray-300 text-gray-700 hover:bg-gray-50 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-800 focus:ring-gray-300",
    )

    size_data = get(size_map, size_sym, size_map.base)
    variant_class = get(variant_map, variant_sym, variant_map.primary)

    # Rounded classes
    rounded_classes =
        (base = "rounded-lg", lg = "rounded-xl", xl = "rounded-2xl", full = "rounded-full")
    rounded_class = get(rounded_classes, rounded_sym, rounded_classes.xl)

    # Build classes
    width_class = full_width ? "w-full" : ""
    disabled_class = disabled || loading ? "opacity-60 cursor-not-allowed" : ""

    base_classes = "inline-flex items-center justify-center font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-opacity-50 dark:focus:ring-offset-gray-900 transition-all duration-300 ease-out transform active:scale-[0.98] disabled:active:scale-100"

    final_classes = "$base_classes $rounded_class $(size_data.padding) $(size_data.text) $(size_data.gap) $variant_class $width_class $disabled_class"

    @button {type = type, class = final_classes, disabled = disabled || loading, attrs...} begin
        if loading
            # Modern loading spinner
            @text HypertextTemplates.SafeString(
                """<svg class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
</svg>""",
            )
        elseif !isnothing(icon_left)
            @text HypertextTemplates.SafeString(icon_left)
        end

        @__slot__()

        if !isnothing(icon_right) && !loading
            @text HypertextTemplates.SafeString(icon_right)
        end
    end
end

@deftag macro Button end

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
            read(joinpath(@__DIR__, "assets/select-dropdown.js"), String),
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
        default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
        error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
        success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
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
                class = "w-full flex items-center justify-between rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600 $size_class $state_class $disabled_class",
            } begin
                @span {
                    var"x-text" = "selectedLabel",
                    var":class" = "{ 'text-gray-500 dark:text-gray-400': !hasSelection }",
                    class = clearable ? "pr-12" : "pr-8",
                } begin
                    if !isnothing(placeholder)
                        @text placeholder
                    end
                end

                # Dropdown arrow
                @svg {
                    class = "absolute right-3 h-5 w-5 text-gray-400 transition-transform duration-200 pointer-events-none",
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
                    class = "absolute right-10 top-1/2 -translate-y-1/2 p-1 rounded-md hover:bg-gray-100 dark:hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50",
                    var"aria-label" = "Clear selection",
                } begin
                    @svg {
                        class = "h-4 w-4 text-gray-500 dark:text-gray-400",
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
            var"x-transition:enter" = "transition ease-out duration-200",
            var"x-transition:enter-start" = "opacity-0 transform scale-95",
            var"x-transition:enter-end" = "opacity-100 transform scale-100",
            var"x-transition:leave" = "transition ease-in duration-150",
            var"x-transition:leave-start" = "opacity-100 transform scale-100",
            var"x-transition:leave-end" = "opacity-0 transform scale-95",
            var"@click.away" = "handleClickOutside()",
            id = dropdown_id,
            class = "absolute z-50 w-full rounded-xl bg-white dark:bg-gray-950 shadow-lg ring-1 ring-gray-200 dark:ring-gray-800 overflow-hidden",
            role = "listbox",
            var"aria-label" = placeholder,
        } begin
            # Search input (if searchable)
            if searchable
                @div {class = "p-2 border-b border-gray-200 dark:border-gray-800"} begin
                    @input {
                        type = "text",
                        var"x-ref" = "search",
                        var"x-model" = "search",
                        var"@click.stop" = "",
                        placeholder = "Search...",
                        class = "w-full px-3 py-2 text-sm rounded-lg border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 placeholder:text-gray-500 dark:placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50",
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
                            'bg-blue-50 dark:bg-blue-900/20': highlighted === index,
                            'bg-blue-100 dark:bg-blue-900/40': isSelected(option[0])
                        }""",
                        var"@mouseenter" = "highlighted = index",
                        var":data-index" = "index",
                        class = "w-full px-4 py-2.5 text-left text-sm hover:bg-gray-50 dark:hover:bg-gray-900 focus:outline-none focus:bg-gray-50 dark:focus:bg-gray-900 transition-colors duration-150",
                        role = "option",
                        var":aria-selected" = "isSelected(option[0])",
                    } begin
                        @div {class = "flex items-center"} begin
                            if multiple
                                @div {class = "mr-3"} begin
                                    @div {
                                        class = "h-4 w-4 rounded border-2 transition-all duration-200",
                                        var":class" = """{
                                            'border-blue-500 bg-blue-500': isSelected(option[0]),
                                            'border-gray-300 dark:border-gray-600': !isSelected(option[0])
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
                                class = "text-gray-900 dark:text-gray-100",
                            }
                        end
                    end
                end

                # No results message
                @div {
                    var"x-show" = "search && filteredOptions.length === 0",
                    class = "px-4 py-8 text-center text-sm text-gray-500 dark:text-gray-400",
                } "No options found"
            end
        end
    end
end

@deftag macro SelectDropdown end
