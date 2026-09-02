# Markdown Integration

HypertextTemplates.jl integrates with CommonMark.jl, so you can create components from Markdown files and mix Markdown content with your templates.

## Prerequisites

Everything on this page lives in a package extension, so it loads once
CommonMark.jl is in the environment:

```julia
using Pkg
Pkg.add("CommonMark")
```

## Inline Markdown with CommonMark

### Basic Usage

CommonMark.jl's `cm` string macro allows you to embed Markdown content directly within your HypertextTemplates components. The macro processes the Markdown at compile time and converts it to HTML, which is then wrapped in a `SafeString` to preserve the formatting. This approach combines the simplicity of Markdown for content authoring with the structure and interactivity of HypertextTemplates, making it a good fit for documentation sites, blogs, or any content-heavy application.

```@example markdown
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
        """
    end
end

@deftag macro article_with_markdown end

# The Markdown is converted to HTML and rendered
html = @render @article_with_markdown

Main.display_html(html) #hide
```

### Interpolation in Markdown

CommonMark.jl supports Julia interpolation:

```@example markdown
@component function dynamic_markdown(; user_name, item_count)
    @div {class = "content"} begin
        @text CommonMark.cm"""
        # Welcome, $(user_name)!

        You have **$(item_count)** items in your cart.

        $(item_count > 0 ? "Ready to checkout?" : "Start shopping!")
        """
    end
end

@deftag macro dynamic_markdown end

html = @render @dynamic_markdown {user_name = "Alice", item_count = 3}

Main.display_html(html) #hide
```

## Markdown File Components

The `@cm_component` macro creates components from Markdown files.

### Basic File Component

The `@cm_component` macro turns Markdown files into reusable HypertextTemplates components, so content can stay in Markdown format while still slotting into a component-based architecture. The macro reads the given Markdown file, processes it with CommonMark, and defines a component that behaves like any other HypertextTemplates component. That suits static content pages, documentation, or any case where non-technical contributors write the content.

A relative path is resolved against the directory of the file containing the `@cm_component` call, so a component defined in `src/pages.jl` and written as `"content/about.md"` reads `src/content/about.md`. The examples on this page are evaluated while the manual is built, where there is no such file, so they spell the directory out with `@__DIR__`.

The examples below use these two files:

```markdown
# About Us

We build tools for people who write HTML in Julia.

- Founded in 2020
- Based in Cape Town
```

```@example markdown
# Create a component from a Markdown file
@cm_component about_page() = joinpath(@__DIR__, "about.md")
@deftag macro about_page end

# Use it like any other component
html = @render @div {class = "page"} begin
    @about_page
end

Main.display_html(html) #hide
```

### Components with Props

Pass props to Markdown files for dynamic content. Given a `product.md` of:

```markdown
# $(name)

**Price:** $(price)
```

the props become ordinary keyword arguments on the component:

```@example markdown
@cm_component product_description(; name, price) = joinpath(@__DIR__, "product.md")
@deftag macro product_description end

html = @render @product_description {
    name = "Premium Widget",
    price = 99.99,
}

Main.display_html(html) #hide
```

### Organizing Markdown Components

Group related Markdown components in a module and export their tags:

```@example markdown
module MarkdownComponents
    using HypertextTemplates

    # Define all Markdown components
    @cm_component home() = joinpath(@__DIR__, "content", "home.md")
    @cm_component about() = joinpath(@__DIR__, "content", "about.md")
    @cm_component contact() = joinpath(@__DIR__, "content", "contact.md")

    # Export the tags if you want to use them without qualification
    @deftag macro home end
    @deftag macro about end
    @deftag macro contact end
    export @home, @about, @contact
end

# Use with module qualification
html = @render @MarkdownComponents.home

Main.display_html(html) #hide
```

```@example markdown
# Or if exported
using .MarkdownComponents

html = @render @div begin
    @about
    @contact
end

Main.display_html(html) #hide
```

## Live Reloading with Revise.jl

When Revise.jl is available, Markdown file components reload when the file changes. The snippet below is not executed by this manual, since it depends on you editing the file between renders:

```julia
using Revise
using HypertextTemplates
using CommonMark

# Define a Markdown component
@cm_component live_content() = "content/live.md"
@deftag macro live_content end

# Edit content/live.md in your editor
# Changes are reflected immediately when you re-render
@render @live_content
```

