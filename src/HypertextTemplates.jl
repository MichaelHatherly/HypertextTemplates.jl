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

function __init__()
    PackageExtensionCompat.@require_extensions
    return nothing
end

end # module HypertextTemplates
