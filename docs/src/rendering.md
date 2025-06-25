# Rendering & Performance

This guide covers the rendering system in HypertextTemplates.jl, including performance optimization techniques and advanced rendering patterns.

## The `@render` Macro

The `@render` macro is the primary way to convert templates into output. It supports multiple output targets and streaming capabilities.

### Basic Rendering

```julia
# Render to String (default)
html = @render @div "Hello, World!"
# Returns: "<div>Hello, World!</div>"

# Render multiple elements
html = @render begin
    @h1 "Title"
    @p "Paragraph"
end
```

### Rendering to IO

Render directly to an IO stream for better performance:

```julia
# Render to IOBuffer
buffer = IOBuffer()
@render buffer @div begin
    @h1 "Large Document"
    for i in 1:1000
        @p "Paragraph $i"
    end
end
result = String(take!(buffer))

# Render to file
open("output.html", "w") do file
    @render file @html begin
        @head @title "My Page"
        @body @h1 "Content"
    end
end

# Render to stdout
@render stdout @div "Prints directly to console"
```

### Output Type Control

Specify the desired output type:

```julia
# Render to String (explicit)
str = @render String @div "Content"

# Render to Vector{UInt8}
bytes = @render Vector{UInt8} @div "Binary content"

# Custom types (if supported)
# The type must have an appropriate method defined
custom = @render MyCustomType @div "Content"
```

## Zero-Allocation Design

HypertextTemplates is designed to minimize memory allocations during rendering.

### Direct IO Streaming

Instead of building intermediate representations, content streams directly:

```julia
# This creates no intermediate strings or DOM objects
@render io @article begin
    @h1 $title
    for paragraph in paragraphs
        @p $paragraph
    end
end

# Equivalent to manual IO operations:
# write(io, "<article>")
# write(io, "<h1>")
# write(io, escaped_title)
# write(io, "</h1>")
# ...
```

### Precompiled Templates

Static parts of templates are optimized at compile time:

```julia
@component function static_heavy()
    # All static HTML is precompiled
    @div {class = "container"} begin
        @header {class = "header"} begin
            @nav begin
                @a {href = "/"} "Home"
                @a {href = "/about"} "About"
            end
        end
        @main {class = "content"} begin
            @__slot__  # Only dynamic part
        end
    end
end

# When rendered, only the slot content is processed at runtime
```

### Efficient String Handling

The rendering system uses efficient string operations:

```julia
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
```

## StreamingRender

For large documents or slow-loading content, use `StreamingRender` to send content as it becomes available.

### Basic Streaming

```julia
# Create a streaming render iterator
stream = StreamingRender() do io
    @render io @div begin
        @h1 "Instant content"
        
        # Simulate slow data loading
        sleep(1)
        data = load_data()
        
        @section begin
            for item in data
                @article process_item(item)
            end
        end
    end
end

# Consume the stream
for chunk in stream
    write(output, chunk)
    flush(output)  # Send immediately to client
end
```

### HTTP Streaming Example

With HTTP.jl:

```julia
using HTTP

function handle_request(req)
    HTTP.Response(200, ["Content-Type" => "text/html"]) do io
        for chunk in StreamingRender() do render_io
            @render render_io @html begin
                @head @title "Streaming Page"
                @body begin
                    @h1 "Live Data"
                    for i in 1:100
                        @p "Item $i"
                        # Simulate slow processing
                        sleep(0.01)
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

StreamingRender uses intelligent micro-batching for optimal performance:

```julia
# Internal behavior:
# - Large writes (≥64 bytes): Sent immediately
# - Small writes: Batched up to 256 bytes or 1ms timeout
# - Configurable via IOContext

# This results in efficient chunking
stream = StreamingRender() do io
    @render io @ul begin
        for i in 1:1000
            @li "Item $i"  # Small writes are batched
        end
    end
end
```

### Error Handling in Streams

Handle errors gracefully in streaming contexts:

```julia
stream = StreamingRender() do io
    try
        @render io @div begin
            @h1 "Results"
            risky_data = fetch_data()  # Might fail
            @section render_data(risky_data)
        end
    catch e
        @render io @div {class = "error"} begin
            @h2 "Error Loading Data"
            @p "Please try again later."
        end
    end
end
```

## Performance Optimization

### 1. Use IO Rendering

For best performance, always render to IO when possible:

```julia
# Good: Direct IO rendering
function render_page(io::IO, data)
    @render io @html begin
        @body render_content(data)
    end
end

# Less efficient: String concatenation
function render_page_string(data)
    html = @render @html begin
        @body render_content(data)
    end
    return html
end
```

### 2. Precompute Static Content

Move computations outside of render loops:

```julia
@component function optimized_table(; rows, columns)
    # Precompute column headers
    headers = [col.title for col in columns]
    col_count = length(columns)
    
    @table begin
        @thead @tr begin
            for header in headers
                @th $header
            end
        end
        @tbody begin
            for row in rows
                @tr begin
                    for i in 1:col_count
                        @td $row[i]
                    end
                end
            end
        end
    end
