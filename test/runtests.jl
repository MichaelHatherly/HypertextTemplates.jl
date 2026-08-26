import CommonMark
import HTTP
import Random
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

# Julia stack allocates the temporaries the render path relies on only from
# 1.11, where escape analysis can see that they never leave the function.
# Before that the escapers' scratch buffer costs a fixed 16 or 32 bytes a call,
# and the lazy attribute wrapper costs a couple of hundred bytes an element.
#
# Both are constants -- per call and per element -- rather than costs per byte,
# so the invariants the allocation tests exist to protect still hold on those
# versions: escaping neither allocates per character nor copies its input, and
# an interpolated attribute is still much cheaper than joining it eagerly was
# (measured on 1.6, 204 bytes an element against 335). The totals simply are
# not zero there, so they are bounded by these constants instead, which from
# 1.11 on are zero and the assertions stay exact.
const SCRATCH_BYTES = VERSION >= v"1.11" ? 0 : 64
const LAZY_ATTRIBUTE_BYTES = VERSION >= v"1.11" ? 0 : 256

# The obvious escaper, character by character, to check the byte-scanning one
# against. Written out rather than expressed as `replace(subject, "&" =>
# "&amp;", ...)`, since `replace` only takes more than one pair from Julia 1.7.
function reference_escape(subject::AbstractString; attribute::Bool)
    io = IOBuffer()
    for character in subject
        if character == '&'
            print(io, "&amp;")
        elseif character == '<'
            print(io, "&lt;")
        elseif character == '>'
            print(io, "&gt;")
        elseif attribute && character == '"'
            print(io, "&quot;")
        elseif attribute && character == '\''
            print(io, "&#39;")
        else
            print(io, character)
        end
    end
    return String(take!(io))
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

# Long enough to cross the escaping block boundary several times, so that
# arbitrary values go through the same blocked path the string escapers use.
struct ShowsLongMixed end
Base.show(io::IO, ::ShowsLongMixed) = print(io, repeat("a<b>&c\"d'e ", 200))
const shows_long_mixed = ShowsLongMixed()

struct ShowsLongPlain end
Base.show(io::IO, ::ShowsLongPlain) = print(io, repeat("plain text here ", 200))
const shows_long_plain = ShowsLongPlain()

# A stream whose write yields before it takes the bytes, the way a socket's
# does while it waits on the network. A float's digits are generated into a
# buffer shared by every render on the thread, so anything still pointing at
# that buffer when the stream yields can have another render's number
# underneath it by the time the write resumes.
struct YieldingSink <: IO
    inner::IOBuffer
end
YieldingSink() = YieldingSink(IOBuffer())
function Base.unsafe_write(sink::YieldingSink, pointer::Ptr{UInt8}, n::UInt)
    yield()
    return unsafe_write(sink.inner, pointer, n)
