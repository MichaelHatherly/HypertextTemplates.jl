# Rendering & Performance

This guide covers the rendering system in HypertextTemplates.jl, including performance optimization techniques and advanced rendering patterns.

## The `@render` Macro

The `@render` macro is the primary way to convert templates into output. It supports multiple output targets and streaming capabilities.

### Basic Rendering

The `@render` macro converts your template expressions into HTML output. By default, it returns a String containing the rendered HTML. You can render single elements or multiple elements in a block, and the macro handles all the necessary HTML generation including proper escaping and tag structure.

```@example basic-rendering
using HypertextTemplates
using HypertextTemplates.Elements

# Render to String (default)
html = @render @div "Hello, World!"

Main.display_html(html) #hide
```

```@example basic-rendering
# Render multiple elements
html2 = @render begin
    @h1 "Title"
    @p "Paragraph"
end

Main.display_html(html2) #hide
```

### Rendering to IO

When building web applications or generating large documents, rendering directly to an IO stream avoids the memory overhead of creating intermediate strings. This approach is particularly beneficial for server responses where you can write directly to the network socket, or when generating files where you can stream directly to disk. The syntax is identical to string rendering - just pass an IO object as the first argument.

```@example iobuffer-render
using HypertextTemplates
using HypertextTemplates.Elements

# Render to IOBuffer
buffer = IOBuffer()
@render buffer @div begin
    @h1 "Small Document"
    for i in 1:3
        @p "Paragraph $i"
    end
end
result = String(take!(buffer))

Main.display_html(result) #hide
```

### Output Type Control

Specify the desired output type:

```@example output-types
using HypertextTemplates
using HypertextTemplates.Elements

# Render to String (explicit)
str = @render String @div "Content"
println(typeof(str), ": ", str)

# Render to Vector{UInt8}
bytes = @render Vector{UInt8} @div "Binary content"
println(typeof(bytes), ": ", String(bytes))
```

## Zero-Allocation Design

HypertextTemplates is designed to minimize memory allocations during rendering.

### Direct IO Streaming

Instead of building intermediate representations, content streams directly:

```@example direct-streaming
using HypertextTemplates
using HypertextTemplates.Elements

# This creates no intermediate strings or DOM objects
title = "My Article"
paragraphs = ["First paragraph.", "Second paragraph.", "Third paragraph."]

io = IOBuffer()
@render io @article begin
    @h1 $title
    for paragraph in paragraphs
        @p $paragraph
    end
end

result = String(take!(io))
Main.display_html(result) #hide

# This is equivalent to manual IO operations:
# write(io, "<article>")
# write(io, "<h1>")
# write(io, escaped_title)
# write(io, "</h1>")
# ...
```

### Precompiled Templates

HypertextTemplates performs compile-time optimization on your templates by identifying static HTML content and precompiling it. This means that any HTML structure that doesn't contain dynamic values (interpolations with `$`) is transformed into efficient string literals at compile time. When you render the template, only the dynamic parts need processing, while static HTML is emitted directly. This optimization happens automatically and can dramatically improve performance for templates with mostly static content.

```@example precompiled
using HypertextTemplates
using HypertextTemplates.Elements

@component function static_heavy()
    # All static HTML is precompiled
    @div {class = "container"} begin
        @header {class = "header"} begin
            @nav begin
                @a {href = "/"} "Home"
                @a {href = "/about"} "About"
            end
        end
        @article {class = "content"} begin
            @__slot__  # Only dynamic part
        end
    end
end

@deftag macro static_heavy end

# When rendered, only the slot content is processed at runtime
html = @render @static_heavy begin
    @p "This is the dynamic content that goes in the slot."
end

Main.display_html(html) #hide
```

### Efficient String Handling

The rendering system uses efficient string operations:

```@example efficient-strings
using HypertextTemplates
using HypertextTemplates.Elements

# Strings are written directly, not concatenated
@component function efficient_list(; items)
    @ul begin
        for item in items
            # Each write is a separate IO operation
            # No string concatenation happens
            @li $item
        end
    end
end

@deftag macro efficient_list end

items = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]
html = @render @efficient_list {items}
Main.display_html(html) #hide
```

