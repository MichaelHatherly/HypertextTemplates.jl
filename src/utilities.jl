function is_stale_template(file, mtime)
    # This is a method that get's extended by ReviseExt.jl, without `Revise`
    # loaded then we just always treat template files as fresh, but when it's
    # loaded then we assume that the user is a developer working on in-progress
    # code where they would like to see changes to templates reflected whenever
    # they make changes.
    return false
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
