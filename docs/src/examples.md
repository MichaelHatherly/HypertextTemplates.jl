# Examples & Patterns

This guide provides practical examples and patterns for building real-world applications with HypertextTemplates.jl.

## Building a Blog

A complete blog implementation showcasing components, layouts, and data handling.

### Blog Layout Component

```julia
@component function blog_layout(; title = "My Blog", current_page = "home")
    @html begin
        @head begin
            @meta {charset = "UTF-8"}
            @meta {name = "viewport", content = "width=device-width, initial-scale=1.0"}
            @title $title
            @link {rel = "stylesheet", href = "/css/blog.css"}
        end
        @body begin
            @header {class = "site-header"} begin
                @h1 {class = "site-title"} @a {href = "/"} "My Blog"
                @nav {class = "main-nav"} begin
                    @ul begin
                        @li @a {href = "/", class = current_page == "home" ? "active" : ""} "Home"
                        @li @a {href = "/archive", class = current_page == "archive" ? "active" : ""} "Archive"
                        @li @a {href = "/about", class = current_page == "about" ? "active" : ""} "About"
                    end
                end
            end
            
            @main {class = "content"} begin
                @__slot__
            end
            
            @footer {class = "site-footer"} begin
                @p "© 2024 My Blog. Built with HypertextTemplates.jl"
            end
        end
    end
end

@deftag macro blog_layout end
```

### Blog Post Component

```julia
struct BlogPost
    slug::String
    title::String
    date::Date
    author::String
    tags::Vector{String}
    content::String  # Markdown or HTML
end

@component function blog_post_card(; post::BlogPost, full = false)
    @article {class = "blog-post"} begin
        @header begin
            @h2 {class = "post-title"} begin
                if full
                    $post.title
                else
                    @a {href = "/post/$(post.slug)"} $post.title
                end
            end
            @div {class = "post-meta"} begin
                @span {class = "author"} "By " $post.author
                @time {datetime = post.date} $(Dates.format(post.date, "MMM d, yyyy"))
            end
        end
        
        @div {class = "post-content"} begin
            if full
                @text SafeString(post.content)  # Full content
            else
                # Extract excerpt (first paragraph)
                excerpt = first(split(post.content, "</p>"), 1) * "</p>"
                @text SafeString(excerpt)
                @a {href = "/post/$(post.slug)", class = "read-more"} "Read more →"
            end
        end
        
        @footer {class = "post-tags"} begin
            @ul {class = "tag-list"} begin
                for tag in post.tags
                    @li @a {href = "/tag/$tag", class = "tag"} "#" $tag
                end
            end
        end
    end
end

@deftag macro blog_post_card end
```

### Blog Home Page

```julia
@component function blog_home(; recent_posts, featured_post = nothing)
    @blog_layout {title = "Home - My Blog", current_page = "home"} begin
        if !isnothing(featured_post)
            @section {class = "featured"} begin
                @h2 "Featured Post"
                @blog_post_card {post = featured_post}
            end
        end
        
        @section {class = "recent-posts"} begin
            @h2 "Recent Posts"
            @div {class = "post-grid"} begin
                for post in recent_posts
                    @blog_post_card {post}
                end
            end
        end
    end
end
```

### Archive Page with Pagination

```julia
@component function blog_archive(; posts, current_page = 1, posts_per_page = 10)
    total_pages = ceil(Int, length(posts) / posts_per_page)
    start_idx = (current_page - 1) * posts_per_page + 1
    end_idx = min(start_idx + posts_per_page - 1, length(posts))
    page_posts = posts[start_idx:end_idx]
    
    @blog_layout {title = "Archive - My Blog", current_page = "archive"} begin
        @section {class = "archive"} begin
            @h2 "All Posts"
            
            @div {class = "post-list"} begin
                for post in page_posts
                    @blog_post_card {post}
                end
            end
            
            # Pagination
            if total_pages > 1
                @nav {class = "pagination"} begin
                    @ul begin
                        # Previous
                        if current_page > 1
                            @li @a {href = "/archive?page=$(current_page-1)"} "← Previous"
                        end
                        
                        # Page numbers
                        for page in 1:total_pages
                            @li begin
                                if page == current_page
                                    @span {class = "current"} $page
                                else
                                    @a {href = "/archive?page=$page"} $page
                                end
                            end
                        end
                        
                        # Next
                        if current_page < total_pages
                            @li @a {href = "/archive?page=$(current_page+1)"} "Next →"
                        end
                    end
                end
            end
        end
    end
end
```

