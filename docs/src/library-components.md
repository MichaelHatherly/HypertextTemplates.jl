# Library Components

The HypertextTemplates.Library module provides a comprehensive set of pre-built UI components styled with Tailwind CSS v4. These components follow modern design principles with a fresh, contemporary aesthetic and include dark mode support by default.

## Getting Started

```julia
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library
```

All component props and detailed API documentation can be found in the [API Reference](api.md).

## Interactive Components

Some components in the library include interactive features powered by Alpine.js. These components work without JavaScript but provide enhanced functionality when Alpine.js is available.

### Components with Alpine.js Integration

- **Alert** (`dismissible=true`) - Adds smooth dismiss animations with fade-out transitions
- **Tabs** - Interactive tab switching with content panels
- **Select** (coming soon) - Enhanced dropdown with search functionality
- **Table** (coming soon) - Client-side sorting when `sortable=true`

### Including Alpine.js

To enable interactive features, include Alpine.js in your page:

```julia
@script {defer=true, src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"}
```

### Progressive Enhancement

All interactive components follow progressive enhancement principles:
- Components render and display correctly without JavaScript
- Interactive features enhance the experience when Alpine.js is loaded
- No functionality is broken if JavaScript is disabled

## Live Examples

Explore complete, interactive examples organized by category:

- [Layout Components](examples/layout-components.html) - Container, Stack, Grid, and Section
- [Typography Components](examples/typography-components.html) - Headings, Text, and Links
- [Form Components](examples/form-components.html) - Complete form with all input types
- [Feedback Components](examples/feedback-components.html) - Alerts, Progress bars, Spinners, and Badges
- [Navigation Components](examples/navigation-components.html) - Breadcrumbs, Tabs, and Pagination
- [Table & List Components](examples/table-list-components.html) - Data tables and styled lists
- [Utility Components](examples/utility-components.html) - Dividers, Avatars, and Icons
- [Modern Styling](examples/modern-styling.html) - Showcase of new design features
- [Advanced Components](examples/advanced-components.html) - Complex component compositions
- [Dark Mode](examples/dark-mode.html) - Dark mode optimized examples
- [Complete Application](examples/complete-app.html) - Full dashboard example

## Modern Design System

### Design Philosophy

The component library embraces modern web design trends while maintaining usability and accessibility. Key principles include:

- **Subtle depth** through shadows and glassmorphism effects
- **Vibrant but balanced** color palette that works in both light and dark modes
- **Smooth interactions** with carefully tuned transitions
- **Consistent spacing** using a harmonious scale
- **Accessibility first** with proper ARIA attributes and focus states

### Visual Language

#### Color System
The library uses a carefully selected palette optimized for both light and dark modes:

- **Primary**: Blue tones for main actions and highlights
- **Secondary**: Purple for complementary elements
- **Success**: Emerald for positive feedback
- **Warning**: Amber for cautions
- **Danger**: Rose for errors and destructive actions

Each color adapts automatically in dark mode to maintain proper contrast ratios.

#### Spacing & Layout
Components use a consistent spacing scale (xs, sm, base, lg, xl) that creates visual rhythm and hierarchy. The system is based on Tailwind's spacing scale for familiarity and consistency.

#### Border Radius
Modern, softer corners are used throughout:
- `sm`: Subtle rounding for inline elements
- `base`: Standard rounding for inputs and small cards
- `lg`: Default for cards and containers
- `xl` & `2xl`: Emphasized rounding for special elements
- `full`: Perfect circles for avatars and icon buttons

### Modern Features

#### Glassmorphism
Create sophisticated layered interfaces with backdrop blur effects:

```julia
@Card {variant=:glass} begin
    # Content appears to float above the background
end
```

Glass effects work best over gradients or images and automatically adjust opacity for readability.

#### Gradients
Beautiful gradients are integrated throughout the component system:

- Text gradients for eye-catching headings
- Button gradients for premium actions
- Background gradients for cards and sections
- Progress bar gradients for visual interest

#### Animations
Subtle animations enhance user experience without being distracting:

- **Hover effects**: Scale transforms and shadow changes
- **Loading states**: Animated progress bars and spinners
- **Transitions**: Smooth 300ms transitions on all interactive elements
- **Pulse effects**: Attention-grabbing animations for badges and alerts

## Component Patterns

### Composition Over Configuration

Components are designed to work together naturally:

```julia
@Card begin
    @Stack {gap=4} begin
        @Heading {level=2} "Title"
        @Text "Description"
        @Button {variant=:primary} "Action"
    end
end
```

### Consistent Props

Common props work the same across all components:

- **Size**: `:xs`, `:sm`, `:base`, `:lg`, `:xl`
- **Variant**: Component-specific style variations
- **Color/State**: Semantic color system
- **Spacing**: Padding and gap values

### Attribute Spreading

All components accept additional attributes via `attrs...`:

```julia
@Button {
    variant=:primary,
    class="custom-class",
    "data-testid"="submit-button",
    id="main-cta"
} "Click Me"
```

## Dark Mode

Dark mode is built into every component with carefully tuned colors and contrasts. Components automatically adapt based on the `dark` class on a parent element.

Key considerations:
- **Adjusted colors** maintain readability
- **Reduced contrast** prevents eye strain
- **Inverted shadows** for proper depth perception
- **Special handling** for glassmorphism effects

## Accessibility

All library components include:

- Semantic HTML elements
- ARIA attributes where appropriate
- Keyboard navigation support
- Focus indicators with proper contrast
- Screen reader friendly content

## Tailwind CSS Integration

The library requires Tailwind CSS v4 with default configuration. Components use:

- Utility classes for all styling
- CSS variables for dynamic values
- Container queries for responsive behavior
- Modern CSS features like `backdrop-filter`

## Best Practices

### Performance
- Components render directly to IO without intermediate DOM
- Use `StreamingRender` for large component trees
- Leverage component composition to avoid deep nesting

### Maintainability
- Keep component trees shallow when possible
- Use semantic component names
- Extract repeated patterns into custom components
- Follow the library's naming conventions

### Styling
- Prefer component props over custom classes
- Use the design system's spacing scale
- Maintain consistency with the existing visual language
- Test in both light and dark modes

## Extending the Library

Create custom components that integrate seamlessly:

```julia
@component function CustomCard(; title, attrs...)
    @Card {variant=:gradient, attrs...} begin
        @Stack {gap=3} begin
            @Heading {level=3, gradient=true} title
            @__slot__()
        end
    end
end
@deftag macro CustomCard end
```

This approach ensures your components:
- Inherit the library's styling
- Support all standard features
- Maintain consistency with built-in components
