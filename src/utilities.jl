function is_stale_template(file, mtime)
    # This is a method that get's extended by ReviseExt.jl, without `Revise`
    # loaded then we just always treat template files as fresh, but when it's
    # loaded then we assume that the user is a developer working on in-progress
    # code where they would like to see changes to templates reflected whenever
    # they make changes.
    return false
end

# Internal type used to dispatch to the correct handler generating function
# based on whether `Revise` and `HTTP` are loaded. See the
# `HypertextTemplatesHTTPReviseExt` module for the actual implementation of the
# feature.
struct TemplateFileLookupType end

"""
    TemplateFileLookup(handler)

This is a developer tool that can be added to an `HTTP` handler stack to allow
the user to open the template file in their default editor by holding down the
`Ctrl` key and clicking on the rendered template. This is useful for debugging
navigating the template files instead of having to manually search through a
codebase for the template file that renders a given item within a page.

```julia
HTTP.serve(router |> TemplateFileLookup, host, port)
```

Always add the `TemplateFileLookup` handler after the other handlers, since it
needs to inject a script into the response to listen for clicks on the rendered
template.
"""
TemplateFileLookup(handler) = _template_file_lookup(TemplateFileLookupType(), handler)

function _template_file_lookup(T, handler)
    function (request)
        return handler(request)
    end
end

# Helpers

function attributes(n::Lexbor.Node)
    return [k => something(v, "") for (k, v) in n.attributes]
end

function key_default(dict::AbstractDict, key::AbstractString)
    value = get(dict, key, nothing)
    return isnothing(value) ? value : isempty(value) ? key : value
end

function split_fallback(n::Lexbor.Node)
    fallback = nothing
    nodes = Union{String,Lexbor.Node}[]
    for each in Lexbor.nodes(n)
        if Lexbor.iselement(each)
            tag = Lexbor.nodename(each)
            if tag == FALLBACK_TAG
                if isnothing(fallback)
                    fallback = each
                else
                    error("more than one 'fallback' nodes found.")
                end
            else
                push!(nodes, each)
            end
        else
            push!(nodes, each)
        end
    end
    return nodes, fallback
end

function lln_replacer(file::Union{String,Symbol}, line::Integer)
    file = Symbol(file)
    function (ex::Expr)
        if line > 0
            MacroTools.postwalk(ex) do each
                if isa(each, LineNumberNode)
                    if startswith(string(each.file), SRC_DIR)
                        return LineNumberNode(line, file)
                    else
                        return each
                    end
                else
                    return each
                end
            end
        else
            return ex
        end
    end
end
