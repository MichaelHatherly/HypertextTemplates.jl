module HypertextTemplates

# Imports:

import CodeTracking
import PackageExtensionCompat
import MacroTools
import SimpleBufferStream

# Exports:

export @<
export @__slot__
export @cm_component
export @component
export @deftag
export @element
export @esc_str
export @render
export @text
export SafeString
export StreamingRender

# Includes:

include("revise.jl")
include("hidden-var-macros.jl")
include("render-macro.jl")
include("tag-macro.jl")
include("text-macro.jl")
include("component-macro.jl")
include("slot-macro.jl")
include("element-rendering.jl")
include("SafeString.jl")
include("html-escaping.jl")
include("element-macro.jl")
include("deftag.jl")
include("Elements.jl")
include("template-source-lookup.jl")
include("render.jl")
include("stream.jl")
include("cmfile.jl")

# Initialization:

function __init__()
    PackageExtensionCompat.@require_extensions
end

end # module HypertextTemplates
