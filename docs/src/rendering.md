# Rendering & Performance

Where output goes, and what it costs to put it there.

## The `@render` Macro

`@render` turns a template into output. Where that output goes depends on the
destination it is given.

### Basic Rendering

With no destination `@render` returns a `String`. A block renders each element
in turn:

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

Pass an `IO` as the first argument and the render writes through to it, with no
string built along the way. That is what a server response or a file wants.

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

## What a Render Allocates

A render allocates a few hundred bytes for the context it carries, then nothing
per element. There is no DOM, nothing is concatenated, and escaping a value
builds no intermediate string. A three item list and a three thousand item one
cost the same. What grows with the page is the destination's own storage, the
buffer behind a `String` or a `Vector{UInt8}`; write to a socket or a file and
even that goes away.

### Direct IO Streaming

Given an `IO`, the render writes to it as it goes:

```@example direct-streaming
using HypertextTemplates
using HypertextTemplates.Elements

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

# The writes it makes are: "<article>", "<h1>", the escaped title,
# "</h1>", and so on to the closing tag.
```

### Static Structure Becomes Constants

A tag name and the run of literal attributes that follows it are known while
the macro expands, so they are merged into single string constants there.
Rendering writes those constants out; the work left at run time is the
interpolated values and the control flow around them.

```@example precompiled
using HypertextTemplates
using HypertextTemplates.Elements

@component function static_heavy()
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

html = @render @static_heavy begin
    @p "This is the dynamic content that goes in the slot."
end

Main.display_html(html) #hide
```

## StreamingRender

For large documents or slow-loading content, use `StreamingRender` to send content as it becomes available.

### Basic Streaming

```@example streaming-basic
using HypertextTemplates
using HypertextTemplates.Elements

# Create a streaming render iterator
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

### HTTP Streaming

Each chunk is a `Vector{UInt8}` ready to write to a response body. HTTP.jl is
not a dependency of this manual, so the example below is not executed here:

```julia
using HTTP
using HypertextTemplates, HypertextTemplates.Elements

function handle_request(req)
    return HTTP.Response(200, ["Content-Type" => "text/html"]) do io
        for chunk in StreamingRender() do render_io
            @render render_io @html begin
                @head @title "Streaming Page"
                @body begin
                    @h1 "Live Data"
                    for i in 1:1000
                        @p "Item $i"
                    end
                end
            end
        end
            write(io, chunk)
        end
    end
end
```

### Micro-batching

A render makes thousands of small writes. Handing each one to the consumer
separately would cost more than the render does, so they are batched. A write of
`immediate_threshold` bytes or more goes over as its own chunk. Smaller ones
accumulate until the batch fills, until 64 of them have arrived, or until a
timer fires a millisecond after the last flush. Chunk boundaries therefore
follow the batching and have nothing to do with where elements begin and end.

```@example micro-batching
using HypertextTemplates
using HypertextTemplates.Elements

chunks = String[]
for chunk in StreamingRender() do io
    @render io @ul begin
        for i in 1:20
            @li "Item $i"
        end
    end
end
    push!(chunks, String(chunk))
end

println("Total chunks: ", length(chunks))
println("First chunk: ", repr(first(chunks)))
```

### StreamingRender Configuration

Three keywords control the batching. `chunk_size` is how many bytes a batch may
reach before it is flushed, clamped to 256. `immediate_threshold` is the write
size that bypasses batching. `buffer_size` is how many chunks the channel holds
before the render task blocks, which is what applies backpressure when a
consumer reads more slowly than the render produces.

```@example streaming-config
using HypertextTemplates
using HypertextTemplates.Elements

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

chunks = String[]
for chunk in StreamingRender(;
    chunk_size = 128,
    immediate_threshold = 128,
    buffer_size = 8,
) do render_io
    @render render_io @sample_document
end
    push!(chunks, String(chunk))
end

println("Configured streaming produced ", length(chunks), " chunks")
```

### Stopping a Stream Early

Rendering runs in its own task, so a consumer that stops reading part way
through leaves that task blocked with nowhere to put the next chunk. `close`
releases it:

```@example streaming-close
using HypertextTemplates
using HypertextTemplates.Elements

stream = StreamingRender() do io
    @render io @ul begin
        for i in 1:10_000
            @li "Item $i"
        end
    end
end

first_chunk = nothing
for chunk in stream
    global first_chunk = String(chunk)
    break
end
close(stream)

println("Read ", length(first_chunk), " bytes, then closed the stream")
```

Reading a stream to the end closes it for you, so `close` is only needed when a
client disconnects or the consumer has seen enough.

## Advanced Patterns

### Buffered Rendering

A fragment can be rendered on its own and spliced in later, which is what
caching part of a page needs. The buffer holds markup this code produced, so it
goes back in as a `SafeString`:

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
    left_buffer = IOBuffer()
    right_buffer = IOBuffer()

    @render left_buffer @div {class = "column-left"} @<left_content
    @render right_buffer @div {class = "column-right"} @<right_content

    @div {class = "two-column"} begin
        @text SafeString(String(take!(left_buffer)))
        @text SafeString(String(take!(right_buffer)))
    end
end

@deftag macro two_column_layout end

html = @render @two_column_layout {left_content, right_content}

Main.display_html(html) #hide
```

### Loading Data During a Render

A component runs while the page renders. It can fetch what it needs at that
point, and the caller does not have to prepare everything up front:

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
        data = data_loader()

        if isnothing(data)
            @p "No data available"
        else
            @<render_data {data}
        end
    end
end

@deftag macro lazy_section end

# Stands in for a database call
function expensive_database_query()
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
        for img in images
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
