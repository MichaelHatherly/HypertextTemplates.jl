using Documenter
using HypertextTemplates

makedocs(
    sitename = "HypertextTemplates",
    format = Documenter.HTML(),
    modules = [HypertextTemplates],
)

deploydocs(
    repo = "github.com/MichaelHatherly/HypertextTemplates.jl.git",
    push_preview = true,
)
