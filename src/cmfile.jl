"""
    @cm_component component_name(; props...) = "file_name.md"

Create a component from a Markdown file.

This macro creates a component that renders Markdown content from a file. The
Markdown is parsed using CommonMark.jl and can include interpolated values using
`\$variable` syntax.

!!! note
    This feature requires CommonMark.jl to be installed as it's provided via
    Julia's package extension mechanism.

# Arguments
- `component_name`: Name for the component function
- `props...`: Optional keyword arguments that can be interpolated in the Markdown
- `file_name.md`: Path to the Markdown file (relative to the current file)

# Features
- **Interpolation**: Use `\$prop_name` in Markdown to insert prop values
- **Live reload**: With Revise.jl, changes to the Markdown file auto-update
- **Compile-time parsing**: Without Revise.jl, Markdown is parsed at compile time for performance

# Examples

## Basic usage
```julia
# In article.md:
# # \$title
# 
# By \$author on \$date
# 
# \$content

# In your Julia code:
using HypertextTemplates, HypertextTemplates.Elements
using CommonMark

@cm_component article(; title, author, date, content) = "article.md"
@deftag macro article end

@render @article {
    title = "Hello World",
    author = "Jane Doe",
    date = "2024-01-15",
    content = "This is my first post!"
}
```

## Directory structure
```julia
# components/header.md contains:
# # \$site_name
# 
# *\$tagline*

# In components/components.jl:
@cm_component header(; site_name, tagline = "Welcome") = "header.md"

# Path is relative to the file containing @cm_component
```

## With default values
```julia
@cm_component footer(; copyright_year = 2024, company = "Acme Corp") = "footer.md"
@deftag macro footer end

# Uses defaults
@render @footer

# Override defaults
@render @footer {copyright_year = 2025}
```

## Complex content interpolation
```julia
# In template.md:
# # Product: \$name
# 
# Price: \$\$\$price
# 
# \$description

@cm_component product_card(; name, price, description) = "template.md"
@deftag macro product_card end

@render @product_card {
    name = "Widget",
    price = 19.99,
    description = "A **fantastic** widget with _many_ features!"
}
```

!!! tip "Development workflow"
    When using Revise.jl, you can edit the Markdown file and see changes
    immediately without restarting Julia or redefining the component.

See also: [`@component`](@ref), [`SafeString`](@ref)
"""
macro cm_component(expr)
    name, parameters, path = if MacroTools.@capture(expr, name_(; parameters__) = path_)
        name, parameters, path
    elseif MacroTools.@capture(expr, name_() = path_)
        name, [], path
    else
        error("invalid `@cm_component` synctax. Must be: name(; params...) = path")
    end

    # Handle direct REPL usage where `__source__` is not defined.
    dir = isnothing(__source__.file) ? pwd() : dirname(String(__source__.file))

    path_const = gensym(Symbol(name, :_path))
    text_const = gensym(Symbol(name, :_text))
    mod_const = gensym(Symbol(name, :_mod))
    gen_func_name = gensym(Symbol(name, :_gen))

    parameter_names = _extract_parameter_name.(parameters)

    # Adjust the source information of the component definition such that
    # `functionloc` returns the correct location for the `@cm_component` call
    # site.
    line, component_expr = @__LINE__() + 2,
    quote
        $(HypertextTemplates).@component function $(name)(; $(parameters...))
            ast = if $(_is_revise_loaded)()
                text = Symbol(read($path_const, String))
                # This results in a dynamic dispatch since `text` is a runtime value.
                $(gen_func_name)(Val{text}(); $(parameter_names...))
            else
                # Ideally this should be fully inferrable since
                # `text_const` is a global constant.
                $(gen_func_name)(Val{$text_const}(); $(parameter_names...))
            end
            $(HypertextTemplates).@text ast
        end
    end
    component_expr = MacroTools.postwalk(component_expr) do each
        file = String(__source__.file)
        if isa(each, LineNumberNode) &&
           String(each.file) == @__FILE__() &&
           each.line == line
            return LineNumberNode(__source__.line, file)
        else
            return each
        end
    end

    return esc(
        quote
            const $(path_const) = joinpath($dir, $(path))
            const $(text_const) = Symbol(read($path_const, String))
            const $(mod_const) = @__MODULE__

            # Changes to the markdown file linked should cause the pkgimage to
            # be invalidated since we store in `text_const` the content of the
            # file.
            $(Base).include_dependency($path_const)

            # This allows us to cache the markdown AST generated from the
            # `text`. `_parse_cm_content` returns an `Expr` that contains a
            # markdown AST which may contain references to the parameters
            # provided to this generated function. At runtime those references
            # will be updated with the values of the individual parameters.
            @generated function $(gen_func_name)(
                ::Val{text};
                $(parameters...),
            ) where {text}
                return $(HypertextTemplates)._parse_cm_content(
                    $mod_const,
                    text,
                    $path_const,
                )
            end

            $component_expr
        end,
    )
end

# This interface function is extended by the `HypertextTemplatesCommonMarkExt`
# extension module. See that file for the real definition.
_parse_cm_content(mod, text, path) = error("`@cm_component` needs `CommonMark.jl` to work.")

_extract_parameter_name(param::Symbol) = param
_extract_parameter_name(param::Expr) =
    Meta.isexpr(param, :kw, 2) ? param.args[1] : error("invalid parameter syntax: $param")
