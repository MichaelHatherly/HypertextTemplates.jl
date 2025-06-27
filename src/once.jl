"""
    @__once__ begin
        # content to render once
    end

Render content only once per `@render` call.

The `@__once__` macro ensures that its content is rendered only once, even if
the containing component is used multiple times within the same render tree.
This is essential for including CSS, JavaScript, or other resources that should
not be duplicated.

# Common use cases
- CSS styles that should appear once
- JavaScript libraries and initialization code
- Meta tags or link elements in components
- Any content that would cause issues if duplicated

# Examples
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function button_with_styles(; text, variant = "primary")
           @__once__ begin
               @style \"\"\"
               .btn { padding: 10px; border: none; cursor: pointer; }
               .btn-primary { background: blue; color: white; }
               .btn-danger { background: red; color: white; }
               \"\"\"
           end
           @button {class = "btn btn-\$variant"} \$text
       end;

julia> @deftag macro button_with_styles end
@button_with_styles (macro with 1 method)
```

# JavaScript dependencies
```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function chart(; data)
           @__once__ begin
               @script {src = "https://cdn.plot.ly/plotly-latest.min.js"}
           end
           @div {id = "chart-\$(hash(data))"} begin
               @script \"\"\"
               Plotly.newPlot('chart-\$(hash(data))', \$(data));
               \"\"\"
           end
       end;

julia> @deftag macro chart end
@chart (macro with 1 method)
```

# Scope behavior
Each `@render` call maintains its own set of rendered once-blocks:

```jldoctest
julia> using HypertextTemplates, HypertextTemplates.Elements

julia> @component function with_header()
           @__once__ @h1 "Page Header"
           @p "Content"
       end;

julia> @deftag macro with_header end
@with_header (macro with 1 method)

julia> # First render includes the header
       @render @with_header
"<h1>Page Header</h1><p>Content</p>"

julia> # Second render also includes it (different @render call)
       @render @with_header
"<h1>Page Header</h1><p>Content</p>"
```

See also: [`@component`](@ref), [`@render`](@ref)
"""
macro __once__(expr)
    key = QuoteNode(gensym(string(__module__)))
    io = esc(S"io")
    return quote
        if $(@__MODULE__)._missing_once_key($io, $key)
            $(esc(expr))
            $(@__MODULE__)._add_once_key!($io, $key)
        end
        nothing
    end
end

function _get_once(io::IO)
    once_ref = get(io, :__once__, nothing)
    isassigned(once_ref) || (once_ref[] = Set{Symbol}())
    once = once_ref[]
    return isnothing(once) ? error("missing `once` object.") : once
end

_missing_once_key(io::IO, key::Symbol) = !(key in _get_once(io))
_add_once_key!(io::IO, key::Symbol) = push!(_get_once(io), key)