## StreamingRender

For large documents or slow-loading content, use `StreamingRender` to send content as it becomes available.

### Basic Streaming

```@example streaming-basic
using HypertextTemplates
using HypertextTemplates.Elements

# Create a streaming render iterator
buffer = IOBuffer()
stream = StreamingRender() do io
    @render io @div begin
        @h1 "Streaming Example"

        # Render multiple sections
        for i in 1:3
            @section begin
                @h2 "Section $i"
                @p "This is paragraph $i"
            end
        end
    end
end

# Consume the stream
chunks = String[]
for chunk in stream
    push!(chunks, String(chunk))
end

println("Streamed $(length(chunks)) chunks:")
for (i, chunk) in enumerate(chunks)
    println("Chunk $i: ", repr(chunk))
end
```

### HTTP Streaming Example

With HTTP.jl:

```@example http-streaming
using HypertextTemplates
using HypertextTemplates.Elements

# Simulated streaming example (without actual HTTP.jl dependency)
function simulate_streaming_response()
    chunks = String[]

    for chunk in StreamingRender() do render_io
        @render render_io @html begin
            @head @title "Streaming Page"
            @body begin
                @h1 "Live Data"
                for i in 1:5  # Reduced for example
                    @p "Item $i"
                end
            end
        end
    end
        push!(chunks, String(chunk))
    end

    return chunks
end

# Show how the content would be streamed
chunks = simulate_streaming_response()
println("Streamed $(length(chunks)) chunks")
for (i, chunk) in enumerate(chunks[1:min(3, length(chunks))])
    println("\nChunk $i preview: ", first(chunk, 100), "...")
end
```

### Micro-batching

StreamingRender uses intelligent micro-batching for optimal performance:

```@example micro-batching
using HypertextTemplates
using HypertextTemplates.Elements

# Internal behavior:
# - Large writes (≥64 bytes): Sent immediately
# - Small writes: Batched up to 256 bytes or 1ms timeout
# - Configurable via keyword arguments to `StreamingRender`

# This results in efficient chunking
chunks = String[]
for chunk in StreamingRender() do io
    @render io @ul begin
        for i in 1:20  # Reduced for example
            @li "Item $i"  # Small writes are batched
        end
    end
end
    push!(chunks, String(chunk))
end

println("Total chunks: ", length(chunks))
if !isempty(chunks)
    println("First chunk size: ", length(chunks[1]), " bytes")
    println("First chunk preview: ", first(chunks[1], 100), "...")
end
```

### StreamingRender Configuration

Configure streaming behavior:

```@example streaming-config
using HypertextTemplates
using HypertextTemplates.Elements

# Example showing configuration (without actual large document)
@component function sample_document()
    @div begin
        @h1 "Document Title"
        for i in 1:10
            @section begin
                @h2 "Section $i"
                @p "Content for section $i"
            end
        end
    end
end

@deftag macro sample_document end

# Custom buffering settings
io_buffer = IOBuffer()
io = IOContext(
    io_buffer,
)

chunks = String[]
for chunk in StreamingRender(;
    buffer_size = 512,
    immediate_threshold = 128,
) do render_io
    @render IOContext(render_io, io) @sample_document
end
    push!(chunks, String(chunk))
end

println("Configured streaming produced ", length(chunks), " chunks")
```

## Advanced Patterns

### Buffered Rendering

For complex layouts, use intermediate buffers:

```@example buffered-rendering
using HypertextTemplates
using HypertextTemplates.Elements

@component function left_content()
    @nav begin
        @h3 "Navigation"
        @ul begin
            @li @a {href = "/"} "Home"
            @li @a {href = "/about"} "About"
            @li @a {href = "/contact"} "Contact"
        end
    end
end

@component function right_content()
    @article begin
        @h2 "Main Content"
        @p "This is the main content area."
        @p "It contains the primary information."
    end
end

@component function two_column_layout(; left_content, right_content)
    # Render columns in parallel (conceptually)
    left_buffer = IOBuffer()
    right_buffer = IOBuffer()

    @render left_buffer @div {class = "column-left"} left_content()
    @render right_buffer @div {class = "column-right"} right_content()

    # Combine results
    @div {class = "two-column"} begin
        @text SafeString(String(take!(left_buffer)))
        @text SafeString(String(take!(right_buffer)))
    end
end

@deftag macro two_column_layout end

# Example usage
html = @render @two_column_layout {left_content, right_content}

Main.display_html(html) #hide
```

