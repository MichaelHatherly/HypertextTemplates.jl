@testmodule Sources begin

    using HypertextTemplates

    export revise_extension, render_uuid

    # `Base.get_extension` only exists from Julia 1.9. Before that
    # `PackageExtensionCompat` loads the extension into the package itself, so it
    # is reached as an ordinary submodule.
    function revise_extension()
        name = :HypertextTemplatesReviseExt
        if isdefined(Base, :get_extension)
            return Base.get_extension(HypertextTemplates, name)
        else
            return isdefined(HypertextTemplates, name) ? getfield(HypertextTemplates, name) :
                nothing
        end
    end

    # Recover the uuid `@render` planted at the call site inside `f`.
    function render_uuid(f)
        for info in Base.code_lowered(f, Tuple{}), name in info.slotnames
            startswith(string(name), "@render") && return name
        end
        return nothing
    end

end

@testitem "call site offset cache" tags = [:source] setup = [Templates, Sources] begin
    using HypertextTemplates.Elements

    # Resolving a call site is memoised, because it is expensive enough to
    # dominate a render under Revise. Whatever the cache hands back has to
    # be what an independent computation produces -- on a cold cache and a
    # warm one alike.
    extension = revise_extension()
    @test extension !== nothing

    function tracked()
        @__LINE__, @render @div "x"
    end
    call_line, html = tracked()
    @test contains(html, "data-htroot=\"$(@__FILE__):$(call_line)")

    uuid = render_uuid(tracked)
    @test uuid !== nothing

    location = LineNumberNode(call_line + 1, Symbol(@__FILE__))
    fresh, cacheable = extension._resolve_method_offset(tracked, uuid, location)
    @test cacheable
    loaded = HypertextTemplates.ReviseIsLoaded()
    @test HypertextTemplates._method_offset(loaded, tracked, uuid, location) == fresh
    # Again, now that the entry is warm.
    @test HypertextTemplates._method_offset(loaded, tracked, uuid, location) == fresh

    # A call site with no file at all is neither an error nor a stat of the
    # relative path "nothing".
    @test HypertextTemplates._method_offset(
        loaded,
        tracked,
        uuid,
        LineNumberNode(call_line + 1),
    ) === nothing
end

@testitem "component line offset cache" tags = [:source] setup = [Templates, Sources] begin
    # The per-render component offset cache has to agree with an
    # independent computation. The reference comes from `functionloc`
    # rather than from `_compute_dynamic_line_offset`, which is memoised
    # itself and would otherwise only be checked against its own cache.
    revise = (custom_component, (@__FILE__, 1))
    direct = functionloc(custom_component)[2] - 1
    @test HypertextTemplates._compute_dynamic_line_offset(revise) == direct
    context = IOContext(IOBuffer(), HypertextTemplates._line_offsets_ref())
    @test HypertextTemplates._dynamic_line_offset(context, revise) == direct
    @test HypertextTemplates._dynamic_line_offset(context, revise) == direct
    # A stream with no cache attached still has to produce the same answer.
    @test HypertextTemplates._dynamic_line_offset(IOBuffer(), revise) == direct
    @test HypertextTemplates._dynamic_line_offset(context, nothing) == 0
    # As does one carrying some other kind of `Ref` under our key, which is
    # an uncached lookup rather than an error.
    foreign = IOContext(IOBuffer(), HypertextTemplates._line_offsets() => Ref{Any}())
    @test HypertextTemplates._dynamic_line_offset(foreign, revise) == direct

    # The offset depends on the recorded line as well as the function, so a
    # second record for the same function must not be handed the first
    # one's answer -- from either cache.
    shifted = (custom_component, (@__FILE__, 2))
    @test HypertextTemplates._compute_dynamic_line_offset(shifted) == direct - 1
    @test HypertextTemplates._dynamic_line_offset(context, shifted) == direct - 1
end

