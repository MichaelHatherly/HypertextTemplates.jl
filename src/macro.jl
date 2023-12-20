"""
    template"folder/file.html"

Define an HTML template. The string must be a path to a valid HTML file.
"""
macro template_str(file::AbstractString, suffix = "jmd")
    return _template_str(file, __module__, __source__, suffix; create = false)
end

"""
    create_template"folder/file.html"

A helper macro to create an empty template file. The string must be a path to a
non-existant HTML file.
"""
macro create_template_str(file::AbstractString, suffix = "jmd")
    return _template_str(file, __module__, __source__, suffix, create = true)
end

function _template_str(file::AbstractString, __module__, __source__, suffix; create::Bool)
    file = _template_file_path(file, __source__)
    _, ext = splitext(file)
    if ext in (".html", ".md")
        if create
            return _create_template(file)
        end
        if ext == ".html"
            return _template_expr(file, components(file, __module__))
        end
        if ext == ".md"
            return _template_expr(file, _markdown_components(file, __module__, suffix))
        end
    end
    error("template file must have an '.html' or '.md' extension: $file")
end

function _template_expr(file, defs)
    exprs = expression.(defs)
    return esc(Expr(:toplevel, :(include_dependency($file)), exprs...))
end

function _create_template(file::AbstractString)
    if isfile(file)
        @error "template file exists, replace `create_template` with the `template` string macro and implement the template function definition" file
    else
        mkpath(dirname(file))
        touch(file)
        @info "created empty template file" file
        return nothing
    end
end

function _markdown_components(file, mod, suffix)
    return _handle_commonmark_ext(CommonMarkExtensionType(), file, mod, suffix)
end

struct CommonMarkExtensionType end

function _handle_commonmark_ext(::Any, file, mod, suffix)
    error("markdown template files require you to import the `CommonMark` package first.")
end

function _template_file_path(file, __source__)
    if isabspath(file) && isfile(file)
        return file
    else
        dir = dirname(String(__source__.file))
        if isdir(dir)
            return joinpath(dir, file)
        else
            return joinpath(pwd(), file)
        end
    end
end
