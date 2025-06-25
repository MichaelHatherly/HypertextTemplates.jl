"""
    @cm_component component_name(; props...) = "file_name.md"

Creates a new `@component` definition from a markdown file. The `CommonMark.jl`
package is used to parsed and render the contents of the file hence that
package must be installed as a dependency, since this features is provided via
the package extension mechanism.

Just as with a regular `@component` you can provide `props` to a markdown
component that will be used in any interpolated values (using the `CommonMark`
`\$` syntax for interpolation).

When `Revise.jl` is active and tracking the package which contains a
`@cm_component` definition updates to the source markdown file are tracked and
will cause the rendered component to be updated without the need to redefine
the component manually. If `Revise.jl` is not active then the component
definition's markdown AST is generated at compile-time and reused on each
render.
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
