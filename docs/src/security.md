# Security

HypertextTemplates.jl includes built-in security features to protect against common web vulnerabilities. This guide covers the automatic escaping system and best practices for secure template development.

## Automatic HTML Escaping

The most important security feature is automatic HTML escaping of dynamic content, which prevents Cross-Site Scripting (XSS) attacks.

### Default Escaping Behavior

HypertextTemplates automatically escapes all dynamic content (variables, expressions, and interpolations) to prevent malicious code injection. This means that any HTML special characters like `<`, `>`, `&`, and quotes are converted to their safe HTML entity equivalents. This protection is applied transparently without any action required from developers, ensuring that user-provided data cannot execute as HTML or JavaScript code, effectively preventing XSS attacks by default.

```@example default-escaping
using HypertextTemplates
using HypertextTemplates.Elements

# User input is automatically escaped
user_input = "<script>alert('XSS')</script>"
html = @render @p "User said: " $user_input

println(html)
# The script tag is rendered as visible text, not executed
```

### Escaping in Attributes

Attribute values from variables are also escaped:

```@example attr-escape
using HypertextTemplates
using HypertextTemplates.Elements

# Attribute injection attempt
user_class = "normal\" onclick=\"alert('xss')"
html = @render @div {class = user_class} "Content"
println(html)

# URL injection protection  
user_url = "javascript:alert('xss')"
html2 = @render @a {href = user_url} "Click"
println(html2)
# Note: URL sanitization should be done at application level
```

## SafeString Type

When you have pre-escaped or trusted HTML content, use `SafeString`:

### Creating Safe Content

`SafeString` is a special type that bypasses the automatic escaping system, telling HypertextTemplates that the content has already been properly escaped or is from a trusted source. This is necessary when you need to include pre-rendered HTML content, such as output from a Markdown processor, syntax highlighter, or sanitized rich text editor. However, using `SafeString` incorrectly can introduce serious security vulnerabilities, so it should only be used when you have complete confidence in the safety of the content - never with raw user input.

```@example safestring-basic
using HypertextTemplates
using HypertextTemplates.Elements

# Mark content as safe (already escaped)
safe_html = SafeString("<strong>Bold text</strong>")
html = @render @div $safe_html
println(html)

# Compare with regular string (gets escaped)
regular_html = "<strong>Bold text</strong>"
html2 = @render @div $regular_html
println(html2)
```

### When to Use SafeString

Only use `SafeString` when you're certain the content is safe:

```@example when-safestring
using HypertextTemplates
using HypertextTemplates.Elements

# GOOD: Content from a trusted source (simulated)
function render_trusted_html()
    # Simulating trusted HTML from a markdown processor or similar
    trusted_html = "<em>This is emphasized</em> and <strong>this is bold</strong>"
    html = @render @div {class = "markdown"} $(SafeString(trusted_html))
    println(html)
end

render_trusted_html()

# BAD: Never use with raw user input!
# Example of what NOT to do:
user_input = "<script>alert('XSS')</script>"
# @div $(SafeString(user_input))  # DANGER: XSS vulnerability!
println("\nNever use SafeString with user input!")
```

## String Literals vs Dynamic Content

Understanding the distinction is crucial for security:

### String Literals (Not Escaped)

String literals in templates are trusted and not escaped:

```@example string-literals-trusted
using HypertextTemplates
using HypertextTemplates.Elements

# This is trusted developer content - NOT escaped
html = @render @div """
<strong>This is bold</strong>
<script>console.log("Trusted script")</script>
"""

println(html)
# String literals are treated as trusted HTML
```

### Dynamic Content (Escaped)

Variables and expressions are always escaped:

```@example dynamic-escaped
using HypertextTemplates
using HypertextTemplates.Elements

# This is dynamic content - ESCAPED
content = "<strong>User content</strong>"
html1 = @render @div $content
println("Variable content:")
println(html1)

# Expressions are also escaped
user_name = "<script>alert('xss')</script>"
html2 = @render @p "Welcome, " $(uppercase(user_name)) "!"
println("\nExpression content:")
println(html2)
```

## Common Security Patterns

### Sanitizing User Input

Always validate and sanitize user input at the application level:

