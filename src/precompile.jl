# Precompilation.
#
# Rendering is generic over the element, the shape of its props and the
# destination `IO`, so the first `@render` in a fresh session compiles a large
# amount of shared machinery — the props plan walk, the escaping kernels, the
# slot and component calling convention — before it can emit a single byte.
# None of that depends on the caller's own templates, so running one
# representative template here bakes those specialisations into the package
# image and the user's first render only pays for their own code.
#
# The workload deliberately covers each shape the render path branches on:
# static props, dynamic props, interpolated attributes, elements with and
# without children, void elements, components reached both through a `@deftag`
# macro and through `@<`, default and named slots, and the escaping of the
# value types that turn up in templates. Revise is not loaded during
# precompilation, so what is cached is the non-Revise path, which is the one
# that runs in production.

module PrecompileWorkload

    using ..HypertextTemplates
    using ..Elements

    @component function item(; name, index, active = false)
        @li {class = active ? "item active" : "item", "data-index" := index} begin
            @span {class = "name", title = "row $(index)"} $name
            @text " #" index
        end
    end
    @deftag macro item end

    @component function panel(; title, subtitle = nothing)
        @section {class = "panel"} begin
            @header begin
                @h2 $title
                isnothing(subtitle) || @p {class = "subtitle"} $subtitle
            end
            @div {class = "body"} @__slot__
            @div {class = "footer"} @__slot__ footer
        end
    end
    @deftag macro panel end

    function page(io::IO, rows)
        return @render io @html {lang = "en"} begin
            @head begin
                @meta {charset = "UTF-8"}
                @title "Precompile workload"
            end
            @body {class = "page"} begin
                @panel {title = "Rows", subtitle = "generated"} begin
                    footer := @small "footer slot"
                    @ul {class = "list"} begin
                        for (index, row) in enumerate(rows)
                            @item {name = row, index = index, active = isodd(index)}
                        end
                    end
                end
                @p "Literal text with & and <angles>."
                @div begin
                    for row in rows
                        @<item {name = row, index = length(row), active = false}
                    end
                end
                @span $(1) $(2.5) $(:sym) $(true) $(SafeString("<b>safe</b>"))
                @br
            end
        end
    end

    # `@render` without a destination builds and takes its own buffer, which is a
    # separate specialisation from the one above.
    standalone() = @render @div {class = "standalone"} "text & more"

end

PrecompileTools.@compile_workload begin
    io = IOBuffer()
    PrecompileWorkload.page(io, ["alpha", "beta & gamma", "<delta>"])
    take!(io)
    PrecompileWorkload.standalone()
end