## Advanced Markdown Patterns

### Markdown Layout Components

Create layout components that accept Markdown content:

```@example markdown
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

@deftag macro markdown_layout end

# Use with Markdown components
@cm_component intro() = joinpath(@__DIR__, "intro.md")

html = @render @markdown_layout {title = "Introduction", markdown_file = intro}

Main.display_html(html) #hide
```

### Mixed Content

Combine Markdown with HTML components:

```@example markdown
# `@time` is ambiguous between `Elements` and `Base`, so name the one we mean.
using HypertextTemplates.Elements: @time

@component function blog_post(; meta, content_file)
    @article begin
        @header begin
            @h1 $(meta.title)
            @p {class = "meta"} begin
                @text "By "
                @strong $(meta.author)
                @text " on "
                @time $(meta.date)
            end
        end

        @div {class = "content prose"} begin
            @<content_file
        end

        @footer begin
            @nav begin
                if !isnothing(meta.prev)
                    @a {href = meta.prev.url} begin
                        @text "← "
                        @text meta.prev.title
                    end
                end
                if !isnothing(meta.next)
                    @a {href = meta.next.url} begin
                        @text meta.next.title
                        @text " →"
                    end
                end
            end
        end
    end
end

@deftag macro blog_post end

@cm_component post_body() = joinpath(@__DIR__, "post.md")

meta = (
    title = "Rendering Markdown",
    author = "Alice",
    date = "2024-05-01",
    prev = nothing,
    next = (url = "/posts/next", title = "Streaming responses"),
)

html = @render @blog_post {meta, content_file = post_body}

Main.display_html(html) #hide
```

### Dynamic Markdown Loading

Load Markdown content by path, validating the path first so a request cannot escape the content directory:

```@example markdown
function validate_doc_path(path)
    # Security: Ensure path is within docs directory
    cleaned = normpath(joinpath("docs", path))
    if startswith(cleaned, "docs/") && endswith(cleaned, ".md")
        return cleaned
    else
        return ""
    end
end

@component function dynamic_docs(; path)
    safe_path = validate_doc_path(path)

    if isfile(safe_path)
        # Read and render Markdown
        content = read(safe_path, String)
        html = CommonMark.html(CommonMark.Parser()(content))
        @div {class = "documentation"} $(SafeString(html))
    else
        @div {class = "error"} begin
            @h1 "404 - Page Not Found"
            @p "The requested documentation page does not exist."
        end
    end
end

@deftag macro dynamic_docs end

html = @render @div begin
    @dynamic_docs {path = "getting-started.md"}
    @dynamic_docs {path = "../../../etc/passwd"}
end

Main.display_html(html) #hide
```

## CommonMark Configuration

### Custom Rendering

Configure CommonMark parsing and rendering:

```@example markdown
using CommonMark

# Create custom parser with extensions
parser = CommonMark.Parser()
CommonMark.enable!(parser, CommonMark.DollarMathRule())
CommonMark.enable!(parser, CommonMark.TableRule())
CommonMark.enable!(parser, CommonMark.FootnoteRule())

@component function enhanced_markdown(; content)
    # Parse with custom settings, then render to HTML
    rendered = CommonMark.html(parser(content))

    @div {class = "enhanced-content"} $(SafeString(rendered))
end

@deftag macro enhanced_markdown end

html = @render @enhanced_markdown {
    content = """
    | Feature | Supported |
    |:--------|:----------|
    | Tables  | yes       |
    | Math    | ``x^2``   |
    """,
}

Main.display_html(html) #hide
```

## Caching Parsed Markdown

`@cm_component` parses its file while the macro expands, so a render pays
nothing for it, except under Revise where the file is re-read so that edits show
up. Markdown read at render time does pay on every render, and a cache keyed by
path keeps that to once per file:

```@example markdown
const MARKDOWN_CACHE = Dict{String, String}()

@component function cached_markdown(; file)
    rendered = get!(MARKDOWN_CACHE, file) do
        CommonMark.html(CommonMark.Parser()(read(file, String)))
    end

    @div {class = "cached-content"} $(SafeString(rendered))
end

@deftag macro cached_markdown end

html = @render @cached_markdown {file = "about.md"}

Main.display_html(html) #hide
```
