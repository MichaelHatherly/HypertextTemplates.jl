module HypertextTemplates

# Imports.

import AbstractTrees
import EzXML
import Logging
import LoggingExtras
import MacroTools
import PackageExtensionCompat

# Aliasing the Match package to avoid name conflicts with the Match struct.
baremodule Deps
import Match
end

# Exports.

export @template_str, @create_template_str, render, TemplateFileLookup

# Includes.

include("utilities.jl")
include("macro.jl")
include("nodes/abstract.jl")
include("nodes/slot.jl")
include("nodes/function.jl")
include("nodes/element.jl")
include("nodes/for.jl")
include("nodes/julia.jl")
include("nodes/match.jl")
include("nodes/show.jl")
include("nodes/text.jl")
include("symbol-swapping.jl")
include("render.jl")

const RESERVED_ELEMENT_NAMES = Set([
    TEMPLATE_FUNCTION_TAG,
    SLOT_TAG,
    SHOW_TAG,
    FALLBACK_TAG,
    MATCH_TAG,
    CASE_TAG,
    FOR_TAG,
    JULIA_TAG,
])

const DATA_FILENAME_MAPPING = Dict{String,Int}()
const DATA_FILENAME_MAPPING_REVERSE = Dict{Int,String}()

function _register_filename_mapping!(file::String)
    key = get!(DATA_FILENAME_MAPPING, file) do
        return length(DATA_FILENAME_MAPPING) + 1
    end
    if haskey(DATA_FILENAME_MAPPING_REVERSE, key) &&
       DATA_FILENAME_MAPPING_REVERSE[key] != file
        error("filename key collision: $key")
    else
        DATA_FILENAME_MAPPING_REVERSE[key] = file
    end
    return key
end

function __init__()
    PackageExtensionCompat.@require_extensions
    empty!(DATA_FILENAME_MAPPING)
    empty!(DATA_FILENAME_MAPPING_REVERSE)
    return nothing
end

end # module HypertextTemplates
