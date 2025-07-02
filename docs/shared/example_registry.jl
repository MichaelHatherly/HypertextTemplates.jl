# Example Registry
# Central registry of all component examples

struct ExampleEntry
    filename::String
    title::String
    component_name::String
    output_file::String
    description::String
end

# Define all examples with their metadata
const EXAMPLE_REGISTRY = [
    ExampleEntry(
        "layout.jl",
        "Layout Components - HypertextTemplates",
        "LayoutExample",
        "layout-components.html",
        "Container, Stack, and Grid components",
    ),
    ExampleEntry(
        "typography.jl",
        "Typography Components - HypertextTemplates",
        "TypographyExample",
        "typography-components.html",
        "Heading, Text, and Link components",
    ),
    ExampleEntry(
        "forms.jl",
        "Form Components - HypertextTemplates",
        "FormExample",
        "form-components.html",
        "Input, Select, Textarea, and form controls",
    ),
    ExampleEntry(
        "feedback.jl",
        "Feedback Components - HypertextTemplates",
        "FeedbackExample",
        "feedback-components.html",
        "Alert, Progress, Spinner, and Badge components",
    ),
    ExampleEntry(
        "navigation.jl",
        "Navigation Components - HypertextTemplates",
        "NavigationExample",
        "navigation-components.html",
        "Breadcrumb, Tabs, and Pagination components",
    ),
    ExampleEntry(
        "tables_lists.jl",
        "Table & List Components - HypertextTemplates",
        "TableListExample",
        "table-list-components.html",
        "Table and List components",
    ),
    ExampleEntry(
        "utility.jl",
        "Utility Components - HypertextTemplates",
        "UtilityExample",
        "utility-components.html",
        "Divider, Avatar, and Icon components",
    ),
    ExampleEntry(
        "icon_gallery.jl",
        "Icon Gallery - HypertextTemplates",
        "IconGalleryExample",
        "icon-gallery.html",
        "Complete collection of available icons",
    ),
    ExampleEntry(
        "modern_styling.jl",
        "Modern Styling Features - HypertextTemplates",
        "ModernStylingExample",
        "modern-styling.html",
        "Glass morphism, gradients, and modern effects",
    ),
    ExampleEntry(
        "advanced_components.jl",
        "Advanced Components - HypertextTemplates",
        "AdvancedComponentsExample",
        "advanced-components.html",
        "Complex component patterns and compositions",
    ),
    ExampleEntry(
        "dark_mode.jl",
        "Dark Mode Examples - HypertextTemplates",
        "DarkModeExample",
        "dark-mode.html",
        "Dark mode showcase and theming",
    ),
    ExampleEntry(
        "dropdown_menu.jl",
        "Dropdown Menu Components - HypertextTemplates",
        "DropdownMenuExample",
        "dropdown-menu.html",
        "Dropdown menus with submenus",
    ),
    ExampleEntry(
        "complete_app.jl",
        "Complete Application - HypertextTemplates",
        "AppExample",
        "complete-app.html",
        "Full dashboard application example",
    ),
]
