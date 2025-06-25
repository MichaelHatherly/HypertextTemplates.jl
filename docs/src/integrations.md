# Integrations

HypertextTemplates.jl integrates with several Julia packages through the package extension system. This guide covers how to use these integrations and build your own.

## HTTP.jl Integration

The HTTP.jl integration provides seamless web server functionality and development tools.

### Basic Server Setup

```julia
using HTTP
using HypertextTemplates
using HypertextTemplates.Elements

# Simple HTTP server
HTTP.serve() do request
    # Route handling
    response = if request.target == "/"
        @render @html begin
            @head @title "Home"
            @body begin
                @h1 "Welcome!"
                @p "This is rendered with HypertextTemplates.jl"
            end
        end
    elseif request.target == "/about"
        @render @html begin
            @head @title "About"
            @body @h1 "About Us"
        end
    else
        @render @html begin
            @head @title "404"
            @body @h1 "Page Not Found"
        end
    end
    
    return HTTP.Response(200, ["Content-Type" => "text/html"], response)
end
```

### Streaming Responses

Use `StreamingRender` for large responses:

```julia
function handle_large_data(request)
    HTTP.Response(200, ["Content-Type" => "text/html"]) do io
        for chunk in StreamingRender() do render_io
            @render render_io @html begin
                @body begin
                    @h1 "Large Dataset"
                    @table begin
                        @thead @tr begin
                            @th "ID" @th "Name" @th "Value"
                        end
                        @tbody for row in fetch_large_dataset()
                            @tr begin
                                @td $(row.id)
                                @td $(row.name)
                                @td $(row.value)
                            end
                        end
                    end
                end
            end
        end
            write(io, chunk)
        end
    end
end

HTTP.serve(handle_large_data, "0.0.0.0", 8080)
```

### Development Mode Features

The HTTP integration automatically includes development tools:

```julia
# Development server with source tracking
function dev_server(; port = 8080)
    HTTP.serve(port = port) do request
        io = IOBuffer()
        
        # Enable development mode for source tracking
        ctx = IOContext(io, :mode => :development)
        
        @render ctx @html begin
            @head @title "Dev Mode"
            @body begin
                @h1 "Development Server"
                @p "Press Ctrl+2 on any element to jump to source!"
            end
        end
        
        return HTTP.Response(200, String(take!(io)))
    end
end
```

### Middleware Integration

Create middleware for templates:

```julia
# Template middleware
function template_middleware(handler)
    return function(request)
        # Pre-processing
        start_time = time()
        
        # Call handler
        response = handler(request)
        
        # Post-processing - add render time header
        if response.status == 200
            push!(response.headers, "X-Render-Time" => string(time() - start_time))
        end
        
        return response
    end
end

# Use with HTTP.serve
HTTP.serve(template_middleware(my_handler), "0.0.0.0", 8080)
```

## Bonito.jl Integration

Bonito.jl integration enables interactive web applications with client-server communication.

### Basic Bonito App

```julia
using Bonito
using HypertextTemplates
using HypertextTemplates.Elements

# Create an interactive component
@component function counter_app()
    count = Observable(0)
    
    @div begin
        @h1 "Counter: " $(count)
        @button {
            onclick = js"() => { $(count)[] = $(count)[] + 1 }"
        } "Increment"
        @button {
            onclick = js"() => { $(count)[] = 0 }"
        } "Reset"
    end
end

# Serve the app
App() do session
    return @render @counter_app
end
```

### Reactive Components

Build reactive UIs with Observables:

```julia
@component function todo_app()
    todos = Observable(String[])
    new_todo = Observable("")
    
    @div {class = "todo-app"} begin
        @h1 "Todo List"
        
        @input {
            type = "text",
            value = new_todo,
            placeholder = "Add a todo...",
            onchange = js"(e) => { $(new_todo)[] = e.target.value }"
        }
        
        @button {
            onclick = js"""() => {
                if ($(new_todo)[].trim() !== '') {
                    $(todos)[] = [...$(todos)[], $(new_todo)[]]
                    $(new_todo)[] = ''
                }
            }"""
        } "Add"
        
        @ul begin
            map(enumerate(todos[])) do (i, todo)
                @li begin
                    $todo
                    @button {
                        onclick = js"""() => {
                            $(todos)[] = $(todos)[].filter((_, idx) => idx !== $(i-1))
                        }"""
                    } "Delete"
                end
            end
        end
    end
end
```

### Bonito + HypertextTemplates Patterns

```julia
# Combine static and dynamic content
@component function dashboard()
    # Static header
    @header begin
        @h1 "Analytics Dashboard"
        @nav begin
            @a {href = "#overview"} "Overview"
            @a {href = "#details"} "Details"
        end
    end
    
    # Dynamic content with Bonito
    data = Observable(fetch_initial_data())
    
    @main begin
        # Reactive chart component
        @div {id = "chart"} begin
            BonitoChart(data)  # Custom Bonito component
        end
        
        # Static + reactive mix
        @section begin
            @h2 "Summary"
            @p "Total items: " $(map(d -> length(d), data))
        end
    end
end
```

## Revise.jl Integration

Revise.jl integration provides live code reloading for rapid development.

### Automatic Reloading

