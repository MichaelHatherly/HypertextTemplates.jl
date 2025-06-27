# Library Components

HypertextTemplates.jl includes a comprehensive library of pre-built, accessible UI components styled with Tailwind CSS v4. These components follow modern design principles and include dark mode support by default.

## Getting Started

To use the library components, you need to import the Library submodule:

```@example library-getting-started
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Example usage
html = @render @Card {padding=:lg, shadow=:md} begin
    @Heading {level=2} "Welcome"
    @Text "This is a card component with a heading and text."
end

Main.display_html(html) #hide
```

## Component Categories

### Layout Components

These components help structure your page layout and organize content.

#### Container
A responsive container with configurable max-widths and padding.

```@example library-container
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Container {size=:xl, padding=true, centered=true} begin
    @Text "This content is in a centered container with padding."
end

Main.display_html(html) #hide
```

**Props:**
- `size::Symbol` - Container size (`:sm`, `:md`, `:lg`, `:xl`, `"2xl"`) - default: `:xl`
- `padding::Bool` - Include horizontal padding - default: `true`
- `centered::Bool` - Center the container - default: `true`

#### Stack
Layout children vertically or horizontally with consistent spacing.

```@example library-stack
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {direction=:vertical, gap=4, align=:center} begin
    @Text "Item 1"
    @Text "Item 2"
    @Text "Item 3"
end

Main.display_html(html) #hide
```

**Props:**
- `direction::Symbol` - Stack direction (`:vertical`, `:horizontal`) - default: `:vertical`
- `gap::Int` - Gap size using Tailwind spacing scale - default: `4`
- `align::Symbol` - Alignment (`:start`, `:center`, `:end`, `:stretch`) - default: `:stretch`
- `justify::Symbol` - Justification (`:start`, `:center`, `:end`, `:between`, `:around`, `:evenly`) - default: `:start`

#### Grid
Responsive grid layout with configurable columns.

```@example library-grid
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Grid {cols=1, sm=2, md=3, lg=4, gap=4} begin
    @Card {padding=:sm} "Cell 1"
    @Card {padding=:sm} "Cell 2"
    @Card {padding=:sm} "Cell 3"
    @Card {padding=:sm} "Cell 4"
end

Main.display_html(html) #hide
```

**Props:**
- `cols::Int` - Default number of columns - default: `1`
- `sm::Int` - Columns on small screens (optional)
- `md::Int` - Columns on medium screens (optional)
- `lg::Int` - Columns on large screens (optional)
- `xl::Int` - Columns on extra large screens (optional)
- `gap::Int` - Gap size - default: `4`

#### Section
Page section with consistent vertical spacing.

```@example library-section
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Section {spacing=:md, background="bg-slate-50"} begin
    @Container begin
        @Heading {level=2} "Section Title"
        @Text "This section has consistent vertical spacing and a background color."
    end
end

Main.display_html(html) #hide
```

**Props:**
- `spacing::Symbol` - Vertical spacing (`:sm`, `:md`, `:lg`) - default: `:md`
- `background::String` - Background color class (optional)

### Typography Components

Components for displaying text with consistent styling.

#### Heading
Styled headings with multiple levels and sizes.

```@example library-heading
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @div begin
    @Heading {level=1} "Page Title"
    @Heading {level=2, size=:xl, weight=:bold} "Custom Heading"
    @Heading {level=3, color="text-blue-600"} "Colored Heading"
end

Main.display_html(html) #hide
```

**Props:**
- `level::Int` - Heading level (1-6) - default: `1`
- `size::Symbol` - Override size (`:xs`, `:sm`, `:base`, `:lg`, `:xl`, `"2xl"`, `"3xl"`, `"4xl"`, `"5xl"`) (optional)
- `weight::Symbol` - Font weight (`:normal`, `:medium`, `:semibold`, `:bold`) - default: `:semibold`
- `color::String` - Text color class (optional)

#### Text
Body text with various styles and alignments.

```@example library-text
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @div begin
    @Text {variant=:body} "Regular paragraph text"
    @Text {variant=:lead, align=:center} "Lead paragraph with center alignment"
    @Text {variant=:small, color="text-slate-500"} "Small helper text"
end

Main.display_html(html) #hide
```