```@example sanitize-input
using HypertextTemplates
using HypertextTemplates.Elements

@component function user_profile(; username, bio, website)
    # Validate username (alphanumeric only)
    clean_username = replace(username, r"[^a-zA-Z0-9_-]" => "")
    
    # Validate URL
    safe_website = if startswith(website, "http://") || startswith(website, "https://")
        website
    else
        "#"  # Invalid URL
    end
    
    @div {class = "profile"} begin
        @h2 $clean_username
        @p {class = "bio"} $bio  # Auto-escaped
        @a {href = safe_website, rel = "noopener"} "Website"
    end
end

@deftag macro user_profile end

# Safe usage
html = @render @user_profile {
    username = "alice_dev<script>",  # Script tag removed
    bio = "I love <b>coding</b>!",   # HTML escaped
    website = "https://example.com"
}
println(html)

# Unsafe input handled
html2 = @render @user_profile {
    username = "bob@#\$%",  # Special chars removed
    bio = "<script>alert('xss')</script>",  # Escaped
    website = "javascript:alert('xss')"  # Rejected
}
println(html2)
```

### Content Security Policy

Use CSP headers for defense in depth:

```@example csp-example
using HypertextTemplates
using HypertextTemplates.Elements

@component function page_with_csp()
    @html begin
        @head begin
            # Define CSP in meta tag
            @meta {
                "http-equiv" := "Content-Security-Policy",
                content = "default-src 'self'; script-src 'self' 'unsafe-inline'"
            }
            @title "Secure Page"
        end
        @body @__slot__
    end
end

@deftag macro page_with_csp end

# Example usage
html = @render @page_with_csp begin
    @h1 "Content protected by CSP"
    @p "This page has Content Security Policy headers."
end

println(html)
```

### Safe URL Handling

Validate URLs before use:

```@example safe-urls
using HypertextTemplates
using HypertextTemplates.Elements

function safe_url(url)
    # Only allow http(s) and relative URLs
    if startswith(url, "/") || 
       startswith(url, "http://") || 
       startswith(url, "https://")
        return url
    else
        return "#"  # Safe fallback
    end
end

@component function link_list(; links)
    @ul begin
        for link in links
            @li @a {href = safe_url(link.url)} $(link.text)
        end
    end
end

@deftag macro link_list end

# Example with various URLs
links = [
    (url = "https://example.com", text = "Safe HTTPS link"),
    (url = "/about", text = "Safe relative link"),
    (url = "javascript:alert('xss')", text = "Dangerous JS link"),
    (url = "data:text/html,<script>alert('xss')</script>", text = "Dangerous data URL")
]

html = @render @link_list {links}
println(html)
```

### Form Handling

Cross-Site Request Forgery (CSRF) protection is essential for any form that performs state-changing operations. CSRF tokens ensure that form submissions come from your own application rather than malicious third-party sites. The token should be unique per session or per request, validated server-side, and included as a hidden field in every form. This pattern, combined with proper session management and same-origin checks, provides robust protection against CSRF attacks.

```@example form-csrf
using HypertextTemplates
using HypertextTemplates.Elements

@component function secure_form(; csrf_token, action)
    @form {method = "POST", action} begin
        # Include CSRF token
        @input {type = "hidden", name = "csrf_token", value = csrf_token}
        
        Elements.@label {"for" := "email"} "Email:"
        @input {type = "email", id = "email", name = "email", required = true}
        
        @button {type = "submit"} "Submit"
    end
end

@deftag macro secure_form end

# Example usage with a mock CSRF token
csrf_token = "abc123def456"  # In practice, generate securely
html = @render @secure_form {csrf_token, action = "/submit"}
println(html)
```

## Dangerous Patterns to Avoid

### Never Trust User Input

```@example never-trust
using HypertextTemplates
using HypertextTemplates.Elements

# Simulate getting user input
function get_user_input()
    return "<script>alert('XSS attempt')</script>"
end

# DANGEROUS: Direct HTML injection
# user_html = get_user_input()
# @div $(SafeString(user_html))  # NO! XSS vulnerability

# SAFE: Let auto-escaping work
user_html = get_user_input()
html = @render @div $user_html  # Automatically escaped
println("Safe rendering:")
println(html)
```

### Avoid Building HTML Strings

