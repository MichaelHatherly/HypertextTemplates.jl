@testset "Source Tracking Caches" begin
    # Resolving a call site and computing a component's line offset are
    # both memoised, because each is expensive enough to dominate a render
    # under Revise. Whatever the caches hand back has to be what computing
    # the answer from scratch would have produced -- on a cold cache and on
    # a warm one alike.
    extension = Base.get_extension(HypertextTemplates, :HypertextTemplatesReviseExt)
    @test extension !== nothing

    function tracked()
        @__LINE__, @render @div "x"
    end
    call_line, html = tracked()
    @test contains(html, "data-htroot=\"$(@__FILE__):$(call_line)")

    # Recover the uuid the macro planted at that call site.
    uuid = nothing
    for info in Base.code_lowered(tracked, Tuple{}), name in info.slotnames
        startswith(string(name), "@render") && (uuid = name)
    end
    @test uuid !== nothing

    location = LineNumberNode(call_line + 1, Symbol(@__FILE__))
    fresh = extension._resolve_method_offset(tracked, uuid, location)
    loaded = HypertextTemplates.ReviseIsLoaded()
    @test HypertextTemplates._method_offset(loaded, tracked, uuid, location) == fresh
    # Again, now that the entry is warm.
    @test HypertextTemplates._method_offset(loaded, tracked, uuid, location) == fresh

    # Same invariant for the per-render component offset cache.
    revise = (custom_component, (@__FILE__, 1))
    direct = HypertextTemplates._compute_dynamic_line_offset(revise)
    context = IOContext(IOBuffer(), HypertextTemplates._line_offsets_ref())
    @test HypertextTemplates._dynamic_line_offset(context, revise) == direct
    @test HypertextTemplates._dynamic_line_offset(context, revise) == direct
    # A stream with no cache attached still has to produce the same answer.
    @test HypertextTemplates._dynamic_line_offset(IOBuffer(), revise) == direct
    @test HypertextTemplates._dynamic_line_offset(context, nothing) == 0

    # `_render` has to actually attach that cache, and rendering has to
    # actually reach it. Checking only that the cache agrees with a fresh
    # computation would pass just as happily with the cache disconnected,
    # silently giving up the speedup it exists for.
    attached = nothing
    HypertextTemplates._render(
        IOBuffer(),
        (io, _) -> (attached = get(io, HypertextTemplates._line_offsets(), nothing)),
        nothing,
    )
    @test attached isa Ref

    # And an element that reports its source populates it, so a component's
    # offset really is resolved once per render rather than once per
    # element.
    populated = nothing
    HypertextTemplates._render(
        IOBuffer(),
        function (io, _)
            HypertextTemplates._dynamic_line_offset(io, revise)
            populated = get(io, HypertextTemplates._line_offsets(), nothing)
        end,
        nothing,
    )
    @test populated isa Ref
    @test isassigned(populated) && haskey(populated[], custom_component)

    # The call-site cache is keyed by the enclosing function's type, not by
    # the function object. A `@render` inside a capturing closure -- a
    # handler built per request, say -- hands over a fresh object every
    # call, and keying on it would add an entry per render forever.
    cache = extension.CACHE
    before = length(cache)
    for i = 1:200
        captured = i
        closure = () -> @render @div $captured
        closure()
    end
    @test length(cache) - before <= 1

    apply(f) = f()
    before = length(cache)
    for i = 1:200
        captured = i
        apply() do
            @render @div $captured
        end
    end
    @test length(cache) - before <= 1

    # Distinct call sites must still get distinct entries.
    first_site() = @render @div "a"
    second_site() = @render @div "b"
    before = length(cache)
    first_site()
    second_site()
    @test length(cache) - before == 2

    # And the table is bounded even against a stream of new call sites,
    # which is what repeated re-expansion under Revise looks like.
    before = length(cache)
    for i = 1:(extension.CACHE_LIMIT+50)
        HypertextTemplates._method_offset(
            loaded,
            tracked,
            Symbol("synthetic#", i),
            LineNumberNode(i, Symbol(@__FILE__)),
        )
    end
    @test length(cache) <= extension.CACHE_LIMIT

    # And what it drops to get there are the entries that were already
    # doomed. An entry only ever hits when its world matches the current
    # one, so one stamped with an older world would miss and be recomputed
    # regardless -- those are the abandoned revisions an editing session
    # leaves behind. An entry from the current world is still live and has
    # to survive, which the wholesale `empty!` this replaced did not manage.
    world = Base.get_world_counter()
    stale = (typeof(tracked), :evict_stale, LineNumberNode(1, Symbol(@__FILE__)))
    live = (typeof(tracked), :evict_live, LineNumberNode(2, Symbol(@__FILE__)))
    cache[stale] = (world - 1, 0.0, nothing)
    cache[live] = (world, 0.0, nothing)
    extension._evict!(world)
    @test !haskey(cache, stale)
    @test haskey(cache, live)

    # Concurrent renders must agree with single-threaded ones. The cache is
    # global, so it is guarded by a lock; the per-render offset cache is not
    # shared between renders at all.
    sites = [first_site, second_site, tracked]
    expected = [string(site()) for site in sites]
    outputs = Vector{Vector{String}}(undef, Threads.nthreads())
    Threads.@threads for thread = 1:Threads.nthreads()
        collected = String[]
        for _ = 1:50, site in sites
            push!(collected, string(site()))
        end
        outputs[thread] = collected
    end
    @test all(output == repeat(expected, 50) for output in outputs)
end