**Props:**
- `variant::Symbol` - Text variant (`:body`, `:lead`, `:small`) - default: `:body`
- `size::Symbol` - Override size (optional)
- `weight::Symbol` - Font weight - default: `:normal`
- `color::String` - Text color class (optional)
- `align::Symbol` - Text alignment (`:left`, `:center`, `:right`, `:justify`) - default: `:left`

#### Link
Styled anchor elements with hover effects.

```@example library-link
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @div begin
    @Link {href="/about"} "About Us"
    @text " | "
    @Link {href="https://example.com", external=true} "External Link"
    @text " | "
    @Link {href="#", variant=:underline} "Underlined Link"
end

Main.display_html(html) #hide
```

**Props:**
- `href::String` - Link destination (required)
- `variant::Symbol` - Link variant (`:default`, `:underline`, `:hover_underline`) - default: `:default`
- `color::String` - Text color class (optional)
- `external::Bool` - Opens in new tab with security attributes - default: `false`

### Card Components

Components for displaying content in cards and badges.

#### Card
Content container with border and shadow.

```@example library-card
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Card {padding=:md, shadow=:sm, rounded=:lg} begin
    @Heading {level=3} "Card Title"
    @Text "Card content goes here"
end

Main.display_html(html) #hide
```

**Props:**
- `padding::Symbol` - Padding size (`:none`, `:sm`, `:md`, `:lg`) - default: `:md`
- `shadow::Symbol` - Shadow size (`:none`, `:sm`, `:md`, `:lg`) - default: `:sm`
- `border::Bool` - Show border - default: `true`
- `rounded::Symbol` - Border radius (`:none`, `:sm`, `:md`, `:lg`) - default: `:lg`

#### Badge
Small status indicators for labels and tags.

```@example library-badge
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @div begin
    @Badge {variant=:primary} "New"
    @text " "
    @Badge {variant=:success, size=:sm} "Active"
    @text " "
    @Badge {variant=:danger, size=:lg} "Critical"
end

Main.display_html(html) #hide
```

**Props:**
- `variant::Symbol` - Badge variant (`:default`, `:primary`, `:success`, `:warning`, `:danger`) - default: `:default`
- `size::Symbol` - Badge size (`:sm`, `:md`, `:lg`) - default: `:md`

### Table & List Components

Components for displaying structured data.

#### Table
Responsive data tables with optional styling.

```@example library-table
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Table {striped=true, hover=true} begin
    @thead begin
        @tr begin
            @th "Name"
            @th "Email"
            @th "Status"
        end
    end
    @tbody begin
        @tr begin
            @td "John Doe"
            @td "john@example.com"
            @td begin
                @Badge {variant=:success} "Active"
            end
        end
        @tr begin
            @td "Jane Smith"
            @td "jane@example.com"
            @td begin
                @Badge {variant=:warning} "Pending"
            end
        end
    end
end

Main.display_html(html) #hide
```

**Props:**
- `striped::Bool` - Striped rows - default: `false`
- `bordered::Bool` - Show borders - default: `true`
- `hover::Bool` - Hover effect on rows - default: `true`
- `compact::Bool` - Compact spacing - default: `false`

#### List
Styled lists with various markers.

```@example library-list
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @div begin
    @List {variant=:bullet} begin
        @li "First item"
        @li "Second item"
        @li "Third item"
    end
    
    @List {variant=:check, spacing=:loose} begin
        @li "Completed task"
        @li "Another completed task"
    end
end

Main.display_html(html) #hide
```

**Props:**
- `variant::Symbol` - List variant (`:bullet`, `:number`, `:check`, `:none`) - default: `:bullet`
- `spacing::Symbol` - Item spacing (`:tight`, `:normal`, `:loose`) - default: `:normal`

### Form Components

A comprehensive set of form controls with consistent styling.

#### Input
Text input fields with various states and options.

