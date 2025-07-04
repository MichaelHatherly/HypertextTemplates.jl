"""
    @context {key = value, ...} body
    @context {key, ...} body

Set context values that will be available to all child components.

The `@context` macro allows passing data through the component tree without
explicit prop drilling. It uses Julia's `IOContext` mechanism to store
key-value pairs that can be retrieved by child components using `@get_context`.

Supports both explicit `key = value` syntax and shorthand `key` syntax (which
expands to `key = key`).

# Arguments
- Key-value pairs or shorthand symbols in `{}` syntax specifying the context data
- `body`: The content that will have access to the context

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function themed_button(; text = "Click me")
           theme = @get_context(:theme, "light")
           @button {class = "btn-\$theme"} \$text
       end;

julia> @deftag macro themed_button end
@themed_button (macro with 1 method)

julia> @render @context {theme = "dark"} begin
           @themed_button {text = "Dark Button"}
       end
"<button class=\\"btn-dark\\">Dark Button</button>"

julia> # Shorthand syntax
       theme = "blue"
       @render @context {theme} begin  # Same as {theme = theme}
           @themed_button
       end
"<button class=\\"btn-blue\\">Click me</button>"

julia> # Mixed syntax
       user = "alice"
       @render @context {user, theme = "dark"} begin
           @div begin
               @text "User: " @get_context(:user)
               @themed_button
           end
       end
"<div>User: alice<button class=\\"btn-dark\\">Click me</button></div>"
```

See also: [`@get_context`](@ref), [`@component`](@ref)
"""
macro context(props, body)
    io = S"io"
    eio = esc(io)

    # Process the props similar to how tag-macro.jl does it
    if !Meta.isexpr(props, :braces)
        error("@context expects properties in {} syntax")
    end

    # Extract key-value pairs
    context_pairs = []
    for arg in props.args
        if Meta.isexpr(arg, [:(=), :(:=)], 2)
            # Handle key = value syntax
            k, v = arg.args
            k = _context_key(k)
            push!(context_pairs, :($(QuoteNode(k)) => $(esc(v))))
        elseif isa(arg, Symbol)
            # Handle shorthand syntax: {name} becomes {name = name}
            k = _context_key(arg)
            push!(context_pairs, :($(QuoteNode(k)) => $(esc(arg))))
        else
            error("@context properties must be key=value pairs or shorthand symbols")
        end
    end

    # Generate the let block with IOContext
    quote
        let $eio = IOContext($eio, $(context_pairs...))
            $(esc(body))
        end
    end
end

_context_key(name) = Symbol("**context.", name, "**")