end
```

### 3. Avoid Repeated Allocations

Cache computed values:

```julia
# Cache formatter functions
const DATE_FORMATTER = dateformat"yyyy-mm-dd"

@component function date_list(; dates)
    @ul begin
        for date in dates
            # Reuse formatter instead of creating new one
            formatted = Dates.format(date, DATE_FORMATTER)
            @li $formatted
        end
    end
end
```

### 4. Stream Large Collections

For large datasets, use streaming:

```julia
@component function huge_list(; items)
    @div {class = "list-container"} begin
        # Process in chunks to allow streaming
        for chunk in Iterators.partition(items, 100)
            @section {class = "list-chunk"} begin
                for item in chunk
                    @div {class = "item"} render_item(item)
                end
            end
        end
    end
end
```

### 5. Conditional Rendering

Avoid rendering hidden content:

```julia
@component function conditional_section(; show_details = false, data)
    @article begin
        @h1 $data.title
        @p $data.summary
        
        # Don't render if not needed
        if show_details && !isempty(data.details)
            @section {class = "details"} begin
                for detail in data.details
                    @p $detail
                end
            end
        end
    end
end
```

## Benchmarking

### Measuring Performance

```julia
using BenchmarkTools

# Benchmark rendering performance
data = generate_test_data(1000)

# Measure String rendering
@benchmark @render @div render_items($data)

# Measure IO rendering
@benchmark begin
    io = IOBuffer()
    @render io @div render_items($data)
    take!(io)
end

# Measure streaming
@benchmark begin
    chunks = collect(StreamingRender() do io
        @render io @div render_items($data)
    end)
end
```

### Memory Profiling

```julia
using Profile

# Profile allocations
Profile.Allocs.@profile @render io @div begin
    for i in 1:10000
        @p "Item $i"
    end
end

# Analyze results
Profile.Allocs.print()
```

## Advanced Patterns

### Buffered Rendering

For complex layouts, use intermediate buffers:

```julia
@component function two_column_layout(; left_content, right_content)
    # Render columns in parallel (conceptually)
    left_buffer = IOBuffer()
    right_buffer = IOBuffer()
    
    @render left_buffer @div {class = "column-left"} left_content
    @render right_buffer @div {class = "column-right"} right_content
    
    # Combine results
    @div {class = "two-column"} begin
        @text SafeString(String(take!(left_buffer)))
        @text SafeString(String(take!(right_buffer)))
    end
end
```

### Lazy Rendering

Defer expensive computations:

```julia
@component function lazy_section(; data_loader)
    @div {class = "lazy-load"} begin
        # Only load data when actually rendering
        data = data_loader()
        
        if isnothing(data)
            @p "No data available"
        else
            render_data(data)
        end
    end
end

# Usage
@lazy_section {
    data_loader = () -> expensive_database_query()
}
```

### Progressive Enhancement

Render basic content first, enhance later:

```julia
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
```

### Render Caching

Cache rendered components:

```julia
const RENDER_CACHE = Dict{Any, String}()

@component function cached_expensive(; cache_key, compute_content)
    if haskey(RENDER_CACHE, cache_key)
        @text SafeString(RENDER_CACHE[cache_key])
    else
        buffer = IOBuffer()
        @render buffer compute_content()
        result = String(take!(buffer))
        RENDER_CACHE[cache_key] = result
        @text SafeString(result)
    end
end
```

## Best Practices

### 1. Choose the Right Output

- Use `IO` for server responses
- Use `String` for testing or caching
- Use `StreamingRender` for large/slow content

### 2. Minimize Dynamic Content

```julia
# Good: Static structure, dynamic content
@component function good_list(; items)
    @ul {class = "static-class"} begin
        for item in items
            @li $item  # Only content is dynamic
        end
    end
end

# Less optimal: Dynamic structure
@component function suboptimal_list(; items, compute_class)
    @ul {class = compute_class(items)} begin  # Computed every render
        for item in items
            @li {class = compute_item_class(item)} $item
        end
    end
end
```

### 3. Use Streaming for Real-time

```julia
@component function real_time_dashboard()
    StreamingRender() do io
        @render io @div {id = "dashboard"} begin
            while keep_running()
                data = fetch_latest_data()
                @render io @section {class = "update"} begin
                    @time {datetime = now()} $(Dates.now())
                    render_metrics(data)
                end
                sleep(1)  # Update every second
            end
        end
    end
end
```

### 4. Profile Before Optimizing

Always measure before optimizing:

```julia
# Simple timing
@time @render io large_template()

# Detailed benchmarking
@benchmark @render io template() samples=100

# Memory tracking
@allocated @render io template()
```

## Summary

HypertextTemplates.jl's rendering system provides:

- **Zero-allocation design** for maximum performance
- **Flexible output targets** (String, IO, custom types)
- **Streaming support** for large/async content  
- **Micro-batching** for optimal chunking
- **Direct IO operations** avoiding intermediate strings

The key to performance is understanding that templates compile to direct IO operations, making HypertextTemplates as fast as hand-written HTML generation code while maintaining the convenience of a DSL.