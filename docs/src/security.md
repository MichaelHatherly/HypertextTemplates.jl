# Security

HypertextTemplates.jl includes built-in security features to protect against common web vulnerabilities. This guide covers the automatic escaping system and best practices for secure template development.

## Automatic HTML Escaping

The most important security feature is automatic HTML escaping of dynamic content, which prevents Cross-Site Scripting (XSS) attacks.

### Default Escaping Behavior

All dynamic content is automatically escaped:

```julia
# User input is automatically escaped
user_input = "<script>alert('XSS')</script>"
html = @render @p "User said: " $user_input

# Output: <p>User said: &lt;script&gt;alert('XSS')&lt;/script&gt;</p>
# The script tag is rendered as visible text, not executed
```

### What Gets Escaped

The escaping system handles these special characters:

```julia
# These characters are escaped in dynamic content:
# & becomes &amp;
# < becomes &lt;
# > becomes &gt;
# " becomes &quot;
# ' becomes &#39;

malicious = """<img src="x" onerror="alert('xss')">"""
@render @div $malicious
# Output: <div>&lt;img src=&quot;x&quot; onerror=&quot;alert('xss')&quot;&gt;</div>
```

### Escaping in Attributes

Attribute values from variables are also escaped:

```julia
# Attribute injection attempt
user_class = "normal\" onclick=\"alert('xss')"
@render @div {class = user_class} "Content"
# Output: <div class="normal&quot; onclick=&quot;alert('xss')">Content</div>

# URL injection protection  
user_url = "javascript:alert('xss')"
@render @a {href = user_url} "Click"
# Output: <a href="javascript:alert('xss')">Click</a>
# Note: URL sanitization should be done at application level
```

## SafeString Type

When you have pre-escaped or trusted HTML content, use `SafeString`:

### Creating Safe Content

```julia
# Mark content as safe (already escaped)
safe_html = SafeString("<strong>Bold text</strong>")
@render @div $safe_html
# Output: <div><strong>Bold text</strong></div>

# Useful for pre-rendered content
markdown_html = markdown_to_html(user_markdown)
@render @article $(SafeString(markdown_html))
```

### When to Use SafeString

Only use `SafeString` when you're certain the content is safe:

```julia
# GOOD: Content from trusted markdown processor
function render_markdown(markdown_text)
    # CommonMark escapes user content appropriately
    html = CommonMark.html(markdown_text)
    @div {class = "markdown"} $(SafeString(html))
end

# GOOD: Pre-escaped content from your own escaping
escaped = html_escape(user_input)
processed = process_escaped_content(escaped)
@div $(SafeString(processed))

# BAD: Never use with raw user input!
# @div $(SafeString(user_input))  # DANGER: XSS vulnerability!
```

## The @esc_str Macro

For compile-time escaping of string literals:

```julia
# Escape at compile time
const ESCAPED_SNIPPET = @esc_str """
<div class="example">
    Code: <script>console.log("hi")</script>
</div>
"""

# Use in templates
@render @pre {class = "code-example"} $(SafeString(ESCAPED_SNIPPET))
# The script tag will be visible, not executed
```

## String Literals vs Dynamic Content

Understanding the distinction is crucial for security:

### String Literals (Not Escaped)

String literals in templates are trusted and not escaped:

```julia
# This is trusted developer content - NOT escaped
@render @div """
<strong>This is bold</strong>
<script>console.log("Trusted script")</script>
"""
# Output: <div>
# <strong>This is bold</strong>
# <script>console.log("Trusted script")</script>
# </div>
```

### Dynamic Content (Escaped)

Variables and expressions are always escaped:

```julia
# This is dynamic content - ESCAPED
content = "<strong>User content</strong>"
@render @div $content
# Output: <div>&lt;strong&gt;User content&lt;/strong&gt;</div>

# Expressions are also escaped
user_name = "<script>alert('xss')</script>"
@render @p "Welcome, " $(uppercase(user_name)) "!"
# Output: <p>Welcome, &LT;SCRIPT&GT;ALERT('XSS')&LT;/SCRIPT&GT;!</p>
```

## Common Security Patterns

### Sanitizing User Input

Always validate and sanitize user input at the application level:

```julia
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
```

### Content Security Policy

Use CSP headers for defense in depth:

```julia
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
```

### Safe URL Handling

Validate URLs before use:

```julia
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
            @li @a {href = safe_url(link.url)} $link.text
        end
    end
end
```

### Form Handling

Protect forms with CSRF tokens:

```julia
@component function secure_form(; csrf_token, action)
    @form {method = "POST", action} begin
        # Include CSRF token
        @input {type = "hidden", name = "csrf_token", value = csrf_token}
        
        @label {for = "email"} "Email:"
        @input {type = "email", id = "email", name = "email", required = true}
        
        @button {type = "submit"} "Submit"
    end
end
```

## Dangerous Patterns to Avoid

### Never Trust User Input

```julia
# DANGEROUS: Direct HTML injection
# user_html = get_user_input()
# @div $(SafeString(user_html))  # NO! XSS vulnerability

# SAFE: Let auto-escaping work
user_html = get_user_input()
@div $user_html  # Automatically escaped
```

### Avoid Building HTML Strings

```julia
# DANGEROUS: String concatenation
# html = "<div class=\"" * user_class * "\">"  # NO!

# SAFE: Use the DSL
@div {class = user_class}  # Automatically escaped
```

### Be Careful with JavaScript

```julia
# DANGEROUS: Injecting into JavaScript
# @script """
# var username = "$(user_name)";  // NO! Code injection
# """

# SAFER: Use data attributes and read from DOM
@div {id = "app", "data-username" := user_name}
@script """
const app = document.getElementById('app');
const username = app.dataset.username;  // Safely encoded
"""
```

## Security Best Practices

### 1. Trust the Auto-Escaping

The default behavior is secure. Don't bypass it without good reason:

```julia
# Default is secure
@component function comment(; author, content, timestamp)
    @article {class = "comment"} begin
        @header begin
            @strong $author  # Escaped
            @time $timestamp  # Escaped
        end
        @p $content  # Escaped
    end
end
```

### 2. Validate at the Boundary

Validate input when it enters your system:

```julia
function create_comment(author, content)
    # Validate length
    if length(author) > 100 || length(content) > 1000
        error("Input too long")
    end
    
    # Validate content (example)
    if contains(content, r"<script"i)
        error("Invalid content")
    end
    
    # Store validated data
    save_comment(author, content)
end
```

### 3. Use Type Safety

Leverage Julia's type system for validation:

```julia
struct Username
    value::String
    
    function Username(str)
        # Validate on construction
        if !match(r"^[a-zA-Z0-9_-]{3,20}$", str)
            error("Invalid username format")
        end
        new(str)
    end
end

@component function user_badge(; user::Username)
    @span {class = "username"} $(user.value)
end
```

### 4. Escape in Context

Different contexts need different escaping:

```julia
@component function multi_context(; user_input)
    @div begin
        # HTML context - auto-escaped
        @p $user_input
        
        # URL context - validate first
        safe_param = URIEncode(user_input)
        @a {href = "/search?q=" * safe_param} "Search"
        
        # JavaScript context - use data attributes
        @button {
            "data-value" := user_input,
            onclick = "handleClick(this.dataset.value)"
        } "Click"
    end
end
```

### 5. Regular Security Audits

Review your templates for security:

```julia
# Check for SafeString usage
# grep -r "SafeString" src/

# Check for string literal HTML
# grep -r '@[a-z]* """' src/

# Review dynamic attributes
# grep -r '{.*:=' src/
```

## Testing Security

### Unit Tests for Escaping

```julia
using Test

@testset "Security Tests" begin
    # Test XSS prevention
    malicious = "<script>alert('xss')</script>"
    result = @render @div $malicious
    @test !contains(result, "<script>")
    @test contains(result, "&lt;script&gt;")
    
    # Test attribute escaping
    bad_attr = "\" onclick=\"alert('xss')"
    result = @render @div {class = bad_attr} "Test"
    @test !contains(result, "onclick=")
    @test contains(result, "&quot;")
end
```

### Integration Tests

```julia
@testset "Form Security" begin
    # Test CSRF protection
    token = generate_csrf_token()
    html = @render @secure_form {csrf_token = token, action = "/submit"}
    @test contains(html, token)
    
    # Test form validation
    @test_throws ErrorException @render @secure_form {
        csrf_token = "",  # Empty token should fail
        action = "/submit"
    }
end
```

## Summary

HypertextTemplates.jl provides robust security by default:

- **Automatic escaping** of all dynamic content
- **SafeString** for explicitly trusted content
- **Context-aware** rendering for attributes and content
- **Type-safe** patterns for validation
- **Clear distinction** between trusted literals and dynamic content

The key principle: Trust the defaults. The auto-escaping will protect you from XSS attacks. Only use `SafeString` when you have pre-sanitized HTML from a trusted source. Always validate and sanitize user input at the application boundary before it reaches your templates.