## E-commerce Product Page

A product page demonstrating complex layouts and interactive elements.

### Product Gallery Component

```julia
@component function product_gallery(; images, product_name)
    @div {class = "product-gallery"} begin
        # Main image
        @div {class = "main-image"} begin
            @img {
                id = "main-product-image",
                src = first(images).large,
                alt = product_name,
                loading = "eager"
            }
        end
        
        # Thumbnails
        @div {class = "thumbnails"} begin
            for (idx, img) in enumerate(images)
                @button {
                    class = "thumbnail",
                    onclick = "document.getElementById('main-product-image').src = '$(img.large)'",
                    "aria-label" := "View image $idx"
                } begin
                    @img {
                        src = img.thumb,
                        alt = "$product_name - Image $idx",
                        loading = "lazy"
                    }
                end
            end
        end
    end
end
```

### Product Details Component

```julia
@component function product_details(; product)
    @div {class = "product-details"} begin
        @h1 {class = "product-title"} $product.name
        
        # Rating
        @div {class = "rating"} begin
            rating_stars = round(Int, product.rating)
            for i in 1:5
                if i <= rating_stars
                    @span {class = "star filled"} "★"
                else
                    @span {class = "star"} "☆"
                end
            end
            @span {class = "rating-count"} "($(product.review_count) reviews)"
        end
        
        # Price
        @div {class = "price-section"} begin
            if product.on_sale
                @span {class = "original-price"} "$" $(product.original_price)
                @span {class = "sale-price"} "$" $(product.sale_price)
                @span {class = "discount"} "-$(product.discount)%"
            else
                @span {class = "price"} "$" $(product.price)
            end
        end
        
        # Product options
        @form {id = "add-to-cart-form", "data-product-id" := product.id} begin
            # Size selector
            if !isempty(product.sizes)
                @div {class = "option-group"} begin
                    @label {for = "size"} "Size:"
                    @select {id = "size", name = "size", required = true} begin
                        @option {value = ""} "Select size"
                        for size in product.sizes
                            @option {value = size.code} $size.name
                        end
                    end
                end
            end
            
            # Quantity
            @div {class = "option-group"} begin
                @label {for = "quantity"} "Quantity:"
                @input {
                    type = "number",
                    id = "quantity",
                    name = "quantity",
                    min = 1,
                    max = product.stock,
                    value = 1
                }
            end
            
            # Add to cart button
            @button {
                type = "submit",
                class = "btn btn-primary add-to-cart",
                disabled = product.stock == 0
            } begin
                if product.stock == 0
                    "Out of Stock"
                else
                    "Add to Cart"
                end
            end
        end
        
        # Product description
        @div {class = "description"} begin
            @h2 "Description"
            @text SafeString(product.description_html)
        end
    end
end
```

### Complete Product Page

```julia
@component function product_page(; product, related_products)
    @html begin
        @head begin
            @title "$(product.name) - Shop"
            @meta {name = "description", content = product.short_description}
            # Structured data for SEO
            @script {type = "application/ld+json"} """
            {
                "@context": "https://schema.org/",
                "@type": "Product",
                "name": "$(product.name)",
                "description": "$(product.short_description)",
                "price": "$(product.price)",
                "priceCurrency": "USD"
            }
            """
        end
        @body begin
            @div {class = "product-page"} begin
                @div {class = "product-container"} begin
                    @product_gallery {
                        images = product.images,
                        product_name = product.name
                    }
                    @product_details {product}
                end
                
                # Related products
                @section {class = "related-products"} begin
                    @h2 "You May Also Like"
                    @div {class = "product-grid"} begin
                        for related in related_products[1:min(4, length(related_products))]
                            @product_card {product = related}
                        end
                    end
                end
            end
        end
    end
end

@deftag macro product_gallery end
@deftag macro product_details end
@deftag macro product_card end
@deftag macro product_page end
```

## Dashboard with Streaming Data

A real-time dashboard using StreamingRender.

### Dashboard Layout

```julia
@component function dashboard_layout(; user)
    @div {class = "dashboard"} begin
        @aside {class = "sidebar"} begin
            @div {class = "user-info"} begin
                @img {src = user.avatar, alt = user.name, class = "avatar"}
                @h3 $user.name
                @p {class = "role"} $user.role
            end
            
            @nav {class = "dashboard-nav"} begin
                @ul begin
                    @li @a {href = "#overview", class = "active"} "📊 Overview"
                    @li @a {href = "#analytics"} "📈 Analytics"
                    @li @a {href = "#reports"} "📄 Reports"
                    @li @a {href = "#settings"} "⚙️ Settings"
                end
            end
        end
        
        @main {class = "dashboard-content"} begin
            @__slot__
        end
    end
end
```