```@example library-input
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {gap=3} begin
    @Input {type="text", placeholder="Enter your name"}
    @Input {type="email", state=:error, placeholder="Email address"}
    @Input {type="password", icon="<svg class='h-4 w-4' fill='currentColor' viewBox='0 0 20 20'><path d='M10 2a5 5 0 00-5 5v2a2 2 0 00-2 2v5a2 2 0 002 2h10a2 2 0 002-2v-5a2 2 0 00-2-2H7V7a3 3 0 016 0v2a1 1 0 102 0V7a5 5 0 00-5-5z'/></svg>", placeholder="Password"}
end

Main.display_html(html) #hide
```

**Props:**
- `type::String` - Input type - default: `"text"`
- `size::Symbol` - Input size (`:sm`, `:md`, `:lg`) - default: `:md`
- `state::Symbol` - Input state (`:default`, `:error`, `:success`) - default: `:default`
- `icon::String` - Icon HTML to display (optional)
- `placeholder::String` - Placeholder text (optional)
- `name::String` - Input name attribute (optional)
- `value::String` - Input value (optional)
- `required::Bool` - Required field - default: `false`
- `disabled::Bool` - Disabled state - default: `false`

#### Textarea
Multi-line text input.

```@example library-textarea
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {gap=3} begin
    @Textarea {rows=4, placeholder="Enter your message..."}
    @Textarea {rows=6, resize=:none, state=:success, value="Message sent successfully!"}
end

Main.display_html(html) #hide
```

**Props:**
- `rows::Int` - Number of visible rows - default: `4`
- `resize::Symbol` - Resize behavior (`:none`, `:vertical`, `:horizontal`, `:both`) - default: `:vertical`
- `state::Symbol` - Input state - default: `:default`
- Plus all text input props (placeholder, name, value, etc.)

#### Select
Dropdown select element.

```@example library-select
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Select {
    options=[("us", "United States"), ("uk", "United Kingdom"), ("ca", "Canada")],
    placeholder="Choose a country",
    value="us"
}

Main.display_html(html) #hide
```

**Props:**
- `options::Vector{Tuple{String,String}}` - Options as (value, label) tuples
- `size::Symbol` - Select size - default: `:md`
- `state::Symbol` - Select state - default: `:default`
- Plus standard form props

#### Checkbox
Styled checkbox inputs.

```@example library-checkbox
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {gap=3} begin
    @Checkbox {label="I agree to the terms"}
    @Checkbox {label="Subscribe to newsletter", checked=true}
    @Checkbox {size=:lg, color=:success, label="Confirmed"}
end

Main.display_html(html) #hide
```

**Props:**
- `size::Symbol` - Checkbox size - default: `:md`
- `color::Symbol` - Checkbox color (`:slate`, `:primary`, `:success`) - default: `:primary`
- `label::String` - Label text (optional)
- `checked::Bool` - Checked state - default: `false`
- Plus standard form props

#### Radio
Radio button groups.

```@example library-radio
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Radio {
    name="plan",
    options=[("basic", "Basic Plan"), ("pro", "Pro Plan"), ("enterprise", "Enterprise")],
    value="pro"
}

Main.display_html(html) #hide
```

**Props:**
- `options::Vector{Tuple{String,String}}` - Options as (value, label) tuples
- `name::String` - Radio group name (required)
- `value::String` - Selected value (optional)
- `size::Symbol` - Radio size - default: `:md`
- `color::Symbol` - Radio color - default: `:primary`
- Plus standard form props

#### FormGroup
Form field wrapper with label and help text.

```@example library-formgroup
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {gap=4} begin
    @FormGroup {label="Email Address", help="We'll never share your email", required=true} begin
        @Input {type="email", placeholder="you@example.com"}
    end

    @FormGroup {label="Password", error="Password must be at least 8 characters"} begin
        @Input {type="password", state=:error}
    end
end

Main.display_html(html) #hide
```

**Props:**
- `label::String` - Field label (optional)
- `help::String` - Help text (optional)
- `error::String` - Error message (optional)
- `required::Bool` - Show required indicator - default: `false`

### Feedback Components

Components for user feedback and loading states.

#### Alert
Notification messages with various severity levels.

```@example library-alert
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {gap=3} begin
    @Alert {variant=:info} "This is an informational message"
    @Alert {variant=:success, dismissible=true} "Operation completed successfully!"
    @Alert {variant=:warning} begin
        @strong "Warning:"
        @text " Please review before proceeding"
    end
end

Main.display_html(html) #hide
```

