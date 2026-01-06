using HypertextTemplates
using Examples

# Ensure build directory exists
build_dir = joinpath(@__DIR__, "src", "examples")
mkpath(build_dir)

# Copy compiled CSS to build directory
css_src = joinpath(@__DIR__, "Examples", "assets", "dist", "app.css")
css_dst = joinpath(build_dir, "app.css")
if isfile(css_src)
    cp(css_src, css_dst; force = true)
    println("Copied app.css to examples directory")
else
    @warn "Compiled CSS not found at $css_src - run `bun run build:css` first"
end

println("Generating component examples...")

# Generate HTML for each example
for entry in Examples.Templates.get_example_names()
    println("  Generating $(entry.output_file)...")
    open(joinpath(build_dir, entry.output_file), "w") do io
        @render io Examples.Templates.@HTMLDocument {
            title = entry.title,
            current_page = entry.output_file,
            css_path = "./app.css",
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