@testitem "source location attributes" tags = [:source] setup = [Templates, Sources] begin
    # `:__root__` is only installed for a call site that had a source
    # location; otherwise the lookup reads through to the caller's context,
    # which can hold anything at all.
    hostile = IOContext(IOBuffer(), :__root__ => "not a location")
    HypertextTemplates._render_source_prop(hostile, (@__FILE__, 1), nothing)
    rendered = String(take!(hostile.io))
    @test contains(rendered, "data-htloc=") && !contains(rendered, "data-htroot=")

    # Including a tuple of the right shape but another integer width, which
    # nothing here produces.
    widened = IOContext(IOBuffer(), :__root__ => (@__FILE__, Int32(1)))
    HypertextTemplates._render_source_prop(widened, (@__FILE__, 1), nothing)
    @test !contains(String(take!(widened.io)), "data-htroot=")

    # Both paths land in a quoted attribute, so both are escaped.
    quoted = IOContext(IOBuffer(), :__root__ => ("ro\"ot", 2))
    HypertextTemplates._render_source_prop(quoted, ("fi\"le", 3), nothing)
    @test String(take!(quoted.io)) ==
        " data-htroot=\"ro&quot;ot:2\" data-htloc=\"fi&quot;le:3\""
end

@testitem "renders carry the offset cache" tags = [:source] setup = [Templates, Sources] begin
    # `_render` has to actually attach that cache, and rendering has to
    # actually reach it. Checking only that the cache agrees with a fresh
    # computation would pass just as happily with the cache disconnected,
    # silently giving up the speedup it exists for.
    function attached_cache(body)
        cache = nothing
        HypertextTemplates._render(
            IOBuffer(),
            function (io, _)
                body(io)
                cache = get(io, HypertextTemplates._line_offsets(), nothing)
            end,
            nothing,
        )
        return cache
    end
    @test attached_cache(io -> nothing) isa Ref

    # And an element that reports its source populates it, so a component's
    # offset really is resolved once per render rather than once per
    # element.
    revise = (custom_component, (@__FILE__, 1))
    populated = attached_cache(io -> HypertextTemplates._dynamic_line_offset(io, revise))
    @test populated isa Ref
    @test isassigned(populated) && haskey(populated[], custom_component)
end

@testitem "call site cache is bounded" tags = [:source] setup = [Templates, Sources] begin
    using HypertextTemplates.Elements

    extension = revise_extension()
    function tracked()
        @__LINE__, @render @div "x"
    end
    tracked()
    loaded = HypertextTemplates.ReviseIsLoaded()

    # The call-site cache is keyed by the enclosing function's type, not by
    # the function object. A `@render` inside a capturing closure -- a
    # handler built per request, say -- hands over a fresh object every
    # call, and keying on it would add an entry per render forever.
    cache = extension.SITES.entries
    before = length(cache)
    for i in 1:200
        captured = i
        closure = () -> @render @div $captured
        closure()
    end
    @test length(cache) - before <= 1

    apply(f) = f()
    before = length(cache)
    for i in 1:200
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
    for i in 1:(extension.SITES.limit + 50)
        HypertextTemplates._method_offset(
            loaded,
            tracked,
            Symbol("synthetic#", i),
            LineNumberNode(i, Symbol(@__FILE__)),
        )
    end
    @test length(cache) <= extension.SITES.limit

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
    HypertextTemplates._evict!(extension.SITES, world)
    @test !haskey(cache, stale)
    @test haskey(cache, live)
end

@testitem "concurrent renders agree with serial ones" tags = [:source] setup = [Templates, Sources] begin
    using HypertextTemplates.Elements

    # The call site cache is global, so it is guarded by a lock; the
    # per-render offset cache is not shared between renders at all.
    first_site() = @render @div "a"
    second_site() = @render @div "b"
    third_site() = @render @div "c"
    sites = [first_site, second_site, third_site]
    expected = [string(site()) for site in sites]
    # Filled rather than `undef`, so a thread that dies fails the test
    # below rather than throwing `UndefRefError` out of it.
    outputs = [String[] for _ in 1:Threads.nthreads()]
    Threads.@threads for thread in 1:Threads.nthreads()
        collected = String[]
        for _ in 1:50, site in sites
            push!(collected, string(site()))
        end
        outputs[thread] = collected
    end
    @test all(output == repeat(expected, 50) for output in outputs)