**Props:**
- `variant::Symbol` - Alert variant (`:info`, `:success`, `:warning`, `:error`) - default: `:info`
- `dismissible::Bool` - Shows close button - default: `false`

#### Progress
Progress bars for loading and completion states.

```@example library-progress
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {gap=4} begin
    @Progress {value=75}
    @Progress {value=50, max=100, label="Upload Progress", striped=true}
    @Progress {value=30, color=:success, size=:lg}
end

Main.display_html(html) #hide
```

**Props:**
- `value::Int` - Current progress value - default: `0`
- `max::Int` - Maximum progress value - default: `100`
- `size::Symbol` - Progress bar size (`:sm`, `:md`, `:lg`) - default: `:md`
- `color::Symbol` - Progress bar color (`:slate`, `:primary`, `:success`) - default: `:primary`
- `striped::Bool` - Show striped pattern - default: `false`
- `label::String` - Label to display (optional)

#### Spinner
Loading spinner animations.

```@example library-spinner
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @div begin
    @Spinner {}
    @text " "
    @Spinner {size=:lg, color=:primary}
    @text " "
    @Spinner {size=:sm, color=:white}
end

Main.display_html(html) #hide
```

**Props:**
- `size::Symbol` - Spinner size (`:sm`, `:md`, `:lg`) - default: `:md`
- `color::Symbol` - Spinner color (`:slate`, `:primary`, `:white`) - default: `:primary`

### Navigation Components

Components for site navigation and wayfinding.

#### Breadcrumb
Navigation breadcrumbs for hierarchical pages.

```@example library-breadcrumb
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Breadcrumb {
    items=[
        ("/", "Home"),
        ("/products", "Products"),
        ("/products/electronics", "Electronics"),
        ("/products/electronics/phones", "Phones")
    ]
}

Main.display_html(html) #hide
```

**Props:**
- `items::Vector{Tuple{String,String}}` - Breadcrumb items as (href, label) tuples
- `separator::String` - Separator character - default: `"/"`

#### Pagination
Page navigation for multi-page content.

```@example library-pagination
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {gap=4} begin
    @Pagination {current=5, total=10}
    @Pagination {current=1, total=20, siblings=2, base_url="/posts/page/"}
end

Main.display_html(html) #hide
```

**Props:**
- `current::Int` - Current page number - default: `1`
- `total::Int` - Total number of pages - default: `1`
- `siblings::Int` - Number of sibling pages to show - default: `1`
- `base_url::String` - Base URL for page links - default: `"#"`

#### Tabs
Tab navigation (visual only, no JavaScript).

```@example library-tabs
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Tabs {
    items=[
        ("overview", "Overview"),
        ("features", "Features"),
        ("pricing", "Pricing"),
        ("support", "Support")
    ],
    active="features"
}

Main.display_html(html) #hide
```

**Props:**
- `items::Vector{Tuple{String,String}}` - Tab items as (id, label) tuples
- `active::String` - ID of the active tab - default: first item's ID

### Utility Components

Miscellaneous utility components.

#### Divider
Horizontal or vertical separators.

```@example library-divider
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @div begin
    @Text "Section 1"
    @Divider {}
    @Text "Section 2"
    @Divider {color="border-blue-500"}
    @Text "Section 3"
end

Main.display_html(html) #hide
```

**Props:**
- `orientation::Symbol` - Divider orientation (`:horizontal`, `:vertical`) - default: `:horizontal`
- `spacing::String` - Custom spacing class (optional)
- `color::String` - Border color class (optional)

#### Avatar
User profile images with fallbacks.

```@example library-avatar
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {direction=:horizontal, gap=3} begin
    @Avatar {src="/user.jpg", alt="John Doe"}
    @Avatar {size=:lg, fallback="JD"}
    @Avatar {shape=:square, fallback="👤"}
end

Main.display_html(html) #hide
```

