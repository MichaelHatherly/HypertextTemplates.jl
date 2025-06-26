# Markdown Integration

HypertextTemplates.jl provides seamless integration with CommonMark.jl, allowing you to create components from Markdown files and mix Markdown content with your templates.

## Prerequisites

To use Markdown features, you need CommonMark.jl in your project:

```julia
using Pkg
Pkg.add("CommonMark")
```

The integration is provided through Julia's package extension system, so features are automatically available when CommonMark.jl is loaded.

## Inline Markdown with CommonMark

### Basic Usage

Use CommonMark's `cm` string macro within templates:

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
@cm_component product_description(; name, price, features) = "templates/product.md"
@deftag macro product_description end

# product.md content:
# # $(name)
# 
# **Price:** $$(price)
# 
# ## Features
# $(join(features, "\n- ", "\n- "))

# Use the component
@render @product_description {
    name = "Premium Widget",
    price = 99.99,
    features = ["Durable", "Lightweight", "Eco-friendly"]
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

### Development Workflow

```julia
# Start Julia with Revise
# julia --project -e "using Revise; using MyApp"

# In MyApp
module MyApp
    using HypertextTemplates
    using CommonMark
    
    @cm_component docs(; page) = "docs/$(page).md"
    
    function serve_docs()
        # HTTP server that renders Markdown files
        # File changes are picked up automatically
    end
end
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

### Markdown Component Collections

Build collections of Markdown content:

```julia
# Directory structure:
# posts/
#   2024-01-01-hello.md
#   2024-01-15-update.md
#   2024-02-01-news.md

module BlogPosts
    using HypertextTemplates
    using Dates
    
    # Generate components for all posts
    for file in readdir("posts", join=true)
        if endswith(file, ".md")
            name = Symbol(replace(basename(file), ".md" => "", "-" => "_"))
            @eval @cm_component $name() = $file
        end
    end
    
    # Metadata extractor
    function post_meta(filename)
        date_str = match(r"(\d{4}-\d{2}-\d{2})", filename).captures[1]
        return (
            date = Date(date_str),
            slug = replace(filename, r"^\d{4}-\d{2}-\d{2}-" => "", ".md" => "")
        )
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

### Syntax Highlighting

Add syntax highlighting to code blocks:

```julia
using CommonMark
using Highlights

@component function highlighted_markdown(; file)
    content = read(file, String)
    
    # Parse Markdown
    parser = Parser()
    ast = parser(content)
    
    # Custom code block rendering
    for (node, entering) in ast
        if node isa CommonMark.CodeBlock && entering
            lang = node.info
            code = node.literal
            
            # Highlight code
            highlighted = Highlights.highlight(
                Highlights.Lexers.JuliaLexer,
                code,
                Highlights.Themes.DefaultTheme
            )
            
            # Replace node content
            node.literal = highlighted
        end
    end
    
    html_content = html(ast)
    @div {class = "markdown-highlighted"} $(SafeString(html_content))
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

### 3. Security Considerations

```julia
# Always validate file paths
@component function safe_markdown_loader(; doc_id)
    # Whitelist allowed document IDs
    allowed = ["intro", "guide", "api", "faq"]
    
    if doc_id in allowed
        file = "docs/$(doc_id).md"
        @cm_component doc() = file
        @doc
    else
        @p "Invalid document ID"
    end
end
```

### 4. Performance

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

### 5. Error Handling

Handle missing or invalid Markdown files:

```julia
@cm_component function safe_doc(; file = "default.md")
    if isfile(file)
        @text CommonMark.html(read(file, String))
    else
        @div {class = "error"} "Documentation not found: $file"
    end
end
```

## Summary

Markdown integration in HypertextTemplates.jl provides:

- **Inline Markdown** with the CommonMark.jl `cm` string macro
- **File-based components** with `@cm_component`
- **Full interpolation** support in Markdown content
- **Live reloading** with Revise.jl integration
- **Flexible patterns** for documentation and content sites

This integration makes it easy to build content-heavy sites while maintaining the full power of HypertextTemplates.jl's component system.