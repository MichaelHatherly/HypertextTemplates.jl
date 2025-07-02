using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Include shared components
include("shared/html_document.jl")
include("shared/example_registry.jl")

# Include all example components
for entry in EXAMPLE_REGISTRY
    include(joinpath("examples", entry.filename))
end

# Ensure build directory exists
build_dir = joinpath(@__DIR__, "src", "examples")
mkpath(build_dir)

println("Generating component examples...")

# Generate HTML for each example
for entry in EXAMPLE_REGISTRY
    println("  Generating $(entry.output_file)...")

    # Get the component based on the registry entry
    component_symbol = Symbol(entry.component_name)
    component = getfield(Main, component_symbol)

    # Render the HTML
    html = @render @HTMLDocument {title = entry.title, current_page = entry.output_file} begin
        @<component {}
    end

    # Write to file
    write(joinpath(build_dir, entry.output_file), html)
end

println("\nComponent examples generated successfully!")
println("Files created in: $(build_dir)")
println("\nGenerated files:")
for file in readdir(build_dir)
    if endswith(file, ".html")
        println("  - $(file)")
    end
end