end

@testitem "nothing is cached while a revision is queued" tags = [:source] setup = [Templates, Sources] begin
    import Revise

    # Nothing may be cached while a revision is queued: a moved-but-unchanged
    # definition would poison the cache with nothing left to invalidate it.
    cache = HypertextTemplates.SourceCache{Int, Int}()
    pending = (Revise.PkgData(Base.PkgId(HypertextTemplates)), "pending.jl")
    push!(Revise.revision_queue, pending)
    try
        @test !HypertextTemplates._source_cache_writable()
        @test HypertextTemplates._cached(() -> (1, true), cache, 1, "") == 1
        @test isempty(cache.entries)
    finally
        delete!(Revise.revision_queue, pending)
    end
    @test HypertextTemplates._source_cache_writable()
    @test HypertextTemplates._cached(() -> (1, true), cache, 1, "") == 1
    @test haskey(cache.entries, 1)

    # A computation that reports itself uncacheable is answered but retried
    # next time, so a transient failure is not memoised forever.
    @test HypertextTemplates._cached(() -> (2, false), cache, 2, "") == 2
    @test !haskey(cache.entries, 2)
end

@testitem "a moved definition reports its new line" tags = [:source] setup = [Templates, Sources] begin
    import Revise

    # End to end: a component whose definition moves has to report its new
    # line once Revise has caught up, whatever was rendered in between.
    directory = mktempdir(; cleanup = true)
    path = joinpath(directory, "shifting.jl")
    # `includet` evaluates into `Main`, which a test item's own imports do not
    # reach, so the file brings the macros it uses with it.
    definition(padding) = string(
        "using HypertextTemplates, HypertextTemplates.Elements\n",
        repeat("\n", padding),
        """
        @component function shifting(; )
            @div "shifting"
        end
        """,
    )
    write(path, definition(0))
    Revise.includet(path)

    # `shifting` is defined while this test runs, so reaching it has to be
    # deferred to the world it was defined in.
    render() = Base.invokelatest(() -> @render @<(getfield(Main, :shifting)))
    reported(html) = parse(Int, match(r"shifting\.jl:(\d+)\"", html)[1])
    before = reported(render())
    key = (typeof(getfield(Main, :shifting)), 1)

    write(path, definition(5))
    # The watcher that queues a changed file is asynchronous; queueing it
    # here rather than waiting keeps the test from racing it.
    for (_, pkgdata) in Revise.pkgdatas, file in Revise.srcfiles(pkgdata)
        joinpath(Revise.basedir(pkgdata), file) == path &&
            push!(Revise.revision_queue, (pkgdata, file))
    end
    @test !HypertextTemplates._source_cache_writable()

    # Rendering now still reports a location, but must not leave the
    # pre-edit offset filed under the post-edit mtime.
    @test contains(render(), "data-htloc=")
    entry = get(HypertextTemplates.LINE_OFFSETS.entries, key, nothing)
    @test entry === nothing || entry[2] != mtime(path)

    Revise.revise()
    @test HypertextTemplates._source_cache_writable()
    @test reported(render()) == before + 5
end

@testitem "the template file lookup needs HTTP" tags = [:source] setup = [Templates] begin
    # The suite loads HTTP, so the extension covers `TemplateFileLookup`
    # itself. Reaching the fallback that reports the missing package means
    # calling past the extension's `Nothing` method.
    without_http() = HypertextTemplates._template_file_lookup(missing, identity)
    @test_throws ErrorException without_http()

    # Matching a message with `@test_throws` needs Julia 1.8, and 1.6 is
    # supported, so the text is read off the exception instead.
    caught = try
        without_http()
        nothing
    catch error
        error
    end
    @test occursin("`HTTP.jl`", string(caught))
end