### Real-time Metrics Component

```julia
@component function realtime_metrics(; metrics_stream)
    @div {class = "metrics-grid"} begin
        @div {class = "metric-card"} begin
            @h3 "Active Users"
            @div {class = "metric-value", id = "active-users"} "--"
        end
        
        @div {class = "metric-card"} begin
            @h3 "Requests/sec"
            @div {class = "metric-value", id = "requests-per-sec"} "--"
        end
        
        @div {class = "metric-card"} begin
            @h3 "Response Time"
            @div {class = "metric-value", id = "response-time"} "--"
        end
        
        @div {class = "metric-card"} begin
            @h3 "Error Rate"
            @div {class = "metric-value", id = "error-rate"} "--"
        end
    end
    
    # JavaScript for updating metrics
    @script """
    const eventSource = new EventSource('$(metrics_stream)');
    eventSource.onmessage = function(event) {
        const data = JSON.parse(event.data);
        document.getElementById('active-users').textContent = data.activeUsers;
        document.getElementById('requests-per-sec').textContent = data.requestsPerSec;
        document.getElementById('response-time').textContent = data.responseTime + 'ms';
        document.getElementById('error-rate').textContent = data.errorRate + '%';
    };
    """
end
```

### Streaming Dashboard Data

```julia
function stream_dashboard_data(io)
    for chunk in StreamingRender() do render_io
        @render render_io @html begin
            @head begin
                @title "Real-time Dashboard"
                @style """
                .loading { animation: pulse 2s infinite; }
                @keyframes pulse { 0% { opacity: 0.5; } 50% { opacity: 1; } }
                """
            end
            @body begin
                @dashboard_layout {user = get_current_user()} begin
                    @h1 "Dashboard"
                    
                    # Initial loading state
                    @div {id = "metrics-container", class = "loading"} begin
                        @p "Loading metrics..."
                    end
                    
                    # Fetch and render data asynchronously
                    metrics = fetch_metrics()
                    
                    # Replace loading state with actual metrics
                    # Note: In real streaming, this would be sent as a separate chunk
                    @div {id = "metrics-actual"} begin
                        render_metrics_component(metrics)
                    end
                    
                    # Activity log that streams
                    @section {class = "activity-log"} begin
                        @h2 "Recent Activity"
                        @ul {id = "activity-list"} begin
                            for activity in get_recent_activities(10)
                                @li {class = "activity-item"} begin
                                    @time $(activity.timestamp)
                                    @span " - " $(activity.description)
                                end
                                
                                # Flush periodically for real-time feel
                                if rand() > 0.8
                                    flush(render_io)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
        write(io, chunk)
    end
end
```

## Form Handling Patterns

### Multi-step Form

```julia
@component function multi_step_form(; form_id = "wizard")
    @form {id = form_id, class = "multi-step-form"} begin
        # Progress indicator
        @div {class = "progress-bar"} begin
            @div {class = "progress", style = "width: 33%"}
        end
        
        # Step 1: Personal Info
        @fieldset {class = "form-step active", "data-step" := "1"} begin
            @legend "Personal Information"
            
            @div {class = "form-group"} begin
                @label {for = "name"} "Full Name"
                @input {
                    type = "text",
                    id = "name",
                    name = "name",
                    required = true
                }
            end
            
            @div {class = "form-group"} begin
                @label {for = "email"} "Email"
                @input {
                    type = "email",
                    id = "email",
                    name = "email",
                    required = true
                }
            end
            
            @button {type = "button", class = "btn-next"} "Next"
        end
        
        # Step 2: Address
        @fieldset {class = "form-step", "data-step" := "2"} begin
            @legend "Address"
            
            @div {class = "form-group"} begin
                @label {for = "street"} "Street Address"
                @input {
                    type = "text",
                    id = "street",
                    name = "street",
                    required = true
                }
            end
            
            @div {class = "form-row"} begin
                @div {class = "form-group"} begin
                    @label {for = "city"} "City"
                    @input {type = "text", id = "city", name = "city"}
                end
                
                @div {class = "form-group"} begin
                    @label {for = "zip"} "ZIP Code"
                    @input {type = "text", id = "zip", name = "zip"}
                end
            end
            
            @button {type = "button", class = "btn-prev"} "Previous"
            @button {type = "button", class = "btn-next"} "Next"
        end
        
        # Step 3: Confirmation
        @fieldset {class = "form-step", "data-step" := "3"} begin
            @legend "Confirmation"
            
            @div {class = "summary"} begin
                @h3 "Please review your information"
                @div {id = "form-summary"}
            end
            
            @button {type = "button", class = "btn-prev"} "Previous"
            @button {type = "submit", class = "btn-submit"} "Submit"
        end
    end
    
    # Form navigation script
    @script """
    // Multi-step form logic
    const form = document.getElementById('$(form_id)');
    const steps = form.querySelectorAll('.form-step');
    let currentStep = 0;
    
    // Navigation functions...
    """
end
```