```julia
using Revise
using HypertextTemplates

# Define components in a module
module MyComponents
    using HypertextTemplates
    using HypertextTemplates.Elements
    
    @component function header()
        @header {class = "site-header"} begin
            @h1 "My Site"
            # Edit this and see changes immediately!
        end
    end
    
    @cm_component content() = "content.md"  # Markdown files auto-reload too
end

# Changes to MyComponents are automatically reflected
```

### Development Workflow

```julia
# Start Julia with Revise
# julia --project -e "using Revise; include(\"server.jl\")"

# server.jl
using HTTP
using HypertextTemplates
includet("components.jl")  # Use includet for tracking

function serve_dev()
    HTTP.serve() do request
        # Components are always up-to-date
        html = @render MyComponents.page()
        HTTP.Response(200, html)
    end
end

serve_dev()
```

## CommonMark.jl Integration

Covered in detail in the [Markdown Integration](markdown-integration.md) guide.

## Building Custom Integrations

### Using Package Extensions

Create your own package extensions:

```julia
# In your package's Project.toml
[weakdeps]
MyPackage = "uuid-here"

[extensions]
MyPackageExt = "MyPackage"

# ext/MyPackageExt.jl
module MyPackageExt

using HypertextTemplates
using MyPackage

# Add new functionality when both packages are loaded
HypertextTemplates.@component function my_special_component()
    # Use features from both packages
end

end
```

### Integration Patterns

#### 1. Wrapper Components

Wrap external packages in components:

```julia
using Plots
using HypertextTemplates

@component function plot_component(; data, title = "")
    # Generate plot
    p = plot(data, title = title)
    
    # Save to temporary file
    tmp = tempname() * ".png"
    savefig(p, tmp)
    
    # Encode as base64
    img_data = base64encode(read(tmp))
    rm(tmp)
    
    # Render as img
    @img {
        src = "data:image/png;base64,$img_data",
        alt = title
    }
end
```

#### 2. Render Methods

Add render methods for custom types:

```julia
import HypertextTemplates: render

# Define how to render your custom type
function render(io::IO, ::Type{MyCustomType}, obj::MyCustomType)
    @render io @div {class = "my-custom-type"} begin
        @h3 $(obj.title)
        @p $(obj.description)
    end
end

# Now can use directly in templates
obj = MyCustomType("Title", "Description")
@render @div begin
    @h1 "Page"
    $(obj)  # Automatically rendered
end
```

#### 3. Macro Extensions

Create domain-specific macros:

```julia
# Create a chart DSL
macro chart(type, data)
    quote
        @div {class = "chart-container"} begin
            @canvas {
                id = "chart-" * string(gensym()),
                "data-type" := $(string(type)),
                "data-values" := JSON.json($data)
            }
            @script """
            // Initialize chart with data
            """
        end
    end
end

# Usage
@render @chart bar [1, 2, 3, 4, 5]
```

## Framework Integration Examples

### With Genie.jl

```julia
using Genie, Genie.Router, Genie.Renderer
using HypertextTemplates
using HypertextTemplates.Elements

# Define route with HypertextTemplates
route("/") do
    @render @html begin
        @head @title "Genie + HypertextTemplates"
        @body begin
            @h1 "Welcome to Genie!"
            @p "Rendered with HypertextTemplates"
        end
    end
end

# Start server
up()
```

### With Oxygen.jl

```julia
using Oxygen
using HypertextTemplates
using HypertextTemplates.Elements

# Define routes
@get "/" function()
    @render @html begin
        @head @title "Oxygen App"
        @body @h1 "Hello from Oxygen + HypertextTemplates!"
    end
end

@get "/users/{id}" function(req)
    user_id = req.params.id
    @render @html begin
        @body begin
            @h1 "User Profile"
            @p "User ID: $user_id"
        end
    end
end

# Start server
serve()
```

### With Pluto.jl

```julia
### A Pluto.jl notebook ###
using HypertextTemplates
using HypertextTemplates.Elements

# Define component
@component function pluto_widget(; data)
    @div {class = "widget"} begin
        @h3 "Data Visualization"
        @ul for (key, value) in data
            @li @strong $key ": " $value
        end
    end
end

# Render in Pluto cell
HTML(@render @pluto_widget {data = Dict("a" => 1, "b" => 2)})
```

## Database Integration

### With SQLite.jl

```julia
using SQLite
using HypertextTemplates
using HypertextTemplates.Elements

# Query and render
function render_users(db)
    users = DBInterface.execute(db, "SELECT * FROM users") |> DataFrame
    
    @render @table {class = "users-table"} begin
        @thead @tr begin
            @th "ID" @th "Name" @th "Email"
        end
        @tbody for row in eachrow(users)
            @tr begin
                @td $(row.id)
                @td $(row.name)
                @td $(row.email)
            end
        end
    end
end
```

## Best Practices

1. **Use package extensions** for optional dependencies
2. **Keep integrations lightweight** - don't force dependencies
3. **Document integration requirements** clearly
4. **Provide examples** for common use cases
5. **Test with and without** weak dependencies
6. **Follow each package's conventions** while using HypertextTemplates

## Summary

HypertextTemplates.jl's integration ecosystem provides:

- **HTTP.jl** for web servers with development tools
- **Bonito.jl** for interactive applications
- **Revise.jl** for live code reloading
- **CommonMark.jl** for Markdown support
- **Extensible architecture** for custom integrations

The package extension system ensures these integrations are optional and don't bloat your dependencies, while providing powerful features when needed.