### Lazy Rendering

Defer expensive computations:

```@example lazy-rendering
using HypertextTemplates
using HypertextTemplates.Elements

@component function render_data(; data)
    @div begin
        @h3 $(data.title)
        @ul begin
            for item in data.items
                @li $item
            end
        end
    end
end

@component function lazy_section(; data_loader)
    @div {class = "lazy-load"} begin
        # Only load data when actually rendering
        data = data_loader()

        if isnothing(data)
            @p "No data available"
        else
            render_data(; data)
        end
    end
end

@deftag macro lazy_section end

# Simulate expensive operations
function expensive_database_query()
    # In real code, this would be a database call
    return (title = "Query Results", items = ["Result 1", "Result 2", "Result 3"])
end

function empty_query()
    return nothing
end

# Example with data
html1 = @render @lazy_section {
    data_loader = () -> expensive_database_query()
}
Main.display_html(html1) #hide
```

```@example lazy-rendering
# Example without data
html2 = @render @lazy_section {
    data_loader = () -> empty_query()
}
Main.display_html(html2) #hide
```

### Progressive Enhancement

Render basic content first, enhance later:

```@example progressive-enhancement
using HypertextTemplates
using HypertextTemplates.Elements

@component function progressive_gallery(; images)
    @div {class = "gallery"} begin
        # Basic version (fast)
        for (i, img) in enumerate(images)
            @img {
                src = img.thumbnail,
                "data-full-src" := img.full_size,
                loading = "lazy",
                alt = img.alt
            }
        end

        # Enhancement script
        @script """
        // Progressively load full images
        document.querySelectorAll('[data-full-src]').forEach(img => {
            // Load full size when visible
        });
        """
    end
end

@deftag macro progressive_gallery end

# Example usage
images = [
    (thumbnail = "/thumb1.jpg", full_size = "/full1.jpg", alt = "Image 1"),
    (thumbnail = "/thumb2.jpg", full_size = "/full2.jpg", alt = "Image 2"),
    (thumbnail = "/thumb3.jpg", full_size = "/full3.jpg", alt = "Image 3")
]

html = @render @progressive_gallery {images}
Main.display_html(html) #hide
```

## Best Practices

### 1. Choose the Right Output

- Use `IO` for server responses
- Use `String` for testing or caching
- Use `StreamingRender` for large/slow content

### 2. Minimize Dynamic Content

```@example minimize-dynamic
using HypertextTemplates
using HypertextTemplates.Elements

# Good: Static structure, dynamic content
@component function good_list(; items)
    @ul {class = "static-class"} begin
        for item in items
            @li $item  # Only content is dynamic
        end
    end
end

@deftag macro good_list end

# Less optimal: Dynamic structure
function compute_class(items)
    length(items) > 5 ? "long-list" : "short-list"
end

function compute_item_class(item)
    startswith(item, "A") ? "a-item" : "other-item"
end

@component function suboptimal_list(; items)
    @ul {class = compute_class(items)} begin  # Computed every render
        for item in items
            @li {class = compute_item_class(item)} $item
        end
    end
end

@deftag macro suboptimal_list end

# Example usage
items = ["Apple", "Banana", "Cherry"]

@render @good_list {items}

Main.display_html(ans) #hide
```

```@example minimize-dynamic
@render @suboptimal_list {items}

Main.display_html(ans) #hide
```

## Summary

HypertextTemplates.jl's rendering system provides:

- **Zero-allocation design** for maximum performance
- **Flexible output targets** (String, IO, custom types)
- **Streaming support** for large/async content  
- **Micro-batching** for optimal chunking
- **Direct IO operations** avoiding intermediate strings

The key to performance is understanding that templates compile to direct IO operations, making HypertextTemplates as fast as hand-written HTML generation code while maintaining the convenience of a DSL.