## Alpine.js Integration

Using Alpine.js for client-side interactivity.

### Interactive Todo List

```julia
@component function alpine_todo()
    @div {"x-data" := """
        {
            todos: [],
            newTodo: '',
            addTodo() {
                if (this.newTodo.trim() !== '') {
                    this.todos.push({
                        id: Date.now(),
                        text: this.newTodo,
                        done: false
                    });
                    this.newTodo = '';
                }
            },
            removeTodo(id) {
                this.todos = this.todos.filter(t => t.id !== id);
            },
            toggleTodo(id) {
                const todo = this.todos.find(t => t.id === id);
                if (todo) todo.done = !todo.done;
            }
        }
    """} begin
        @h2 "Todo List"
        
        # Input form
        @form {"@submit.prevent" := "addTodo"} begin
            @input {
                type = "text",
                "x-model" := "newTodo",
                placeholder = "Add new todo...",
                class = "todo-input"
            }
            @button {type = "submit"} "Add"
        end
        
        # Todo list
        @ul {class = "todo-list"} begin
            @template {"x-for" := "todo in todos", ":key" := "todo.id"} begin
                @li {class = "todo-item"} begin
                    @input {
                        type = "checkbox",
                        ":checked" := "todo.done",
                        "@change" := "toggleTodo(todo.id)"
                    }
                    @span {
                        "x-text" := "todo.text",
                        ":class" := "{ 'done': todo.done }"
                    }
                    @button {
                        "@click" := "removeTodo(todo.id)",
                        class = "delete-btn"
                    } "×"
                end
            end
        end
        
        # Summary
        @p {class = "summary"} begin
            "Total: " @span {"x-text" := "todos.length"}
            " | Completed: " @span {"x-text" := "todos.filter(t => t.done).length"}
        end
    end
end
```

## HTMX Patterns

Server-driven interactivity with HTMX.

### Dynamic Search

```julia
@component function htmx_search()
    @div {class = "search-widget"} begin
        @input {
            type = "search",
            name = "q",
            placeholder = "Search...",
            "hx-get" := "/search",
            "hx-trigger" := "keyup changed delay:500ms",
            "hx-target" := "#search-results",
            "hx-indicator" := "#search-spinner"
        }
        
        @span {id = "search-spinner", class = "htmx-indicator"} "Searching..."
        
        @div {id = "search-results"} begin
            # Results will be loaded here
        end
    end
end

# Search results component
@component function search_results(; query, results)
    @div begin
        if isempty(results)
            @p "No results found for \"$query\""
        else
            @ul {class = "results-list"} begin
                for result in results
                    @li begin
                        @a {href = result.url} begin
                            @strong $result.title
                            @p {class = "excerpt"} $result.excerpt
                        end
                    end
                end
            end
        end
    end
end
```

### Infinite Scroll

```julia
@component function infinite_scroll_list(; items, page = 1, has_more = true)
    @div {class = "infinite-list"} begin
        @ul begin
            for item in items
                @li {class = "list-item"} $item.title
            end
        end
        
        if has_more
            @div {
                "hx-get" := "/items?page=$(page + 1)",
                "hx-trigger" := "revealed",
                "hx-swap" := "afterend",
                class = "load-more"
            } "Loading more..."
        end
    end
end
```

## Best Practices Summary

1. **Component Organization** - Group related components in modules
2. **Prop Validation** - Use Julia's type system for safety
3. **Performance** - Use streaming for large datasets
4. **Accessibility** - Include ARIA attributes and semantic HTML
5. **Security** - Always validate user input, trust auto-escaping
6. **Maintainability** - Create reusable, composable components
7. **Testing** - Use ReferenceTests for component output

These examples demonstrate the flexibility and power of HypertextTemplates.jl for building modern web applications.