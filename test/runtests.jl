import CommonMark
import HTTP
import Revise
using HypertextTemplates
using HypertextTemplates.Elements
import HypertextTemplates.Elements: @time
using ReferenceTests
using Test

module ExternalDefs

using HypertextTemplates

function markdown_component_ext end
@deftag macro markdown_component_ext end

end

# Turns off source locations in the rendered HTML such that the reference
# testing does not need to account for that variablity.
function render_test(f, file)
    io = IOBuffer()
    ctx = IOContext(io, HypertextTemplates._include_data_htloc() => false)
    f(ctx)
    @test_reference(file, String(take!(io)))
end

@element "custom-element" custom_element
@deftag macro custom_element end

# Values used to check how arbitrary objects are escaped: one whose `show`
# emits every character that needs escaping, and one that inspects the stream
# it is printed to.
struct ShowsAngles end
Base.show(io::IO, ::ShowsAngles) = print(io, "<&\"'>")
const shows_angles = ShowsAngles()

struct ContextSensitive end
Base.show(io::IO, ::ContextSensitive) =
    print(io, get(io, :compact, false) ? "compact" : "full")
const context_sensitive = ContextSensitive()

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

@component function custom_component(; prop)
    @div {class = prop, id = 1} begin
        @p @text "component content"
        @p "The prop value is: " $prop
    end
end
@deftag macro custom_component end

@component function nested_component(; prop, captured)
    @component function inner_component(; prop)
        @p {class = captured, id = prop} "content"
    end
    @div {class = prop} @<inner_component {prop = "inner"}
end
@deftag macro nested_component end

@component function slot_component()
    @div begin
        @__slot__
        @__slot__ named
    end
end
@deftag macro slot_component end

@component function conditional_component(; show)
    if show
        @p "shown"
    else
        @strong "hidden"
    end
end
@deftag macro conditional_component end

@component function commonmark_component()
    here = "there"
    @div {class = "prose"} @text CommonMark.cm"""
    # *Header*

    > Some `code` goes [$here](/link).

    ```julia
    a = 1
    ```
    """
end
@deftag macro commonmark_component end

@cm_component markdown_component(; x) = joinpath(@__DIR__, "markdown.md")
@deftag macro markdown_component end

@cm_component ExternalDefs.markdown_component_ext(; x) = joinpath(@__DIR__, "markdown.md")

@component function streaming(; n::Integer)
    @div {class = "streamed"} begin
        @ul begin
            for id = 1:n
                @li {id} "This is item $id."
            end
        end
    end
end
@deftag macro streaming end

@component function once_jquery()
    @__once__ begin
        @script {src = "https://code.jquery.com/jquery-3.6.0.min.js"}
    end
end
@deftag macro once_jquery end

@component function once_button()
    @once_jquery
    @button "Click Me"
end
@deftag macro once_button end

@component function once_page()
    @html begin
        @head begin
            @once_jquery
        end
        @body begin
            @h1 "Hello, World!"
            @once_button
        end
    end
end
@deftag macro once_page end

