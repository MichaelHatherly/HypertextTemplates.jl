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
passed to `Revise` to perform code revision.
"""
macro cm_component(expr)
    name, parameters, path = if MacroTools.@capture(expr, name_(; parameters__) = path_)
        name, parameters, path
    elseif MacroTools.@capture(expr, name_() = path_)
        name, [], path
    else
        error("invalid `@cm_component` synctax. Must be: name(; params...) = path")
    end

    dir = dirname(String(__source__.file))
    return quote
        $(Base).include_dependency(joinpath($dir, $(esc(path))))
        $(Base).include(
            $(__module__),
            $(CMFile)(
                joinpath($(dir), $(esc(path))),
                $(__module__),
                $(QuoteNode(Symbol(name))),
                $(QuoteNode(parameters)),
            ),
        )
        $(Expr(
            :toplevel,
            Expr(
                :module,
                true,
                esc(gensym("markdown_component_watcher")),
                Expr(
                    :block,
                    esc(
                        :(
                            __init__() = $(HypertextTemplates)._includet(
                                $(__module__),
                                $(CMFile)(
                                    joinpath($(dir), $(path)),
                                    $(__module__),
                                    $(QuoteNode(Symbol(name))),
                                    $(QuoteNode(parameters)),
                                ),
                            )
                        ),
                    ),
                ),
            ),
        ))
    end
end

struct CMFile
    file::String
    mod::Module
    name::Symbol
    parameters::Vector
end

Base.String(vaf::CMFile) = vaf.file
Base.abspath(file::CMFile) =
    CMFile(Base.abspath(file.file), file.mod, file.name, file.parameters)
Base.isfile(file::CMFile) = Base.isfile(file.file)
Base.isabspath(file::CMFile) = Base.isabspath(file.file)
Base.findfirst(str::String, file::CMFile) = Base.findfirst(str, file.file)
Base.joinpath(str::String, file::CMFile) =
    CMFile(Base.joinpath(str, file.file), file.mod, file.name, file.parameters)
Base.normpath(file::CMFile) =
    CMFile(Base.normpath(file.file), file.mod, file.name, file.parameters)

function Base.include(mod::Module, file::CMFile)
    ex = cm_file_expr(mod, file)
    Core.eval(mod, ex)
    return nothing
end

function cm_file_expr(mod::Module, file::CMFile)
    _cm_file_expr(mod, file, nothing)
end

function _cm_file_expr(::Module, ::CMFile, ::Any)
    error("`CommonMark.jl` must be imported to use the `@cm` macro.")
end

_includet(mod::Module, cmfile::CMFile) = _includet(mod, cmfile, nothing)
_includet(mod::Module, cmfile::CMFile, ::Any) = Base.include(mod, cmfile)
