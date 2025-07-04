using HypertextTemplates
using Examples

# Ensure build directory exists
build_dir = joinpath(@__DIR__, "src", "examples")
mkpath(build_dir)

println("Generating component examples...")

# Generate HTML for each example
for entry in Examples.Templates.get_example_names()
    println("  Generating $(entry.output_file)...")
    open(joinpath(build_dir, entry.output_file), "w") do io
        @render io Examples.Templates.@HTMLDocument {
            title = entry.title,
            current_page = entry.output_file,
        } begin
            @<entry.component
        end
    end
end

println("\nComponent examples generated successfully!")
println("Files created in: $(build_dir)")
println("\nGenerated files:")
for file in readdir(build_dir)
    if endswith(file, ".html")
        println("  - $(file)")
    end
end
