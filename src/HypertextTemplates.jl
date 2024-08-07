module HypertextTemplates

# Imports.

import AbstractTrees
import MacroTools
import PackageExtensionCompat

# Aliasing the Match package to avoid name conflicts with the Match struct.
baremodule Deps
import Match
end

# Exports.

export @template_str,
    @custom_element, @create_template_str, render, TemplateFileLookup, slots

# Constants.

# Used for replacing package-specific file/line information in macro-generated code.
const SRC_DIR = @__DIR__

# Includes.

include("Lexbor.jl")
include("SafeString.jl")
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
include("custom_element.jl")
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
