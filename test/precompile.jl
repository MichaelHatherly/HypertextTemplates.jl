@testset "Precompile Workload" begin
    # The workload only pays for itself if it keeps covering the shapes the
    # render path branches on. Assert each one is still reached, so a later
    # edit that quietly drops a branch fails here rather than silently
    # costing users their first-render time back.
    workload = HypertextTemplates.PrecompileWorkload
    io = IOBuffer()
    # Revise is loaded here but not during precompilation, so turn its
    # source attributes off to compare against what the workload renders.
    workload.page(
        IOContext(io, HypertextTemplates._include_data_htloc() => false),
        ["alpha", "beta & gamma", "<delta>"],
    )
    rendered = String(take!(io))

    @test startswith(rendered, "<!DOCTYPE html>")
    # Static props merged into the opening tag, and dynamic ones.
    @test occursin("<section class=\"panel\">", rendered)
    @test occursin("data-index=\"2\"", rendered)
    # An interpolated attribute.
    @test occursin("title=\"row 1\"", rendered)
    # Escaping, in text and in attributes.
    @test occursin("beta &amp; gamma", rendered)
    @test occursin("&lt;delta&gt;", rendered)
    # Void elements, with and without props.
    @test occursin("<meta charset=\"UTF-8\">", rendered)
    @test occursin("<br>", rendered)
    # Default and named slots.
    @test occursin("<div class=\"body\">", rendered)
    @test occursin("<div class=\"footer\"><small>footer slot</small></div>", rendered)
    # A component reached through `@<` rather than its `@deftag` macro.
    @test occursin("data-index=\"12\"", rendered)
    # The value types templates interpolate.
    @test occursin("<span>12.5symtrue<b>safe</b></span>", rendered)

    # `@render` without a destination is its own specialisation. It builds
    # its own buffer, so there is nowhere to switch the source attributes
    # off and only the parts Revise does not touch can be checked.
    @test startswith(workload.standalone(), "<div class=\"standalone\"")
    @test endswith(workload.standalone(), ">text &amp; more</div>")
end