**Props:**
- `src::String` - Image source URL (optional)
- `alt::String` - Alternative text - default: `"Avatar"`
- `size::Symbol` - Avatar size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) - default: `:md`
- `shape::Symbol` - Avatar shape (`:circle`, `:square`) - default: `:circle`
- `fallback::String` - Fallback content when no src provided (optional)

#### Icon
Icon wrapper for consistent sizing.

```@example library-icon
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Stack {direction=:horizontal, gap=3} begin
    @Icon {name="check"}
    @Icon {name="search", size=:lg, color="text-blue-600"}
    @Icon {size=:xl} begin
        # Custom SVG content
        HypertextTemplates.SafeString("<svg fill='currentColor' viewBox='0 0 20 20'><path d='M10 12a2 2 0 100-4 2 2 0 000 4z'/><path d='M10 4a8 8 0 100 16 8 8 0 000-16zm0 14a6 6 0 110-12 6 6 0 010 12z'/></svg>")
    end
end

Main.display_html(html) #hide
```

**Props:**
- `size::Symbol` - Icon size (`:xs`, `:sm`, `:md`, `:lg`, `:xl`) - default: `:md`
- `color::String` - Icon color class (optional)
- `name::String` - Built-in icon name (optional)

**Built-in icons:** `check`, `x`, `arrow-right`, `arrow-left`, `chevron-down`, `chevron-up`, `menu`, `search`, `plus`, `minus`

## Complete Example

Here's a complete example combining multiple library components:

```@example library-complete
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Section {spacing=:lg} begin
    @Container begin
        @Stack {gap=6} begin
            # Header
            @Card {padding=:lg, shadow=:md} begin
                @Stack {gap=4} begin
                    @Heading {level=1} "User Dashboard"
                    @Text {variant=:lead} "Manage your account settings and preferences"
                end
            end
            
            # Navigation
            @Breadcrumb {
                items=[
                    ("/", "Home"),
                    ("/account", "Account"),
                    ("/account/settings", "Settings")
                ]
            }
            
            # Content Grid
            @Grid {cols=1, md=2, gap=6} begin
                # Profile Section
                @Card begin
                    @Stack {gap=4} begin
                        @Heading {level=2} "Profile"
                        @Stack {direction=:horizontal, gap=4, align=:center} begin
                            @Avatar {src="/user.jpg", size=:lg}
                            @Stack {gap=1} begin
                                @Text {weight=:semibold} "John Doe"
                                @Badge {variant=:success} "Pro User"
                            end
                        end
                        @Divider {}
                        @FormGroup {label="Display Name"} begin
                            @Input {value="John Doe"}
                        end
                        @FormGroup {label="Email", help="Used for notifications"} begin
                            @Input {type="email", value="john@example.com"}
                        end
                    end
                end
                
                # Settings Section
                @Card begin
                    @Stack {gap=4} begin
                        @Heading {level=2} "Preferences"
                        @FormGroup {label="Theme"} begin
                            @Radio {
                                name="theme",
                                options=[
                                    ("light", "Light"),
                                    ("dark", "Dark"),
                                    ("system", "System")
                                ],
                                value="system"
                            }
                        end
                        @Divider {}
                        @Stack {gap=3} begin
                            @Checkbox {label="Email notifications", checked=true}
                            @Checkbox {label="Marketing emails"}
                            @Checkbox {label="Security alerts", checked=true}
                        end
                    end
                end
            end
            
            # Actions
            @Alert {variant=:info} begin
                @text "Changes are saved automatically"
            end
        end
    end
end

Main.display_html(html) #hide
```

## Styling Notes

All components are styled with Tailwind CSS v4 classes and include:
- Dark mode support by default
- Responsive design considerations
- Accessibility attributes where appropriate
- Consistent spacing and sizing scales
- Modern, clean aesthetic similar to shadcn/ui

To use these components effectively, ensure your project includes Tailwind CSS v4 with the default configuration.

## Custom Styling

While components come with sensible defaults, you can customize them using the `attrs...` parameter that all components accept:

```@example library-custom-styling
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

html = @render @Card {class="custom-class", id="my-card", "data-testid"="card-1"} begin
    @Text "This card has custom attributes"
end

Main.display_html(html) #hide
```

Additional classes will be merged with the default component classes, allowing you to extend or override styles as needed.