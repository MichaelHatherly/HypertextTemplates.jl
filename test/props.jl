@testitem "interpolated attributes" tags = [:props, :perf] setup = [Templates] begin
    using HypertextTemplates.Elements

    # Records the type of every property it is handed, so that the lazy form of
    # an interpolated attribute can be caught if it ever escapes to a component.
    observed_properties = Any[]
    @component function property_spy(; a = nothing, b = nothing)
        push!(observed_properties, (a = typeof(a), b = typeof(b)))
        @div {x = a}
    end
    @deftag macro property_spy end

    @component function property_forwarder(; a)
        @<property_spy {a = a}
    end
    @deftag macro property_forwarder end

    # An interpolated attribute keeps its pieces unjoined so that elements
    # can write them straight out. A component still has to receive the
    # joined `SafeString` it always has, and the lazy form must never reach
    # user code by any route.
    lazy = HypertextTemplates.InterpolatedAttribute
    index = 42
    extra = (; b = "plain")

    # No property may arrive as the lazy form, by any route.
    function properties(render)
        empty!(observed_properties)
        html = render()
        @test !occursin("InterpolatedAttribute", html)
        for entry in observed_properties, T in entry
            @test typeintersect(T, lazy) === Union{}
        end
        return observed_properties[1]
    end

    target = property_spy
    @test properties(() -> @render @property_spy {a = "/item/$index"}).a === SafeString
    @test properties(() -> @render @property_spy {a = "/x/$index", b = "/y/$index"}).b ===
        SafeString
    @test properties(() -> @render @property_spy {a = "/item/$index", extra...}).a ===
        SafeString
    @test properties(() -> @render @property_spy {extra..., a = "/item/$index"}).a ===
        SafeString
    @test properties(() -> @render @property_spy {a = "static"}).a === String
    @test properties(() -> @render @<target {a = "/item/$index"}).a === SafeString
    @test properties(() -> @render @property_forwarder {a = "/item/$index"}).a ===
        SafeString
    # `render` interpolates at its own call site, so the property arrives
    # as an ordinary string and never reaches the attribute machinery.
    @test properties(
        () -> HypertextTemplates.render(property_spy; a = "/item/$index"),
    ).a === String

    # Rendered output is exactly what joining eagerly produced. Source
    # locations are turned off, since Revise is loaded here.
    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end
    @test bare(io -> @render io @div {href = "/item/$index"}) ==
        "<div href=\"/item/42\"></div>"
    @test bare(io -> @render io @div {href = "/a/$index/b/$index"}) ==
        "<div href=\"/a/42/b/42\"></div>"
    @test bare(io -> @render io @div {t = "pre $(SafeString("<b>")) post"}) ==
        "<div t=\"pre <b> post\"></div>"
    @test bare(io -> @render io @div {t = "pre $("<i>") post"}) ==
        "<div t=\"pre &lt;i&gt; post\"></div>"
    @test bare(io -> @render io @div {t = "q$("\"'&<>")z"}) ==
        "<div t=\"q&quot;&#39;&amp;&lt;&gt;z\"></div>"
    @test bare(io -> @render io @div {t = "☃$(index)—"}) == "<div t=\"☃42—\"></div>"

    # The point of keeping the pieces unjoined is that elements stop
    # allocating for them, so that is what is asserted -- a test that only
    # checked the output would pass just as happily with the joining put
    # back.
    #
    # The comparison is against the same template with a plain dynamic
    # attribute, which isolates the interpolation from whatever else the
    # surrounding environment costs: under Revise, source tracking
    # allocates per element and would otherwise swamp the signal.
    function interpolated_rows(io, n)
        @render io @ul begin
            for i in 1:n
                @li @a {href = "/item/$i", class = "row"} $i
            end
        end
    end
    function plain_rows(io, n, href)
        @render io @ul begin
            for i in 1:n
                @li @a {href = href, class = "row"} $i
            end
        end
    end
    buffer = IOBuffer(sizehint = 1 << 20)
    located = IOContext(buffer, HypertextTemplates._include_data_htloc() => false)
    interpolated = steady_allocations(interpolated_rows, buffer, located, 200)
    plain = steady_allocations(plain_rows, buffer, located, 200, "/item/5")
    # Joining eagerly cost roughly 32KB across 800 extra allocations for
    # these 200 rows; keeping the pieces costs nothing over a plain value
    # from Julia 1.11, and well under what joining cost before that. See
    # `LAZY_ATTRIBUTE_BYTES`.
    @test interpolated <= plain + 1_000 + 200 * LAZY_ATTRIBUTE_BYTES
end

@testitem "merged opening tags" tags = [:props] setup = [Templates] begin
    using HypertextTemplates.Elements

    # An opening tag whose every part is known at compile time is written
    # as one constant rather than assembled from three writes. The merge
    # must produce exactly the same bytes, including for void elements,
    # elements with a doctype prefix, and elements carrying `true`/`false`
    # literal properties.
    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end
    @test bare(io -> @render io @div "x") == "<div>x</div>"
    @test bare(io -> @render io @div {class = "a"} "x") == "<div class=\"a\">x</div>"
    @test bare(io -> @render io @div {class = "a", id = "b"}) ==
        "<div class=\"a\" id=\"b\"></div>"
    @test bare(io -> @render io @br) == "<br>"
    @test bare(io -> @render io @img {src = "/a", alt = "b"}) ==
        "<img src=\"/a\" alt=\"b\">"
    @test bare(io -> @render io @html {lang = "en"} "x") ==
        "<!DOCTYPE html><html lang=\"en\">x</html>"
    @test bare(io -> @render io @div {hidden = true, disabled = false}) ==
        "<div hidden></div>"
    @test bare(io -> @render io @custom_element {prop = "v"} "x") ==
        "<custom-element prop=\"v\">x</custom-element>"
    # Escaping in a literal property survives the merge.
    @test bare(io -> @render io @div {t = "a<b>&\"c"}) ==
        "<div t=\"a&lt;b&gt;&amp;&quot;c\"></div>"
    # A merged run travels in a type parameter, which is a `Symbol` and so
    # cannot hold a NUL byte. Such an attribute is not valid HTML anyway,
    # but it used to render, so it has to keep rendering rather than fail
    # during macro expansion.
    @test bare(io -> @render io @div {t = "a\0b"} "x") == "<div t=\"a\0b\">x</div>"
    @test bare(io -> @render io @div {class = "c", t = "a\0b"}) ==
        "<div class=\"c\" t=\"a\0b\"></div>"

    dynamic = "d"
    @test bare(io -> @render io @div {class = "a", id = dynamic}) ==
        "<div class=\"a\" id=\"d\"></div>"
end

@testitem "how much of an opening tag is merged" tags = [:props] setup = [Templates] begin
    # What the merge is for is the number of writes, so that is what is
    # measured. Reference tests only see the bytes, and the whole path is
    # skipped while Revise is loaded -- which it is for this suite -- so the
    # merge is driven directly rather than through a render.
    mutable struct RecordingIO <: IO
        sink::IOBuffer
        writes::Vector{String}
        RecordingIO() = new(IOBuffer(), String[])
    end
    function Base.unsafe_write(io::RecordingIO, source::Ptr{UInt8}, n::UInt)
        push!(io.writes, unsafe_string(source, n))
        return unsafe_write(io.sink, source, n)
    end
    function Base.write(io::RecordingIO, byte::UInt8)
        push!(io.writes, string(Char(byte)))
        return write(io.sink, byte)
    end

    function merged(plan, props)
        io = RecordingIO()
        HypertextTemplates._write_open(io, Val(:div), plan, props)
        return String(take!(io.sink)), io.writes
    end

    static = HypertextTemplates.StaticProps{Symbol(" class=\"btn\"")}()
    dynamic = HypertextTemplates.DynamicProp{:id, Symbol(" id"), Symbol(" id=\"")}()

    # Nothing but the tag name, and a plan that is one literal run: the
    # whole opening tag, closing `>` included, is one constant.
    @test merged((), (;)) == ("<div>", ["<div>"])
    @test merged((static,), (;)) == ("<div class=\"btn\">", ["<div class=\"btn\">"])

    # A literal run before the first dynamic property joins the tag name,
    # and the properties that follow are written as they always were.
    html, writes = merged((static, dynamic), (; id = "x"))
    @test html == "<div class=\"btn\" id=\"x\">"
    @test first(writes) == "<div class=\"btn\""

    # With nothing literal to lead with there is nothing to merge, but the
    # bytes are the same either way.
    html, writes = merged((dynamic,), (; id = "x"))
    @test html == "<div id=\"x\">"
    @test first(writes) == "<div"

    # A literal run after a dynamic property cannot join anything, since
    # what precedes it is only known once the value is written.
    html, writes = merged((dynamic, static), (; id = "x"))
    @test html == "<div id=\"x\" class=\"btn\">"
    @test first(writes) == "<div"

    # However much of the tag gets merged, the bytes have to be the ones the
    # unmerged path writes. Reference tests cannot check this, since they run
    # with Revise loaded and Revise takes the unmerged path for every element.
    function unmerged(plan, props)
        io = IOBuffer()
        print(io, "<div")
        HypertextTemplates._render_plan(io, plan, props)
        print(io, ">")
        return String(take!(io))
    end
    flag = HypertextTemplates.DynamicProp{:hidden, Symbol(" hidden"), Symbol(" hidden=\"")}()
    quoted = HypertextTemplates.StaticProps{Symbol(" t=\"a&lt;b&quot;c\"")}()
    plans = (
        (),
        (static,),
        (quoted,),
        (static, quoted),
        (dynamic,),
        (static, dynamic),
        (dynamic, static),
        (static, dynamic, quoted),
        (flag, static),
    )
    props = (; id = "a\"<b", hidden = true)
    for plan in plans
        @test first(merged(plan, props)) == unmerged(plan, props)
    end
    # A property that is `false` renders nothing at all, merged or not.
    @test first(merged((static, flag), (; hidden = false))) ==
        unmerged((static, flag), (; hidden = false))
end

@testitem "components expand without a props plan" tags = [:props] setup = [Templates] begin
    using HypertextTemplates.Elements

    # `@deftag` splices the component or the element itself into the `@<`
    # call, so a call site written `@custom_component {...}` already knows at
    # expansion time which of the two it is calling. A component takes its
    # properties as keywords and never reads the plan, and building one anyway
    # made every distinct run of literal attributes a distinct type for
    # `_render_tag` to be specialised on.
    @test !HypertextTemplates._plans_props(custom_component)
    @test HypertextTemplates._plans_props(Elements.div)
    # A tag that only arrives with the render may still be an element.
    @test HypertextTemplates._plans_props(:tag_in_a_variable)

    @test !occursin(
        "StaticProps",
        string(@macroexpand @custom_component {prop = "literal"}),
    )
    @test occursin("StaticProps", string(@macroexpand @div {class = "literal"}))
    dynamic = custom_component
    @test occursin("StaticProps", string(@macroexpand @<dynamic {prop = "literal"}))
end
