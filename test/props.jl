# Records the type of every property it is handed, so that the lazy form of an
# interpolated attribute can be caught if it ever escapes to a component.
const observed_properties = Any[]
@component function property_spy(; a = nothing, b = nothing)
    push!(observed_properties, (a = typeof(a), b = typeof(b)))
    @div {x = a}
end
@deftag macro property_spy end

@component function property_forwarder(; a)
    @<property_spy {a = a}
end
@deftag macro property_forwarder end

@testset "Interpolated Attributes" begin
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
            for i = 1:n
                @li @a {href = "/item/$i", class = "row"} $i
            end
        end
    end
    function plain_rows(io, n, href)
        @render io @ul begin
            for i = 1:n
                @li @a {href = href, class = "row"} $i
            end
        end
    end
    buffer = IOBuffer(sizehint = 1 << 20)
    located = IOContext(buffer, HypertextTemplates._include_data_htloc() => false)
    interpolated_rows(located, 5)
    plain_rows(located, 5, "/item/5")
    take!(buffer)
    interpolated = @allocated interpolated_rows(located, 200)
    take!(buffer)
    plain = @allocated plain_rows(located, 200, "/item/5")
    take!(buffer)
    # Joining eagerly cost roughly 32KB across 800 extra allocations for
    # these 200 rows; keeping the pieces costs nothing over a plain value.
    @test interpolated <= plain + 1_000
end

@testset "Merged Opening Tags" begin
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

    # Only fully-literal plans merge; anything dynamic keeps the old path.
    @test HypertextTemplates._mergeable_plan(Tuple{})
    @test HypertextTemplates._mergeable_plan(
        Tuple{HypertextTemplates.StaticProps{Symbol(" a=\"b\"")}},
    )
    @test !HypertextTemplates._mergeable_plan(
        Tuple{HypertextTemplates.DynamicProp{:a,Symbol(" a"),Symbol(" a=\"")}},
    )
    @test !HypertextTemplates._mergeable_plan(Nothing)
    dynamic = "d"
    @test bare(io -> @render io @div {class = "a", id = dynamic}) ==
          "<div class=\"a\" id=\"d\"></div>"
end