```@example avoid-concat
using HypertextTemplates
using HypertextTemplates.Elements

# Example user input that tries to break out
user_class = "normal\" onclick=\"alert('xss')"

# DANGEROUS: String concatenation
# html = "<div class=\"" * user_class * "\">"  # NO!

# SAFE: Use the DSL
html = @render @div {class = user_class} "Content"  # Automatically escaped
println("Safe DSL rendering:")
println(html)
```

## Security Best Practices

### 1. Trust the Auto-Escaping

The default behavior is secure. Don't bypass it without good reason:

```@example trust-escaping
using HypertextTemplates
using HypertextTemplates.Elements

# Default is secure
@component function comment(; author, content, timestamp)
    @article {class = "comment"} begin
        @header begin
            @strong $author  # Escaped
            Elements.@time $timestamp  # Escaped
        end
        @p $content  # Escaped
    end
end

@deftag macro comment end

# Example with potentially malicious content
html = @render @comment {
    author = "<script>alert('xss')</script>",
    content = "Great article! <img src=x onerror=alert('xss')>",
    timestamp = "2024-01-01 <script>alert('xss')</script>"
}

println(html)
# All content is safely escaped
```

### 2. Validate at the Boundary

Validate input when it enters your system:

```@example validate-boundary
using HypertextTemplates
using HypertextTemplates.Elements

function create_comment(author, content)
    # Validate length
    if length(author) > 100 || length(content) > 1000
        error("Input too long")
    end

    # Validate content (example)
    if contains(content, r"<script"i)
        error("Invalid content")
    end

    # Return validated data
    return (author = author, content = content)
end

# Test validation
try
    comment = create_comment("Alice", "Great post!")
    println("Valid comment created: ", comment)
catch e
end

try
    create_comment("Bob", "Nice <script>alert('xss')</script>")
catch e
    println("\nBlocked invalid content: ", e)
end

try
    create_comment("A" ^ 200, "Too long")
catch e
    println("\nBlocked too long input: ", e)
end
```

### 3. Use Type Safety

Leverage Julia's type system for validation:

```@example type-safety
using HypertextTemplates
using HypertextTemplates.Elements

struct Username
    value::String

    function Username(str)
        # Validate on construction
        if isnothing(match(r"^[a-zA-Z0-9_-]{3,20}$", str))
            error("Invalid username format")
        end
        new(str)
    end
end

@component function user_badge(; user::Username)
    @span {class = "username"} $(user.value)
end

@deftag macro user_badge end

# Valid username
try
    valid_user = Username("alice_123")
    html = @render @user_badge {user = valid_user}
    println("Valid username: ", html)
catch e
    println("Error: ", e)
end

# Invalid username with special characters
try
    invalid_user = Username("alice<script>")
    html = @render @user_badge {user = invalid_user}
catch e
    println("\nBlocked invalid username: ", e)
end
```

### 4. Escape in Context

Different contexts need different escaping:

```@example escape-context
using HypertextTemplates
using HypertextTemplates.Elements

# Simple URL encoding function
function url_encode(str)
    # Basic URL encoding for demonstration
    replace(str, 
        ' ' => "%20",
        '<' => "%3C",
        '>' => "%3E",
        '"' => "%22",
        '&' => "%26"
    )
end

@component function multi_context(; user_input)
    @div begin
        # HTML context - auto-escaped
        @p $user_input

        # URL context - encode for URL
        safe_param = url_encode(user_input)
        @a {href = "/search?q=" * safe_param} "Search"

        # JavaScript context - use data attributes
        @button {
            "data-value" := user_input,
            onclick = "handleClick(this.dataset.value)"
        } "Click"
    end
end

@deftag macro multi_context end

# Example with potentially malicious input
user_input = "test & <script>alert('xss')</script>"
html = @render @multi_context {user_input}
println(html)
```

## Summary

HypertextTemplates.jl provides robust security by default:

- **Automatic escaping** of all dynamic content
- **SafeString** for explicitly trusted content
- **Context-aware** rendering for attributes and content
- **Type-safe** patterns for validation
- **Clear distinction** between trusted literals and dynamic content

The key principle: Trust the defaults. The auto-escaping will protect you from XSS attacks. Only use `SafeString` when you have pre-sanitized HTML from a trusted source. Always validate and sanitize user input at the application boundary before it reaches your templates.
