# Markdown Integration

HypertextTemplates.jl provides seamless integration with CommonMark.jl, allowing you to create components from Markdown files and mix Markdown content with your templates.

## Prerequisites

The Markdown integration features are provided through Julia's package extension system, which means they become available automatically when CommonMark.jl is present in your environment. This design keeps HypertextTemplates lightweight for users who don't need Markdown support while providing seamless integration for those who do. Simply adding CommonMark.jl to your project enables all the Markdown-related functionality described in this guide.

```julia
using Pkg
Pkg.add("CommonMark")
```

The integration is provided through Julia's package extension system, so features are automatically available when CommonMark.jl is loaded.

## Inline Markdown with CommonMark

### Basic Usage

CommonMark.jl's `cm` string macro allows you to embed Markdown content directly within your HypertextTemplates components. The macro processes the Markdown at compile time and converts it to HTML, which is then wrapped in a `SafeString` to preserve the formatting. This approach combines the simplicity of Markdown for content authoring with the power of HypertextTemplates for structure and interactivity, making it ideal for documentation sites, blogs, or any content-heavy application.

```julia
using HypertextTemplates
using HypertextTemplates.Elements
using CommonMark

@component function article_with_markdown()
    @article {class = "prose"} begin
        @text CommonMark.cm"""
        # Markdown Heading
        
        This is a paragraph with **bold** and *italic* text.
        
        - List item 1
        - List item 2
        
        > A blockquote
        
        ```julia
        # Code block
        println("Hello from Markdown!")
        ```
        """
    end
end

# The Markdown is converted to HTML and rendered
html = @render @article_with_markdown
```

### Interpolation in Markdown

CommonMark.jl supports Julia interpolation:

```julia
@component function dynamic_markdown(; user_name, item_count)
    @div {class = "content"} begin
        @text CommonMark.cm"""
        # Welcome, $(user_name)!
        
        You have **$(item_count)** items in your cart.
        
        $(item_count > 0 ? "Ready to checkout?" : "Start shopping!")
        """
    end
end

@render @dynamic_markdown {user_name = "Alice", item_count = 3}
```

## Markdown File Components

The `@cm_component` macro creates components from Markdown files.

### Basic File Component

The `@cm_component` macro transforms Markdown files into reusable HypertextTemplates components. This powerful feature allows you to maintain content in Markdown format while seamlessly integrating it into your component-based architecture. The macro reads the specified Markdown file, processes it with CommonMark, and creates a component that can be used just like any other HypertextTemplates component. This is particularly useful for static content pages, documentation, or any scenario where non-technical users need to contribute content.

```julia
# Create a component from a Markdown file
@cm_component about_page() = "content/about.md"
@deftag macro about_page end

# Use it like any other component
@render @div {class = "page"} begin
    @about_page
end
```

### Components with Props

Pass props to Markdown files for dynamic content:

```julia
# Define component with props
@cm_component product_description(; name, price) = "templates/product.md"
@deftag macro product_description end

# product.md content:
# # $(name)
#
# **Price:** $$(price)

# Use the component
@render @product_description {
    name = "Premium Widget",
    price = 99.99,
}
```

### Organizing Markdown Components

```julia
# Use relative paths from your module
@cm_component header() = joinpath(@__DIR__, "partials", "header.md")
@cm_component footer() = joinpath(@__DIR__, "partials", "footer.md")

# Or organize in a module
module MarkdownComponents
    using HypertextTemplates

    # Define all Markdown components
    @cm_component home() = "content/home.md"
    @cm_component about() = "content/about.md"
    @cm_component contact() = "content/contact.md"

    # Export tags if you want to use without qualification
    @deftag export macro home end
    @deftag export macro about end
    @deftag export macro contact end
end

# Use with module qualification
@render @MarkdownComponents.home

# Or if exported
using .MarkdownComponents
@render @home
```

## Live Reloading with Revise.jl

When Revise.jl is available, Markdown file components automatically reload when the file changes.

### Setup