@testset "HypertestTemplates" begin
    @testset "Basics" begin
        render_test("references/basics/html-elements.txt") do io
            @render io @html {lang = "en"} begin
                @head begin
                    @meta {charset = "UTF-8"}
                    @meta {name = "viewport", content = "width=device-width"}
                    @title "Document title"
                end
                @body begin
                    @header begin
                        @a {href = "#", class = "logo"} "Page Header"
                    end
                    @article begin
                        @header begin
                            @h1 "Article Title"
                            @time "01/01/2000"
                        end
                        # Test that `@text` works on non-string-literals.
                        content = "Content goes here."
                        @p @text content
                    end
                end
            end
        end
        render_test("references/basics/prop_names.txt") do io
            # Supports both `=` and `:=` as property syntax since literal strings
            # raise warnings in LSPs, but we want to use the string syntax to support
            # property names that are not valid Julia syntax.
            @render io @div {"data-custom-prop" := true, hidden_prop = false}
        end
        render_test("references/basics/attribute-escaping.txt") do io
            # Literal strings are always marked as safe and are not
            # escaped. Anything that is added to an element as a variable,
            # that is potentially user-provided is escaped.
            class = "<script></script>"
            pre_escaped = SafeString("<script></script>")
            unsafe = "\"'"
            @render io @div {
                unsafe,
                class,
                unescaped = "<script></script>",
                pre = pre_escaped,
                interpolated = "\"$("\"")",
            }
        end
        render_test("references/basics/custom-elements.txt") do io
            @render io @div begin
                @custom_element {prop = "value"} begin
                    @strong "content"
                end
            end
        end
        render_test("references/basics/looping.txt") do io
            @render io @ul begin
                for each in [1, 2, 3, 4]
                    @li {id = each} @text each
                end
            end
        end
        render_test("references/basics/custom-components.txt") do io
            @render io @custom_component {prop = "class-name"}
        end
        render_test("references/basics/nested-custom-components.txt") do io
            @render io @nested_component {prop = "class-name", captured = "captured"}
        end
        render_test("references/basics/component-slots.txt") do io
            @render io @slot_component begin
                named := @p "named slot content"
                @p "slot content"
            end
        end
        render_test("references/basics/conditional-component.txt") do io
            @render io @div begin
                @conditional_component {show = true}
                @conditional_component {show = false}
            end
        end
        render_test("references/basics/commonmark-component.txt") do io
            @render io @commonmark_component
        end
        render_test("references/basics/non-standard-prop-names.txt") do io
            @render io @div {"x-data" := "{ open: false }"} begin
                @button {"@click" := "open = true"} "Expand"
                @span {"x-show" := "open"} "Content..."
            end
        end
        render_test("references/basics/once-button-1.txt") do io
            @render io @once_button
        end
        render_test("references/basics/once-button-2.txt") do io
            @render io begin
                @once_button
                @once_button
            end
        end
        render_test("references/basics/once-page.txt") do io
            @render io @once_page
        end
    end
    @testset "Markdown" begin
        render_test("references/markdown/markdown.txt") do io
            @render io @markdown_component {x = 1}
        end
        render_test("references/markdown/markdown-ext.txt") do io
            @render io ExternalDefs.@markdown_component_ext {x = 1}
        end
    end
    @testset "Render Root" begin
        function render_function()
            @__LINE__, @render @div begin
                @conditional_component {show = true}
                @conditional_component {show = false}
            end
        end
        line, html = render_function()
        @test contains(html, "data-htroot=\"$(@__FILE__):$(line)")
        @test contains(html, "data-htloc=\"$(@__FILE__):$(line)")
    end
    @testset "Output Types" begin
        result = @render @p "content"
        @test isa(result, String)
        result_bytes = @render Vector{UInt8} @p "content"
        @test isa(result_bytes, Vector{UInt8})
    end
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
    @testset "Escaping Arbitrary Values" begin
        # Values that are neither strings, numbers nor characters are escaped
        # as they print, rather than being turned into a string first. The
        # result has to match what escaping `string(value)` produced.
        reference(escaper, value) = sprint(escaper, string(value))
        for value in Any[
            :sym,
            :var"weird<sym>&\"'",
            nothing,
            missing,
            3//4,
            1+2im,
            ["<a>", "&b", "\"c\"", "'d'"],
            (a = 1, b = "<x>"),
            Dict(:a => "<v>"),
            1:5,
            Int,
            Vector{Int},
            Some("<x>"),
            big(2)^70,
            Int128(-5),
        ]
            @test sprint(HypertextTemplates.escape_html, value) ==
                  reference(HypertextTemplates.escape_html, value)
            @test sprint(HypertextTemplates.escape_attr, value) ==
                  reference(HypertextTemplates.escape_attr, value)
        end

        # A value whose `show` inspects the stream must see what it saw when it
        # was rendered into a bare buffer, so the wrapper must not forward the
        # surrounding `IOContext`.
        buffer = IOBuffer()
        HypertextTemplates.escape_html(
            IOContext(buffer, :compact => true),
            context_sensitive,
        )
        @test String(take!(buffer)) == "full"

        # Rendered without source locations, which Revise would otherwise add.
        function plain(f)
            io = IOBuffer()
            f(IOContext(io, HypertextTemplates._include_data_htloc() => false))
            return String(take!(io))
        end
        @test plain(io -> @render io @div $(:sym)) == "<div>sym</div>"
        @test plain(io -> @render io @div {id = :sym}) == "<div id=\"sym\"></div>"
        @test plain(io -> @render io @div $(shows_angles)) == "<div>&lt;&amp;\"'&gt;</div>"
        @test plain(io -> @render io @div {t = shows_angles}) ==
              "<div t=\"&lt;&amp;&quot;&#39;&gt;\"></div>"
    end
    @testset "Source Information" begin
        line = @__LINE__
        file = @__FILE__
        result = @render @p "content"
        @test contains(result, "data-htloc=\"$file:$(line + 2)\"")
    end
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
    @testset "Streaming" begin
        func(io = Vector{UInt8}) = @render io @streaming {n = 10000}
        output = UInt8[]
        for bytes in StreamingRender(func)
            @assert !isempty(bytes)
            append!(output, bytes)
        end
        @test length(output) > 1
        @test output == func()

        # `StreamingRender` hands the writer to the caller's function, so
        # writing to it directly has to work. A `write(::MicroBatchWriter,
        # ::AbstractString)` method used to make these ambiguous against
        # `Base`, turning every one of them into a `MethodError`.
        @test isempty(Test.detect_ambiguities(HypertextTemplates; recursive = true))
        channel = Channel{Vector{UInt8}}(64)
        writer = HypertextTemplates.MicroBatchWriter(channel)
        @test write(writer, "hello") == 5
        @test write(writer, SubString("hello world", 1, 5)) == 5
        @test write(writer, UInt8[1, 2, 3]) == 3
        @test write(writer, codeunits("abc")) == 3
        @test write(writer, 0x41) == 1
        @test print(writer, "text", 42, 'x') === nothing
        # Above `immediate_threshold`, so it bypasses the buffer.
        @test print(writer, repeat("x", 100)) === nothing

        # Everything written to the writer must come back out in order.
        function raw(io)
            write(io, "<p>")
            print(io, "a", 1, 'b')
            write(io, SubString("--tail--", 3, 6))
            print(io, repeat("z", 200))
            write(io, "</p>")
        end
        collected = UInt8[]
        for bytes in StreamingRender(raw)
            append!(collected, bytes)
        end
        @test String(collected) == "<p>a1btail" * repeat("z", 200) * "</p>"
    end
    @testset "Macro Hygiene" begin
        # The macro that `@deftag` generates is defined in, and expands in, the
        # caller's module, so a caller that defines a binding named `esc`,
        # `Expr`, `GlobalRef` or `Symbol` used to break every tag macro in
        # their module. Importing the package under another name, without
        # `using` it, used to fail for the same reason.
        cases = [
            "esc" => """
                module HygieneEsc
                using HypertextTemplates, HypertextTemplates.Elements
                esc = "shadowed"
                @component function w(; n)
                    @div \$n
                end
                @deftag macro w end
                run() = @render @w {n = 1}
                end
                HygieneEsc.run()
            """,
            "Expr" => """
                module HygieneExpr
                using HypertextTemplates, HypertextTemplates.Elements
                Expr = "shadowed"
                @component function w(; n)
                    @div \$n
                end
                @deftag macro w end
                run() = @render @w {n = 1}
                end
                HygieneExpr.run()
            """,
            "GlobalRef" => """
                module HygieneGlobalRef
                using HypertextTemplates, HypertextTemplates.Elements
                GlobalRef = "shadowed"
                @component function w(; n)
                    @div \$n
                end
                @deftag macro w end
                run() = @render @w {n = 1}
                end
                HygieneGlobalRef.run()
            """,
            "Symbol" => """
                module HygieneSymbol
                using HypertextTemplates, HypertextTemplates.Elements
                Symbol = "shadowed"
                @component function w(; n)
                    @div \$n
                end
                @deftag macro w end
                run() = @render @w {n = 1}
                end
                HygieneSymbol.run()
            """,
        ]
        for (shadowed, code) in cases
            @testset "shadowed `$shadowed`" begin
                @test include_string(Main, code) == "<div>1</div>"
            end
        end
        # `@element` goes through the same code path as `@component`.
        @test include_string(
            Main,
            """
            module HygieneElement
            using HypertextTemplates
            esc = "shadowed"
            @element "my-widget" my_widget
            @deftag macro my_widget end
            run() = @render @my_widget {id = "a"} "x"
            end
            HygieneElement.run()
            """,
        ) == "<my-widget id=\"a\">x</my-widget>"
        # The package need not be in scope under its own name.
        @test include_string(
            Main,
            """
            module HygieneRenamed
            import HypertextTemplates as HTT
            import HypertextTemplates.Elements as E
            HTT.@component function w(; n)
                E.@div \$n
            end
            HTT.@deftag macro w end
            run() = HTT.@render @w {n = 1}
            end
            HygieneRenamed.run()
            """,
        ) == "<div>1</div>"
    end
end
