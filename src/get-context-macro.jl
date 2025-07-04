"""
    @get_context(key)
    @get_context(key, default)

Retrieve a value from the current context.

The `@get_context` macro retrieves values that were set by parent `@context`
blocks. It accesses the `IOContext` chain to find the requested key.

# Arguments
- `key`: The context key to retrieve (as a symbol or string)
- `default`: Optional default value if the key is not found

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function user_greeting()
           user = @get_context(:user, "Guest")
           @p "Hello, \$(user)!"
       end;

julia> @deftag macro user_greeting end
@user_greeting (macro with 1 method)

julia> @render @context {user = "Alice"} begin
           @user_greeting
       end
"<p>Hello, Alice!</p>"

julia> # Without context, uses default
       @render @user_greeting
"<p>Hello, Guest!</p>"

julia> # Access multiple context values
       @component function profile_card()
           user = @get_context(:user, "Unknown")
           theme = @get_context(:theme, "light")
           role = @get_context(:role)  # No default
           @div {class = "profile-\$theme"} begin
               @h3 \$user
               !isnothing(role) && @span {class = "role"} \$role
           end
       end;
```

See also: [`@context`](@ref), [`@component`](@ref)
"""
macro get_context(key)
    io = S"io"
    eio = esc(io)
    return :($(_get_context)($eio, $(esc(key))))
end

macro get_context(key, default)
    io = S"io"
    eio = esc(io)
    return :($(_get_context)($eio, $(esc(key)), $(esc(default))))
end

struct FlagDefault end
const flag_default = FlagDefault()

function _get_context(io, key)
    value = __get_context(io, key, flag_default)
    value === flag_default && error("Context key `$(key)` not found.")
    return value
end
_get_context(io, key, default) = __get_context(io, key, default)

function __get_context(io, key, default)
    real_key = _context_key(key)
    return get(io, real_key, default)
end
