"""
Theme utility functions for HypertextTemplates Library components.
Provides functions for merging and creating custom themes.
"""

"""
    merge_theme(base::NamedTuple, override::NamedTuple)

Deep merge two theme NamedTuples, with values from `override` taking precedence.
Nested NamedTuples are merged recursively.

# Arguments
- `base`: The base theme to merge into
- `override`: The theme with overrides to apply

# Example
```julia
base_theme = default_theme()
custom_theme = merge_theme(base_theme, (
    button = (
        variants = (
            primary = "bg-indigo-600 text-white hover:bg-indigo-700"
        )
    )
))
```
"""
function merge_theme(base::NamedTuple, override::NamedTuple)
    keys_all = union(keys(base), keys(override))

    merged = map(keys_all) do k
        if haskey(base, k) && haskey(override, k)
            base_val = base[k]
            override_val = override[k]
            if isa(base_val, NamedTuple) && isa(override_val, NamedTuple)
                # Recursive merge for nested NamedTuples
                k => merge_theme(base_val, override_val)
            else
                # Override takes precedence
                k => override_val
            end
        elseif haskey(override, k)
            k => override[k]
        else
            k => base[k]
        end
    end

    return NamedTuple(merged)
end

"""
    create_theme(; overrides...)

Create a custom theme based on the default theme with specified overrides.

# Arguments
- `overrides`: Keyword arguments specifying theme overrides

# Example
```julia
my_theme = create_theme(
    button = (
        variants = (
            primary = "bg-indigo-600 text-white hover:bg-indigo-700"
        )
    ),
    colors = (
        primary = "indigo-600"
    )
)
```
"""
function create_theme(; overrides...)
    merge_theme(default_theme(), NamedTuple(overrides))
end

export merge_theme, create_theme