end
Base.write(sink::YieldingSink, byte::UInt8) = write(sink.inner, byte)
Base.take!(sink::YieldingSink) = take!(sink.inner)

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
    @testset "Render Buffer" begin
        # The sink `@render` builds for itself. It replaces `IOBuffer`, so it
        # has to behave like one for everything a render does to it.
        RenderBuffer = HypertextTemplates.RenderBuffer

        buffer = RenderBuffer()
        @test position(buffer) == 0
        @test take!(buffer) == UInt8[]

        # Writes of every shape, and the growth boundary crossed repeatedly.
        for total in (0, 1, 63, 64, 65, 127, 128, 1000, 100_000)
            reference = IOBuffer()
            buffer = RenderBuffer()
            written = 0
            piece = 1
            while written < total
                count = min(piece, total - written)
                chunk = repeat("ab", count)[1:count]
                print(reference, chunk)
                print(buffer, chunk)
                written += count
                piece = piece == 17 ? 1 : piece + 1
            end
            @test position(buffer) == total
            @test take!(buffer) == take!(reference)
        end

        # Single bytes, mixed with block writes.
        reference = IOBuffer()
        buffer = RenderBuffer()
        for index = 1:300
            if iseven(index)
                write(reference, UInt8(index % 256))
                write(buffer, UInt8(index % 256))
            else
                print(reference, "chunk-$index/")
                print(buffer, "chunk-$index/")
            end
        end
        @test take!(buffer) == take!(reference)

        # `take!` hands the bytes over and leaves an empty buffer behind.
        buffer = RenderBuffer()
        print(buffer, "first")
        @test String(take!(buffer)) == "first"
        @test position(buffer) == 0
        print(buffer, "second")
        @test String(take!(buffer)) == "second"

        # A size hint is a hint, not a limit.
        buffer = RenderBuffer(4)
        print(buffer, repeat("x", 500))
        @test String(take!(buffer)) == repeat("x", 500)

        # Non-ASCII goes through unchanged: the sink deals in bytes.
        buffer = RenderBuffer()
        print(buffer, "héllo — ☃")
        @test String(take!(buffer)) == "héllo — ☃"

        # And it is what a destination-less render actually uses.
        @test HypertextTemplates._render_dst(String) isa RenderBuffer
        @test HypertextTemplates._render_dst(Vector{UInt8}) isa RenderBuffer
        supplied = IOBuffer()
        @test HypertextTemplates._render_dst(supplied) === supplied

        # Renders that grow past the initial capacity must still be exact.
        big = @render @ul begin
            for index = 1:2000
                @li {class = "row", "data-index" := index} "item $index & more"
            end
        end
        @test length(big) > 100_000
        @test count("<li ", big) == 2000
        @test occursin("&amp; more", big)
        @test endswith(big, "</ul>")
        # The `Vector{UInt8}` destination uses the same sink. Its source
        # location differs from the render above, so it is checked on its own
        # rather than compared byte for byte.
        bytes = @render Vector{UInt8} @ul begin
            for index = 1:2000
                @li {class = "row", "data-index" := index} "item $index & more"
            end
        end
        @test bytes isa Vector{UInt8}
        @test count("<li ", String(bytes)) == 2000
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
        # these 200 rows; keeping the pieces costs nothing over a plain value
        # from Julia 1.11, and well under what joining cost before that. See
        # `LAZY_ATTRIBUTE_BYTES`.
        @test interpolated <= plain + 1_000 + 200 * LAZY_ATTRIBUTE_BYTES
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
    @testset "Escaping Blocks" begin
        # Escaped output is assembled in a fixed stack buffer and handed over a
        # block at a time. The buffer must never escape to the heap, or the
        # scan would allocate on every string rendered.
        struct DiscardingSink <: IO end
        Base.unsafe_write(::DiscardingSink, ::Ptr{UInt8}, n::UInt) = Int(n)
        Base.write(::DiscardingSink, byte::UInt8) = 1
        sink = DiscardingSink()

        subjects = [
            "" => "empty",
            "hi" => "short plain",
            "a<b>&c" => "short mixed",
            repeat("abc ", 400) => "long plain",
            repeat("a<b>&c ", 250) => "long mixed",
            repeat("<", 1000) => "nothing but escapes",
            repeat("héllo ☃ ", 100) => "unicode",
            "\"'&<>" => "every escapable character",
        ]
        for (subject, _) in subjects
            HypertextTemplates.escape_html(sink, subject)
            HypertextTemplates.escape_attr(sink, subject)
        end
        function repeatedly(escaper, subject, n)
            for _ = 1:n
                escaper(sink, subject)
            end
        end
        for (subject, name) in subjects
            repeatedly(HypertextTemplates.escape_html, subject, 3)
            repeatedly(HypertextTemplates.escape_attr, subject, 3)
            # Zero on 1.11 and later; see `SCRATCH_BYTES`. The bound is a
            # constant per call either way, so growing the subject must not
            # grow the total.
            budget = 500 * SCRATCH_BYTES
            @testset "$name" begin
                @test (@allocated repeatedly(
                    HypertextTemplates.escape_html,
                    subject,
                    500,
                )) <= budget
                @test (@allocated repeatedly(
                    HypertextTemplates.escape_attr,
                    subject,
                    500,
                )) <= budget
            end
        end

        # The scan for the first escapable byte reads eight bytes at a time,
        # after a prologue that walks to an eight-byte boundary. So an escapable
        # character has to be found at every position, at every length spanning
        # several words, and at every pointer alignment -- which substrings
        # provide, since their data begins at an arbitrary offset.
        for length = 0:40
            filler = repeat("x", length)
            @test sprint(HypertextTemplates.escape_html, filler) == filler
            for position = 1:length,
                (character, entity) in ("&" => "&amp;", "<" => "&lt;", ">" => "&gt;")

                subject = filler[1:(position-1)] * character * filler[(position+1):end]
                expected = filler[1:(position-1)] * entity * filler[(position+1):end]
                @test sprint(HypertextTemplates.escape_html, subject) == expected
                # The same bytes reached through a substring, so the scan sees
                # a pointer that is not eight-byte aligned.
                padded = "abcde" * subject
                for offset = 1:6
                    view = SubString(padded, offset)
                    @test sprint(HypertextTemplates.escape_html, view) ==
                          sprint(HypertextTemplates.escape_html, String(view))
                end
            end
        end
        # Attribute escaping looks for two more characters, so it gets the same
        # treatment at the lengths where words and boundaries interact.
        for length in (7, 8, 9, 15, 16, 17, 23, 24, 25)
            for position = 1:length, character in ("\"", "'", "&", "<", ">")
                subject =
                    repeat("y", position - 1) * character * repeat("y", length - position)
                @test sprint(HypertextTemplates.escape_attr, subject) ==
                      reference_escape(subject; attribute = true)
            end
        end

        # A block boundary must not corrupt output, so check lengths either
        # side of it, including where an entity would straddle the edge.
        for length in [
            HypertextTemplates.ESCAPE_BLOCK .+ (-3:3)...,
            2 * HypertextTemplates.ESCAPE_BLOCK,
        ]
            for filler in ("x", "<", "&", "\"")
                subject = repeat(filler, length)
                @test sprint(HypertextTemplates.escape_html, subject) ==
                      reference_escape(subject; attribute = false)
                @test sprint(HypertextTemplates.escape_attr, subject) ==
                      reference_escape(subject; attribute = true)
            end
        end
    end
    @testset "Once Blocks" begin
        # An `IOContext` hands its properties back as `Any`, so the set behind
        # `@__once__` has to be asserted back to its real type or every
        # membership test becomes a dynamic dispatch that boxes -- an
        # allocation on every `@__once__`, including the common case where the
        # key is already present and nothing is rendered.
        function repeated(io, n)
            @render io @div begin
                for _ = 1:n
                    @once_button
                end
            end
        end
        function unrepeated(io, n)
            @render io @div begin
                for _ = 1:n
                    @button "Click Me"
                end
            end
        end
        buffer = IOBuffer(sizehint = 1 << 20)
        located = IOContext(buffer, HypertextTemplates._include_data_htloc() => false)
        repeated(located, 5)
        unrepeated(located, 5)
        take!(buffer)
        # The script is emitted once however many times the component appears.
        repeated(located, 200)
        rendered = String(take!(buffer))
        @test count("jquery-3.6.0.min.js", rendered) == 1
        @test count("Click Me", rendered) == 200

        # The membership test itself is what had to stop allocating, so it is
        # measured directly rather than inferred from a whole render, where
        # component overhead and output size would blur the signal.
        context = IOContext(IOBuffer(), HypertextTemplates._once_ref())
        HypertextTemplates._add_once_key!(context, :already_present)
        function probe(io, n)
            found = 0
            for _ = 1:n
                HypertextTemplates._missing_once_key(io, :already_present) && (found += 1)
            end
            return found
        end
        probe(context, 5)
        @test probe(context, 10) == 0
        @test (@allocated probe(context, 1_000)) == 0
    end
    @testset "Interpolated Text" begin
        # An interpolated string of two or more pieces is written piece by
        # piece rather than joined first. Joining flattened any `SafeString`
        # among the pieces into ordinary text, so the pieces have to be
        # flattened the same way -- and a single-piece string, where `string`
        # can pass a `SafeString` through untouched, is left alone.
        safe = SafeString("<b>bold</b>")
        angles = "<i>&\"'"
        index = 42

        function bare(render)
            io = IOBuffer()
            render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
            return String(take!(io))
        end

        # Two or more pieces: the safe value is flattened and escaped.
        @test bare(io -> @render io @div "s=$safe") ==
              "<div>s=&lt;b&gt;bold&lt;/b&gt;</div>"
        @test bare(io -> @render io @div "$(safe)!") ==
              "<div>&lt;b&gt;bold&lt;/b&gt;!</div>"
        # A single piece: the safe value passes through, as it always has.
        @test bare(io -> @render io @div "$safe") == "<div><b>bold</b></div>"
        @test bare(io -> @render io @div $safe) == "<div><b>bold</b></div>"

        @test bare(io -> @render io @div "x=$angles") == "<div>x=&lt;i&gt;&amp;\"'</div>"
        @test bare(io -> @render io @div "<$index>") == "<div>&lt;42&gt;</div>"
        @test bare(io -> @render io @div "a<b> $index") == "<div>a&lt;b&gt; 42</div>"
        @test bare(io -> @render io @div "$index-$angles-$index") ==
              "<div>42-&lt;i&gt;&amp;\"'-42</div>"
        @test bare(io -> @render io @div "☃$(index)—") == "<div>☃42—</div>"
        @test bare(io -> @render io @div @text "n=$index") == "<div>n=42</div>"
        @test bare(io -> @render io @div "no interpolation") ==
              "<div>no interpolation</div>"

        # And writing the pieces separately is what removes the allocations, so
        # that is asserted too rather than only the output.
        #
        # The comparison is against a template with no interpolation but output
        # of the same length, since allocation here is driven by how far the
        # buffer has to grow. Comparing against a template that simply prints
        # less would measure the output size, not the interpolation.
        function interpolated_paragraphs(io, n)
            @render io @div begin
                for i = 1:n
                    @p "ab$i"
                end
            end
        end
        function literal_paragraphs(io, n)
            @render io @div begin
                for _ = 1:n
                    @p "abcd"
                end
            end
        end
        buffer = IOBuffer(sizehint = 1 << 20)
        located = IOContext(buffer, HypertextTemplates._include_data_htloc() => false)
        interpolated_paragraphs(located, 5)
        literal_paragraphs(located, 5)
        take!(buffer)
        interpolated = @allocated interpolated_paragraphs(located, 200)
        take!(buffer)
        literal = @allocated literal_paragraphs(located, 200)
        take!(buffer)
        # Joining first cost roughly 7 extra allocations per element. The
        # interpolated form makes one more escaping call per paragraph than the
        # literal one, which before Julia 1.11 is a fixed cost each; see
        # `SCRATCH_BYTES`.
        @test interpolated <= literal + 1_000 + 200 * SCRATCH_BYTES
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
            shows_angles,
            shows_long_mixed,
            shows_long_plain,
        ]
            @test sprint(HypertextTemplates.escape_html, value) ==
                  reference(HypertextTemplates.escape_html, value)
            @test sprint(HypertextTemplates.escape_attr, value) ==
                  reference(HypertextTemplates.escape_attr, value)
        end

        # A number is written straight out, without being scanned, since its
        # printed form cannot need escaping. It has to come out exactly as
        # `print` would render it, at every width and at the boundaries where
        # the digit by digit writer is easiest to get wrong.
        for value in Any[
            Int8(-8),
            Int16(-16),
            Int32(-32),
            Int64(-64),
            Int128(-128),
            UInt8(8),
            UInt16(16),
            UInt32(32),
            UInt64(64),
            UInt128(128),
            true,
            false,
            Float16(1.5),
            Float32(-2.5),
            1.0e10,
            big(2)^70,
            big"1.5",
            typemin(Int64),
            typemax(UInt64),
        ]
            @test sprint(HypertextTemplates.escape_html, value) == string(value)
            @test sprint(HypertextTemplates.escape_attr, value) == string(value)
        end

        # `Float16`, `Float32` and `Float64` do not go through `print` at all.
        # `print` asks `Base.Ryu` for the digits and lets it allocate a fresh
        # buffer to put them in every time; the same call is made against a
        # buffer the package already owns instead. That means restating the
        # formatting arguments `show` passes on the way through, which are
        # `Base`'s to change, so the result is checked against `print` itself
        # across every `Float16` that exists and a wide sample of the two
        # wider types -- not at a handful of hand-picked values, which would
        # not notice a changed threshold between plain and exponent form.
        function first_float_mismatch(values)
            for value in values
                expected = sprint(print, value)
                sprint(HypertextTemplates.escape_html, value) == expected || return value
                sprint(HypertextTemplates.escape_attr, value) == expected || return value
            end
            return nothing
        end

        @test first_float_mismatch(
            reinterpret(Float16, bits) for bits = typemin(UInt16):typemax(UInt16)
        ) === nothing

        rng = Random.MersenneTwister(20260826)
        sampled = Any[
            0.0,
            -0.0,
            1.0,
            -1.0,
            0.1,
            floatmin(Float64),
            floatmax(Float64),
            eps(Float64),
            5.0e-324,
            1.0e16,
            1.0e17,
            Inf,
            -Inf,
            NaN,
            Float32(0.1),
            Float32(1.0f10),
            floatmin(Float32),
            floatmax(Float32),
            Float32(Inf),
            Float32(NaN),
        ]
        for _ = 1:5_000
            push!(sampled, reinterpret(Float32, rand(rng, UInt32)))
            push!(sampled, reinterpret(Float64, rand(rng, UInt64)))
            push!(sampled, randn(rng) * 10.0^rand(rng, -308:308))
            push!(sampled, Float32(randn(rng) * 10.0f0^rand(rng, -38:38)))
        end
        @test first_float_mismatch(sampled) === nothing

        # And the point of owning the buffer: writing a float costs nothing.
        function write_floats(io, n)
            for index = 1:n
                HypertextTemplates.escape_html(io, index * 1.5)
                HypertextTemplates.escape_attr(io, index / 7)
            end
            return nothing
        end
        # Pre-grown, so that what is measured is the writing and not the sink.
        sink = IOBuffer(sizehint = 1 << 16)
        write_floats(sink, 10)
        truncate(sink, 0)
        seek(sink, 0)
        floats = @allocated write_floats(sink, 1_000)
        truncate(sink, 0)
        seek(sink, 0)
        @test floats == 0

        # The buffer holding the digits is shared by every render on the
        # thread, so they are copied out before the stream is handed them: a
        # stream that yields mid-write must not be able to pick up another
        # render's number. Without the copy the interleaved tasks below hand
        # each other their digits and the reads come back wrong.
        concurrent = [index * 1.0e-3 for index = 1:64]
        running = Task[]
        for value in concurrent
            push!(
                running,
                Threads.@spawn(begin
                    stream = YieldingSink()
                    for _ = 1:32
                        HypertextTemplates.escape_html(stream, $(value))
                    end
                    String(take!(stream))
                end)
            )
        end
        @test all(
            fetch(task) == repeat(sprint(print, value), 32) for
            (value, task) in zip(concurrent, running)
        )

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
        extension = revise_extension()
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
        cache = extension.SITES.entries
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
        for i = 1:(extension.SITES.limit+50)
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

        # Flushing a batch must not cost the buffer its capacity. `take!` hands
        # the internal array to the channel and installs a fresh empty one, so
        # the buffer would regrow from nothing on every cycle -- several
        # reallocations per flush, and a flush happens every few hundred bytes.
        sink = Channel{Vector{UInt8}}(64)
        batcher = HypertextTemplates.MicroBatchWriter(sink)
        # Each piece has to stay under `immediate_threshold`, or it bypasses
        # the buffer entirely and there is nothing to keep.
        piece = repeat("x", 40)
        for _ = 1:5
            write(batcher, piece)
        end
        flush(batcher)
        @test String(take!(sink)) == repeat(piece, 5)
        grown = length(batcher.buffer.data)
        @test grown >= 200
        write(batcher, "y")
        flush(batcher)
        @test String(take!(sink)) == "y"
        @test length(batcher.buffer.data) >= grown

        # Which is to say repeated flushes stay flat rather than paying to
        # regrow each time.
        function cycles(writer, channel, n)
            for _ = 1:n
                write(writer, "a short batch of text")
                flush(writer)
                take!(channel)
            end
        end
        cycles(batcher, sink, 5)
        @test (@allocated cycles(batcher, sink, 100)) < 100 * 150

        # The write path no longer reads the clock, which leaves the flush
        # timer as the only thing bounding latency. So check it directly: a
        # producer that emits a little and then stalls must have that little
        # delivered while it is still stalled, not once it finishes.
        function stalling(io)
            @render io @div begin
                @span "a"
                sleep(0.25)
                @span "b"
                sleep(0.25)
                @span "c"
            end
        end
        function quick(io)
            @render io @div begin
                @span "a"
                @span "b"
                @span "c"
            end
        end
        # Warm up first: compiling the render, the iterator and this loop body
        # would otherwise be charged to the first chunk's arrival.
        collect(StreamingRender(quick))
        collect(StreamingRender(stalling))
        started = Base.time()
        arrivals = Tuple{Float64,String}[]
        for chunk in StreamingRender(stalling)
            push!(arrivals, (Base.time() - started, String(copy(chunk))))
        end
        @test join(last.(arrivals)) == sprint(stalling)
        # The producer runs for about half a second. Anything under a tenth of
        # that means the timer flushed while it was asleep rather than the
        # bytes waiting for it to return.
        @test first(first(arrivals)) < 0.05
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
        # `@cm_component` expands into the caller's module too, and names
        # `Symbol`, `read`, `String`, `Val` and `joinpath` in what it generates.
        markdown = joinpath(mktempdir(), "hygiene.md")
        write(markdown, "# Heading\n\nSome *prose* with \$value in it.\n")
        for (index, assignment) in enumerate([
            "Symbol = \"shadowed\"",
            "read = \"shadowed\"",
            "String = \"shadowed\"",
            "Val = \"shadowed\"",
            "joinpath = \"shadowed\"",
        ])
            rendered = include_string(
                Main,
                """
                module CmHygiene$(index)
                using HypertextTemplates, HypertextTemplates.Elements
                $(assignment)
                @cm_component page(; value) = raw"$(markdown)"
                @deftag macro page end
                run() = @render @page {value = "v"}
                end
                CmHygiene$(index).run()
                """,
            )
            @test occursin("Heading", rendered)
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
end
