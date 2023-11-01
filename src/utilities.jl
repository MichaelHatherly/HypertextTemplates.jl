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

# Logging hacks to drop warnings about invalid HTML tags but also capture them to a tag set.

function _with_filtered_logging(f)
    invalid_tags = Set{String}()
    active_filter_logger = LoggingExtras.ActiveFilteredLogger(
        _drop_invalid_html_tag_warnings(invalid_tags),
        Logging.global_logger(),
    )
    result = Logging.with_logger(f, active_filter_logger)
    @debug "Invalid HTML tags:" invalid_tags
    return result
end

function _drop_invalid_html_tag_warnings(invalid_tags)
    function (log_args)
        result = match(r"^XMLError: Tag (.+) invalid from HTML parser ", log_args.message)
        if isnothing(result)
            return true
        else
            push!(invalid_tags, result.captures[1])
            return false
        end
    end
end

# EzXML helpers

function attributes(n::EzXML.Node)
    return [EzXML.nodename(a) => EzXML.nodecontent(a) for a in EzXML.attributes(n)]
end

function key_default(dict::AbstractDict, key::AbstractString)
    value = get(dict, key, nothing)
    return isnothing(value) ? value : isempty(value) ? key : value
end

function split_fallback(n::EzXML.Node)
    fallback = nothing
    nodes = EzXML.Node[]
    for each in EzXML.nodes(n)
        if EzXML.iselement(each)
            tag = EzXML.nodename(each)
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
