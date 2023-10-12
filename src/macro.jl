"""
    template"folder/file.html"

Define an HTML template. The string must be a path to a valid HTML file.
"""
macro template_str(file::AbstractString)
    return _template_str(file, __module__, __source__, create = false)
end

"""
    create_template"folder/file.html"

A helper macro to create an empty template file. The string must be a path to a
non-existant HTML file.
"""
macro create_template_str(file::AbstractString)
    return _template_str(file, __module__, __source__, create = true)
end

function _template_str(file::AbstractString, __module__, __source__; create::Bool)
    file = _template_file_path(file, __source__)
    if endswith(file, ".html")
        if create
            if isfile(file)
                @error "template file exists, replace `create_template` with the `template` string macro and implement the template function definition" file
            else
                mkpath(dirname(file))
                touch(file)
                @info "created empty template file" file
                return nothing
            end
        else
            defs = components(file, __module__)
            exprs = expression.(defs)
            return esc(Expr(:toplevel, :(include_dependency($file)), exprs...))
        end
    else
        error("template file must have an '.html' extension: $file")
    end
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