```julia
using Revise
using HypertextTemplates
using CommonMark

# Define a Markdown component
@cm_component live_content() = "content/live.md"

# Edit content/live.md in your editor
# Changes are reflected immediately when you re-render
@render @live_content
```

## Advanced Markdown Patterns

### Markdown Layout Components

Create layout components that accept Markdown content:

```julia
@component function markdown_layout(; title, markdown_file)
    @html begin
        @head begin
            @title $title
            @style """
            .prose { max-width: 65ch; margin: 0 auto; }
            .prose h1 { color: #333; }
            .prose code { background: #f4f4f4; padding: 0.2em; }
            """
        end
        @body begin
            @div {class = "prose"} begin
                @<markdown_file
            end
        end
    end
end

# Use with Markdown components
@cm_component intro() = "intro.md"
@render @markdown_layout {title = "Introduction", markdown_file = intro}
```

### Mixed Content

Combine Markdown with HTML components:

```julia
@component function blog_post(; meta, content_file)
    @article begin
        @header begin
            @h1 $meta.title
            @p {class = "meta"} begin
                "By " @strong $meta.author " on " @time $meta.date
            end
        end

        @div {class = "content prose"} begin
            @<content_file  # Markdown component
        end

        @footer begin
            @nav begin
                if !isnothing(meta.prev)
                    @a {href = meta.prev.url} "← " $meta.prev.title
                end
                if !isnothing(meta.next)
                    @a {href = meta.next.url} $meta.next.title " →"
                end
            end
        end
    end
end
```

### Dynamic Markdown Loading

Load Markdown content dynamically:

```julia
@component function dynamic_docs(; path)
    # Validate path for security
    safe_path = validate_doc_path(path)

    if isfile(safe_path)
        # Read and render Markdown
        content = read(safe_path, String)
        html = CommonMark.html(content)
        @div {class = "documentation"} $(SafeString(html))
    else
        @div {class = "error"} begin
            @h1 "404 - Page Not Found"
            @p "The requested documentation page does not exist."
        end
    end
end

function validate_doc_path(path)
    # Security: Ensure path is within docs directory
    cleaned = normpath(joinpath("docs", path))
    if startswith(cleaned, "docs/") && endswith(cleaned, ".md")
        return cleaned
    else
        return ""
    end
end
```

## CommonMark Configuration

### Custom Rendering

Configure CommonMark parsing and rendering:

```julia
using CommonMark

# Create custom parser with extensions
parser = Parser()
enable!(parser, DollarMathRule())
enable!(parser, TableRule())
enable!(parser, FootnoteRule())

@component function enhanced_markdown(; content)
    # Parse with custom settings
    ast = parser(content)

    # Render to HTML
    html = html(ast)

    @div {class = "enhanced-content"} $(SafeString(html))
end
```

## Best Practices

### 1. File Organization

Structure your Markdown files logically:

```
project/
├── src/
│   └── components.jl
├── content/
│   ├── pages/
│   │   ├── home.md
│   │   └── about.md
│   ├── blog/
│   │   └── posts/
│   └── docs/
│       ├── getting-started.md
│       └── api-reference.md
```

### 2. Props Documentation

Document props in your Markdown files:

```markdown
<!-- product-template.md -->
<!-- Props: name (String), price (Float64), description (String) -->

# $(name)

**Price:** $$(price)

$(description)
```

### 3. Performance

Cache parsed Markdown for frequently accessed content:

```julia
const MARKDOWN_CACHE = Dict{String, String}()

@component function cached_markdown(; file)
    html = get!(MARKDOWN_CACHE, file) do
        content = read(file, String)
        CommonMark.html(content)
    end

    @div {class = "cached-content"} $(SafeString(html))
end
```

## Summary

Markdown integration in HypertextTemplates.jl provides:

- **Inline Markdown** with the CommonMark.jl `cm` string macro
- **File-based components** with `@cm_component`
- **Full interpolation** support in Markdown content
- **Live reloading** with Revise.jl integration

This integration makes it easy to build content-heavy sites while maintaining the full power of HypertextTemplates.jl's component system.
