# Development Tools

HypertextTemplates.jl includes powerful development tools to improve your workflow, debugging experience, and code quality.

## Source Location Tracking

In development mode, HypertextTemplates automatically tracks where each HTML element was generated in your source code.

### How It Works

When enabled, elements include special `data-htloc` attributes:

```julia
# Enable development mode
io_dev = IOContext(stdout, :mode => :development)

@render io_dev @div {class = "container"} begin
    @h1 "Title"
    @p "Content"
end

# Output includes source locations:
# <div class="container" data-htloc="example.jl:5:12">
#   <h1 data-htloc="example.jl:6:5">Title</h1>
#   <p data-htloc="example.jl:7:5">Content</p>
# </div>
```

### Global Control

```julia
# Enable globally (default in development)
HypertextTemplates.SOURCE_TRACKING[] = true

# Disable globally (recommended for production)
HypertextTemplates.SOURCE_TRACKING[] = false
```

### Per-Render Control

```julia
# Development context - includes source tracking
dev_io = IOContext(io, :mode => :development)
@render dev_io @div "Debug mode"

# Production context - no source tracking
prod_io = IOContext(io, :mode => :production)
@render prod_io @div "Production mode"

# Or use the global setting
@render io @div "Uses global setting"
```

## Editor Integration

With the HTTP.jl extension, HypertextTemplates provides seamless editor integration.

### Quick Navigation

When viewing rendered HTML in your browser:

- **Ctrl+1** (or Cmd+1 on Mac): Jump to the `@render` call that created the fragment
- **Ctrl+2** (or Cmd+2 on Mac): Jump to the specific element macro that generated the HTML under cursor

### Setup with HTTP.jl

```julia
using HTTP
using HypertextTemplates

# The integration script is automatically injected in development mode
HTTP.serve() do request
    io = IOBuffer()
    
    # Render with development context
    ctx = IOContext(io, :mode => :development)
    @render ctx @html begin
        @head @title "Dev Server"
        @body begin
            @h1 "Click elements and press Ctrl+2"
            @p "Jump directly to source!"
        end
    end
    
    return HTTP.Response(200, String(take!(io)))
end
```

### How It Works

1. In development mode, a small JavaScript snippet is injected
2. The script listens for keyboard shortcuts
3. When triggered, it reads the `data-htloc` attribute
4. Sends a request to open the file in your editor

### Supported Editors

The HTTP extension attempts to open files using your system's default handler. For best results, configure your editor as the default handler for `.jl` files.

## Testing with ReferenceTests

HypertextTemplates works well with ReferenceTests.jl for comparing HTML output.

### Basic Test Setup

```julia
using Test
using ReferenceTests
using HypertextTemplates
using HypertextTemplates.Elements

@testset "Component Tests" begin
    # Test renders against reference files
    @test_reference "references/button.html" begin
        @render @button {class = "primary"} "Click me"
    end
    
    @test_reference "references/card.html" begin
        @render @card {title = "Test Card"} begin
            @p "Card content"
        end
    end
end
```

### Updating References

When you intentionally change output:

```bash
# Update all reference files
julia> using ReferenceTests
julia> ReferenceTests.update_reference_files("test/")

# Or set environment variable
JULIA_REFERENCETESTS_UPDATE=true julia test/runtests.jl
```

### Testing Components

```julia
# Test component with various inputs
@testset "UserCard component" begin
    @test_reference "references/usercard_basic.html" begin
        @render @user_card {name = "Alice", role = "Admin"}
    end
    
    @test_reference "references/usercard_guest.html" begin
        @render @user_card {name = "Guest", role = nothing}
    end
    
    # Test error conditions
    @test_throws ArgumentError @render @user_card {}  # Missing required props
end
```

## Debugging Techniques

### Macro Expansion

Understand what your templates compile to:

```julia
# See the generated code
@macroexpand @div {class = "test"} begin
    @p "Hello"
end

# For components
@macroexpand @component function test()
    @div "Test"
end

# Pretty print for readability
using MacroTools
MacroTools.prettify(@macroexpand @div "content")
```

### Tracing Rendering

Add debug output during rendering:

```julia
@component function debug_component(; data)
    # Add debug prints
    @debug "Rendering with data" data
    
    @div begin
        if length(data) > 10
            @warn "Large dataset" size=length(data)
        end
        
        for item in data
            @p $item
        end
    end
end

# Enable debug logging
ENV["JULIA_DEBUG"] = "Main"  # Or your module name
```

### Performance Profiling

Profile your templates:

```julia
using Profile
using PProf

# Profile rendering
@profile for i in 1:1000
    @render @complex_component {data = large_dataset}
end

# Visualize results
pprof()

# Or use simple timing
@time @render @large_page
@allocated @render @large_page

# Benchmark specific components
using BenchmarkTools
@benchmark @render @my_component {prop = $value}
```

### Memory Analysis

Track allocations:

```julia
using Profile

# Profile allocations
Profile.Allocs.@profile sample_rate=1 begin
    @render io @heavy_component
end

# Analyze results
Profile.Allocs.print(groupby = [:source])
```

## Development Workflow

### Live Reloading

Combine with Revise.jl for live development:

```julia
# In your REPL startup
using Revise
using HypertextTemplates

# Define components in a module
module MyApp
    using HypertextTemplates
    using HypertextTemplates.Elements
    
    @component function navbar()
        @nav begin
            @a {href = "/"} "Home"
            @a {href = "/about"} "About"
        end
    end
end

# Changes to navbar() are reflected immediately
```

### Development Server

Create a development server with auto-reload:

```julia
using HTTP
using HypertextTemplates
using Revise

function dev_server(; port = 8080)
    HTTP.serve(port = port) do request
        try
            # Route to component based on path
            path = request.target
            
            io = IOBuffer()
            ctx = IOContext(io, :mode => :development)
            
            if path == "/"
                @render ctx MyApp.home_page()
            elseif path == "/about"
                @render ctx MyApp.about_page()
            else
                @render ctx MyApp.not_found()
            end
            
            return HTTP.Response(200, String(take!(io)))
        catch e
            # Show errors in browser
            error_html = @render @html begin
                @body begin
                    @h1 "Error"
                    @pre $(sprint(showerror, e, catch_backtrace()))
                end
            end
            return HTTP.Response(500, error_html)
        end
    end
end
```

## Code Quality Tools

### Linting Components

Create custom lints for your templates:

```julia
# Check for accessibility
function lint_accessibility(expr)
    # Walk the AST looking for issues
    issues = String[]
    
    MacroTools.prewalk(expr) do node
        if @capture(node, @img {args___})
            # Check for alt attribute
            has_alt = any(args) do arg
                @capture(arg, alt = _)
            end
            if !has_alt
                push!(issues, "img missing alt attribute")
            end
        end
        node
    end
    
    return issues
end

# Use in tests
@testset "Accessibility" begin
    issues = lint_accessibility(quote
        @div begin
            @img {src = "photo.jpg"}  # Missing alt!
        end
    end)
    @test isempty(issues)
end
```

### Component Documentation

Document components with docstrings:

```julia
"""
    @button(; variant, size, disabled)

Render a styled button component.

# Arguments
- `variant::String = "primary"`: Button style variant
- `size::String = "md"`: Button size (sm, md, lg)
- `disabled::Bool = false`: Whether button is disabled

# Examples
```julia
@button {variant = "danger", size = "lg"} "Delete"
```
"""
@component function button(; variant = "primary", size = "md", disabled = false)
    # Implementation
end
```

## Debugging Patterns

### Component Inspection

```julia
@component function inspector(; component, props = (;))
    @div {class = "inspector", style = "border: 2px solid red; padding: 1rem;"} begin
        @details begin
            @summary "Component Inspector"
            @pre $(string(component))
            @pre $(string(props))
        end
        @div {style = "margin-top: 1rem;"} begin
            @<component {props...}
        end
    end
end

# Wrap any component for debugging
@render @inspector {component = my_component, props = (name = "test",)}
```

### Conditional Debugging

```julia
const DEBUG_MODE = Ref(false)

@component function debug_wrapper(; label = "Debug")
    @div begin
        if DEBUG_MODE[]
            @div {class = "debug-info", style = "background: yellow;"} begin
                @strong "$label: "
                @code $(string(@__FILE__)) ":" $(string(@__LINE__))
            end
        end
        @__slot__
    end
end

# Toggle debugging
DEBUG_MODE[] = true
```

### Error Boundaries

Catch and display errors gracefully:

```julia
@component function error_boundary(; children)
    try
        @<children
    catch e
        @div {class = "error-boundary"} begin
            @h2 "Something went wrong"
            @details begin
                @summary "Error details"
                @pre $(sprint(showerror, e))
            end
        end
    end
end
```

## Performance Monitoring

### Render Timing

```julia
@component function timed_section(; name)
    start_time = time()
    
    @div {"data-section" := name} begin
        @__slot__
    end
    
    elapsed = time() - start_time
    if elapsed > 0.1  # Log slow sections
        @warn "Slow section" name elapsed
    end
end
```

### Component Metrics

```julia
# Track component render counts
const RENDER_COUNTS = Dict{String, Int}()

@component function tracked_component(; name)
    RENDER_COUNTS[name] = get(RENDER_COUNTS, name, 0) + 1
    
    @div {"data-render-count" := RENDER_COUNTS[name]} begin
        @__slot__
    end
end

# View metrics
function print_metrics()
    for (name, count) in sort(collect(RENDER_COUNTS), by = last, rev = true)
        println("$name: $count renders")
    end
end
```

## Best Practices

1. **Use development mode during development** - Enable source tracking
2. **Disable source tracking in production** - Reduce output size
3. **Test with ReferenceTests** - Catch unintended changes
4. **Profile before optimizing** - Measure actual performance
5. **Document components** - Help your team understand usage
6. **Use debugging tools sparingly** - Remove before production
7. **Set up editor integration** - Faster development workflow

## Summary

HypertextTemplates.jl's development tools provide:

- **Source location tracking** for debugging
- **Editor integration** with jump-to-source
- **Testing utilities** with ReferenceTests.jl
- **Debugging helpers** for development
- **Performance profiling** capabilities
- **Live reloading** with Revise.jl

These tools combine to create a productive development environment for building web applications with HypertextTemplates.jl.