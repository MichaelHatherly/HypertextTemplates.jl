# Sinks and values that the escaping tests measure the escapers against.
@testmodule Escapes begin

    export YieldingSink, reference_escape
    export shows_angles, context_sensitive, shows_long_mixed, shows_long_plain

    # A stream whose write yields before it takes the bytes, the way a socket's
    # does while it waits on the network. A float's digits are handed over as a
    # pointer into a buffer that outlives the call, so whatever else runs during
    # that yield must not be able to write over them.
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
    Base.show(io::IO, ::ShowsLongMixed) = print(io, repeat("a<b>&c \"d\" 'e' ", 200))
    const shows_long_mixed = ShowsLongMixed()

    struct ShowsLongPlain end
    Base.show(io::IO, ::ShowsLongPlain) = print(io, repeat("plain text here ", 200))
    const shows_long_plain = ShowsLongPlain()

end

@testitem "escaping arbitrary values" tags = [:escaping] setup = [Templates, Escapes] begin
    using HypertextTemplates.Elements

    # Values that are neither strings, numbers nor characters are escaped
    # as they print, rather than being turned into a string first. The
    # result has to match what escaping `string(value)` produced.
    reference(escaper, value) = sprint(escaper, string(value))
    for value in Any[
            :sym,
            :var"weird<sym>&\"'",
            nothing,
            missing,
            3 // 4,
            1 + 2im,
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

<<<<<<< HEAD
    # A value whose `show` inspects the stream is answered by the destination,
    # not by the wrapper escaping its output.
||||||| parent of 68ceab1 (fix: answer for the destination a render was given)
    # A value whose `show` inspects the stream must see what it saw when it
    # was rendered into a bare buffer, so the wrapper must not forward the
    # surrounding `IOContext`.
=======
    # A value whose `show` inspects the stream is answered by the destination
    # the render was given rather than by the wrapper escaping its output, so
    # it sees the properties the caller set.
>>>>>>> 68ceab1 (fix: answer for the destination a render was given)
    buffer = IOBuffer()
    HypertextTemplates.escape_html(
        IOContext(buffer, :compact => true),
        context_sensitive,
    )
    @test String(take!(buffer)) == "compact"
    HypertextTemplates.escape_html(buffer, context_sensitive)
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

@testitem "escaping numbers" tags = [:escaping, :perf] setup = [Templates, Escapes] begin
    import Random

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
        reinterpret(Float16, bits) for bits in typemin(UInt16):typemax(UInt16)
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
    for _ in 1:5_000
        push!(sampled, reinterpret(Float32, rand(rng, UInt32)))
        push!(sampled, reinterpret(Float64, rand(rng, UInt64)))
        push!(sampled, randn(rng) * 10.0^rand(rng, -308:308))
        push!(sampled, Float32(randn(rng) * 10.0f0^rand(rng, -38:38)))
    end
    @test first_float_mismatch(sampled) === nothing

    # And the point of owning the buffer: writing a float costs nothing.
    function write_floats(io, n)
        for index in 1:n
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
    floats = allocations(write_floats, sink, 1_000)
    truncate(sink, 0)
    seek(sink, 0)
    # Zero from 1.11; before it the `task_local_storage` lookup allocates,
    # so the bound borrows `SCRATCH_BYTES` as the version switch.
    @test floats <= 2_000 * SCRATCH_BYTES
end

@testitem "float digits belong to the rendering task" tags = [:escaping] setup = [Templates, Escapes] begin
    # The buffer holding the digits belongs to the task doing the
    # rendering, which is what makes it safe to write straight out of: a
    # stream that yields mid-write must not be able to pick up another
    # render's number. Interleave renders across tasks through a stream
    # that does yield, and check every one of them -- a buffer shared any
    # more widely than this fails here.
    concurrent = [index * 1.0e-3 for index in 1:64]
    running = Task[]
    for value in concurrent
        push!(
            running,
            Threads.@spawn(
                begin
                    stream = YieldingSink()
                    for _ in 1:32
                        HypertextTemplates.escape_html(stream, $(value))
                    end
                    String(take!(stream))
                end
            )
        )
    end
    @test all(
        fetch(task) == repeat(sprint(print, value), 32) for
            (value, task) in zip(concurrent, running)
    )
end

@testitem "interpolated text" tags = [:escaping, :perf] setup = [Templates] begin
    using HypertextTemplates.Elements

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
            for i in 1:n
                @p "ab$i"
            end
        end
    end
    function literal_paragraphs(io, n)
        @render io @div begin
            for _ in 1:n
                @p "abcd"
            end
        end
    end
    buffer = IOBuffer(sizehint = 1 << 20)
    located = IOContext(buffer, HypertextTemplates._include_data_htloc() => false)
    interpolated = steady_allocations(interpolated_paragraphs, buffer, located, 200)
    literal = steady_allocations(literal_paragraphs, buffer, located, 200)
    # Joining first cost roughly 7 extra allocations per element. The
    # interpolated form makes one more escaping call per paragraph than the
    # literal one, which before Julia 1.11 is a fixed cost each; see
    # `SCRATCH_BYTES`.
    @test interpolated <= literal + 1_000 + 200 * SCRATCH_BYTES
end

@testitem "escaping keeps its block buffer on the stack" tags = [:escaping, :perf] setup = [Templates, Escapes] begin
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
    function repeatedly(escaper, sink, subject, n)
        for _ in 1:n
            escaper(sink, subject)
        end
    end
    for (subject, name) in subjects
        repeatedly(HypertextTemplates.escape_html, sink, subject, 3)
        repeatedly(HypertextTemplates.escape_attr, sink, subject, 3)
        # Zero on 1.11 and later; see `SCRATCH_BYTES`. The bound is a
        # constant per call either way, so growing the subject must not
        # grow the total.
        budget = 500 * SCRATCH_BYTES
        @testset "$name" begin
            @test allocations(
                repeatedly,
                HypertextTemplates.escape_html,
                sink,
                subject,
                500,
            ) <= budget
            @test allocations(
                repeatedly,
                HypertextTemplates.escape_attr,
                sink,
                subject,
                500,
            ) <= budget
        end
    end
end

@testitem "escaping finds every escapable byte" tags = [:escaping] setup = [Templates, Escapes] begin
    # The scan for the first escapable byte reads eight bytes at a time,
    # after a prologue that walks to an eight-byte boundary. So an escapable
    # character has to be found at every position, at every length spanning
    # several words, and at every pointer alignment -- which substrings
    # provide, since their data begins at an arbitrary offset.
    for length in 0:40
        filler = repeat("x", length)
        @test sprint(HypertextTemplates.escape_html, filler) == filler
        for position in 1:length,
                (character, entity) in ("&" => "&amp;", "<" => "&lt;", ">" => "&gt;")

            subject = filler[1:(position - 1)] * character * filler[(position + 1):end]
            expected = filler[1:(position - 1)] * entity * filler[(position + 1):end]
            @test sprint(HypertextTemplates.escape_html, subject) == expected
            # The same bytes reached through a substring, so the scan sees
            # a pointer that is not eight-byte aligned.
            padded = "abcde" * subject
            for offset in 1:6
                view = SubString(padded, offset)
                @test sprint(HypertextTemplates.escape_html, view) ==
                    sprint(HypertextTemplates.escape_html, String(view))
            end
        end
    end
    # Attribute escaping looks for two more characters, so it gets the same
    # treatment at the lengths where words and boundaries interact.
    for length in (7, 8, 9, 15, 16, 17, 23, 24, 25)
        for position in 1:length, character in ("\"", "'", "&", "<", ">")
            subject =
                repeat("y", position - 1) * character * repeat("y", length - position)
            @test sprint(HypertextTemplates.escape_attr, subject) ==
                reference_escape(subject; attribute = true)
        end
    end
end

@testitem "escaping across block boundaries" tags = [:escaping] setup = [Templates, Escapes] begin
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

    # The escaper alternates between the block buffer and writes straight
    # from the source, so the tail after an early entity has to come out
    # the same as the reference at every length around the clean run.
    for tail in (0, 1, 15, 31, 32, 33, 64, 255, 256, 257, 1_000, 10_000)
        for prefix in ("&", "<>", "\"'", "x&", repeat("<", 40))
            subject = prefix * repeat("x", tail)
            @test sprint(HypertextTemplates.escape_html, subject) ==
                reference_escape(subject; attribute = false)
            @test sprint(HypertextTemplates.escape_attr, subject) ==
                reference_escape(subject; attribute = true)
            # Once more with a trailing entity, so the tail is a gap
            # between two escaped regions rather than the end of the input.
            closed = subject * "&"
            @test sprint(HypertextTemplates.escape_html, closed) ==
                reference_escape(closed; attribute = false)
            @test sprint(HypertextTemplates.escape_attr, closed) ==
                reference_escape(closed; attribute = true)
        end
    end
    # Dense and sparse stretches in turn, which is where the block buffer
    # and the direct writes hand over to one another.
    for gap in (0, 1, 5, 31, 32, 33, 100), entities in 1:3
        subject = repeat(repeat("<\"", entities) * repeat("y", gap), 40)
        @test sprint(HypertextTemplates.escape_html, subject) ==
            reference_escape(subject; attribute = false)
        @test sprint(HypertextTemplates.escape_attr, subject) ==
            reference_escape(subject; attribute = true)
        # And through a substring, for a pointer the scan cannot align.
        view = SubString("abc" * subject, 2)
        @test sprint(HypertextTemplates.escape_attr, view) ==
            reference_escape(String(view); attribute = true)
    end
end

@testitem "esc_str escapes during expansion" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    # The literal is escaped while the macro expands, so what is left in the
    # code is a `SafeString` constant that rendering writes out untouched.
    expanded = @macroexpand esc"<b>Bold & bright</b>"
    @test expanded isa SafeString
    @test expanded == SafeString("&lt;b&gt;Bold &amp; bright&lt;/b&gt;")
    @test String(expanded) == sprint(HypertextTemplates.escape_html, "<b>Bold & bright</b>")

    # Only the three characters `escape_html` replaces are replaced: quotes are
    # left alone, so this is not a substitute for attribute escaping.
    @test esc"'\"" == SafeString("'\"")

    # A string macro receives its text unprocessed, so `$` is content rather
    # than interpolation.
    @test esc"$name" == SafeString("\$name")

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    # Being safe, the escaped text survives a second pass through the escapers
    # unchanged, in text and in an attribute alike.
    @test bare(io -> @render io @div $(esc"<b>x</b>")) == "<div>&lt;b&gt;x&lt;/b&gt;</div>"
    @test bare(io -> @render io @div {title = esc"<x>"}) == "<div title=\"&lt;x&gt;\"></div>"
end


@testitem "splatted attribute names are validated" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    named(name, value) = NamedTuple{(Symbol(name),)}((value,))

    # A name goes into the tag as it stands, so one that could break out is
    # refused: a literal during expansion, a splatted one as it is written.
    attack = named("x\" onmouseover=\"alert(1)", "y")
    @test_throws ArgumentError bare(io -> @render io @div {attack...})

    # The case the check exists for, and the other route through the renderer:
    # a `NamedTuple` unrolls with its names in the type, a `Dict` is iterated.
    dictionary = Dict(Symbol("x\" onmouseover=\"alert(1)") => "y")
    @test_throws ArgumentError bare(io -> @render io @div {dictionary...})

    for name in
        ["a b", "a\"b", "a'b", "a>b", "a/b", "a=b", "a\tb", "a\nb", "a\eb", "a\x7fb"]
        props = named(name, "v")
        @test_throws ArgumentError bare(io -> @render io @div {props...})
        # A `false` value writes nothing at all, so there is no name to break
        # out of.
        skipped = named(name, false)
        @test bare(io -> @render io @div {skipped...}) == "<div></div>"
    end

    # The error names the attribute, since a splat gives no other clue which
    # key was at fault.
    thrown = try
        bare(io -> @render io @div {attack...})
        nothing
    catch error
        error
    end
    @test occursin("onmouseover", sprint(showerror, thrown))

    # Everything a template legitimately splats still renders.
    props = (;
        class = "card",
        var"data-foo" = "1",
        var"aria-label" = "Close",
        var"@click" = "open = true",
        hidden = true,
    )
    @test bare(io -> @render io @div {props...}) ==
        "<div class=\"card\" data-foo=\"1\" aria-label=\"Close\" @click=\"open = true\" hidden></div>"
end

@testitem "escaping strings that are not String" tags = [:escaping] setup = [Templates, Escapes] begin
    using Test: GenericString

    # `String` and `SubString{String}` have a byte-scanning escaper of their
    # own; every other string escapes through the wrapper and must match it.
    subject = "a<b>&c \"d\" 'e' ☃ plain text here"
    views = Any[
        SubString(SubString("z" * subject, 2), 1),
        GenericString(subject),
        GenericString(""),
        GenericString("<"),
    ]
    @static if VERSION >= v"1.8"
        push!(views, LazyString(subject, "<&>", 42))
    end
    for value in views
        reference = String(value)
        @test sprint(HypertextTemplates.escape_html, value) ==
            reference_escape(reference; attribute = false)
        @test sprint(HypertextTemplates.escape_attr, value) ==
            reference_escape(reference; attribute = true)
    end

    # Long enough to cross the block boundary several times, so the stream
    # wrapper's blocked writes are exercised rather than a single short run.
    long = repeat("a<b>&c \"d\" 'e' ", 200)
    @test sprint(HypertextTemplates.escape_html, GenericString(long)) ==
        reference_escape(long; attribute = false)
    @test sprint(HypertextTemplates.escape_attr, GenericString(long)) ==
        reference_escape(long; attribute = true)
end

@testitem "script and style bodies are raw text" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    # A browser does not decode entities inside a script or a style, so
    # escaping the body changes the program it runs and the rules it applies.
    @test bare(io -> @render io @script "if (a < b && c) {}") ==
        "<script>if (a < b && c) {}</script>"
    @test bare(io -> @render io @style "a > b { content: \"&\" }") ==
        "<style>a > b { content: \"&\" }</style>"

    # Interpolated content is written the same way.
    code = "x < y && y > z"
    @test bare(io -> @render io @script $code) == "<script>x < y && y > z</script>"
    @test bare(io -> @render io @script "var x = $code;") ==
        "<script>var x = x < y && y > z;</script>"
    @test bare(io -> @render io @script "n = " $(42) ";") == "<script>n = 42;</script>"

    # What raw text cannot carry is the sequence that ends it.
    attack = "</script><img src=x onerror=alert(1)>"
    @test bare(io -> @render io @script $attack) ==
        "<script><\\/script><img src=x onerror=alert(1)></script>"
    @test bare(io -> @render io @script "a</script>b") == "<script>a<\\/script>b</script>"
    @test bare(io -> @render io @script "a</SCRIPT >b") == "<script>a<\\/SCRIPT >b</script>"
    @test bare(io -> @render io @script "</") == "<script></</script>"
    @test bare(io -> @render io @script "<") == "<script><</script>"
    # Only the element's own end tag closes it. A `style` is left by `</style`
    # and by nothing else, so the `</script` in the same value stays as it is.
    @test bare(io -> @render io @style $("</style><script>alert(1)</script>")) ==
        "<style><\\/style><script>alert(1)</script></style>"
    # An end tag for some other element is text the tokenizer hands back, so
    # there is nothing to neutralise in it.
    @test bare(io -> @render io @script "a" $("</b>") "c") == "<script>a</b>c</script>"
    # The sequence is neutralised wherever it lands, including when it is
    # divided between the end of one interpolated value and the start of the
    # next.
    @test bare(io -> @render io @script "a" $("</scr") $("ipt>") "c") ==
        "<script>a<\\/script>c</script>"

    # `SafeString` says the content is already what it should be, and nothing
    # in it is escaped. What still cannot appear in the body is the sequence
    # that ends the element, whoever wrote it.
    safe = SafeString("if (a < b) { document.write(\"</script>\") }")
    @test bare(io -> @render io @script $safe) ==
        "<script>if (a < b) { document.write(\"<\\/script>\") }</script>"

    # Only the raw text elements change; anything alongside one is escaped.
    @test bare(
        io -> @render io @div begin
            @script "a<b"
            "c<d"
        end
    ) == "<div><script>a<b</script>c&lt;d</div>"
    # A nested element starts markup again, so its children are escaped. Its
    # tags pass through intact, since `</div` does not close a `script`.
    @test bare(io -> @render io @script @div "a<b") ==
        "<script><div>a&lt;b</div></script>"
    @test bare(io -> @render io @textarea "a<b") == "<textarea>a&lt;b</textarea>"

    # Attributes are attributes wherever they are written.
    @test bare(io -> @render io @script {src = "/a?b=1&c=2"}) ==
        "<script src=\"/a?b=1&amp;c=2\"></script>"

    # Settled during expansion, and `@<` over a variable does not know its
    # element until the render, so its children are escaped.
    dynamic = Elements.script
    @test bare(io -> @render io @<dynamic "a<b") == "<script>a&lt;b</script>"
end

@testitem "raw text carries through `@text`" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    # `@text` writes the content of the element it is written in, and a
    # `script` or a `style` holds raw text.
    @test bare(io -> @render io @script @text "if (a < b && c)") ==
        "<script>if (a < b && c)</script>"
    @test bare(io -> @render io @style @text "a > b { }") == "<style>a > b { }</style>"

    # Julia's own control flow decides when a write happens, not where it goes.
    value = "a < b"
    condition = true
    @test bare(
        io -> @render io @script begin
            if condition
                @text value
            end
        end
    ) == "<script>a < b</script>"

    # Neutralised in what `@text` writes, and across the boundary after it.
    @test bare(io -> @render io @script @text "</script>") ==
        "<script><\\/script></script>"
    @test bare(
        io -> @render io @script begin
            @text "x<"
            "/script>"
        end
    ) == "<script>x<\\/script></script>"

    # Everywhere else `@text` escapes, as it always has.
    @test bare(io -> @render io @div @text "a<b") == "<div>a&lt;b</div>"
    @test bare(io -> @render io @div @text value) == "<div>a &lt; b</div>"
end

@testitem "slots write their element's raw text" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    @component function inline_script()
        @script @__slot__
    end

    @component function trailing_script()
        @script begin
            @__slot__
            "/script>"
        end
    end

    # A string literal directly before a macro call is that call's docstring,
    # so the child before the slot is written with `@text` instead.
    @component function leading_script()
        @script begin
            @text "x<"
            @__slot__
        end
    end

    @component function named_script()
        @script @__slot__ js
    end

    @component function plain_div()
        @div @__slot__
    end

    # A slot is written where the component renders it, so content passed into
    # one inside a `script` is that script's raw text however the call site
    # wrote it.
    @test bare(io -> @render io @<inline_script "if (a < b)") ==
        "<script>if (a < b)</script>"
    code = "x < y && y > z"
    @test bare(io -> @render io @<inline_script $code) ==
        "<script>x < y && y > z</script>"
    @test bare(
        io -> @render io @<named_script begin
            js := "a < b"
        end
    ) == "<script>a < b</script>"

    # One writer covers the whole of the element's children, slot content
    # included, so a sequence divided across the slot boundary is caught either
    # way round.
    @test bare(io -> @render io @<trailing_script "x<") ==
        "<script>x<\\/script></script>"
    @test bare(io -> @render io @<leading_script "/script>") ==
        "<script>x<\\/script></script>"

    # `SafeString` still says nothing in the content is escaped, and the
    # writer still keeps the sequence that ends the element out of it.
    @test bare(io -> @render io @<inline_script $(SafeString("a < b</script>"))) ==
        "<script>a < b<\\/script></script>"

    # A slot rendered outside a raw text element escapes as it always has.
    @test bare(io -> @render io @<plain_div "a<b") == "<div>a&lt;b</div>"
    @test bare(io -> @render io @<plain_div $code) ==
        "<div>x &lt; y &amp;&amp; y &gt; z</div>"
end

@testitem "an element nested in raw text starts markup again" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    # The innermost element decides. A `script` body is raw text, but an
    # element written inside one is markup again, so its children are escaped.
    # Its own tags reach the page as they were written: `</div` is not what
    # closes a `script`, so the writer leaves it alone.
    value = "a<b"
    @test bare(io -> @render io @script @div "a<b") ==
        "<script><div>a&lt;b</div></script>"
    @test bare(io -> @render io @script @div $value) ==
        "<script><div>a&lt;b</div></script>"
    @test bare(io -> @render io @style @div "a<b") ==
        "<style><div>a&lt;b</div></style>"
    @test bare(io -> @render io @style @div $value) ==
        "<style><div>a&lt;b</div></style>"

    # Which is what a template script needs: the block is parsed as HTML by
    # the page later, so an entity written in it is decoded then, content that
    # reached it from a user has to be escaped for that parse, and the markup
    # the template wrote has to survive it as markup.
    user_input = "<img src=x onerror=alert(1)>"
    @test bare(io -> @render io @script {type = "text/template"} @div $user_input) ==
        "<script type=\"text/template\"><div>&lt;img src=x onerror=alert(1)&gt;</div></script>"

    # Escaping the nested element's children already keeps a `<` out of them,
    # so what the writer is left to catch is a `SafeString`, which says the
    # content is already what it should be and is written through untouched.
    @test bare(io -> @render io @script @div $("</script>")) ==
        "<script><div>&lt;/script&gt;</div></script>"
    @test bare(io -> @render io @script @div $(SafeString("</script>"))) ==
        "<script><div><\\/script></div></script>"

    # The rule applies at every depth, since each element is asked about its
    # own children rather than the one it is written in.
    @test bare(io -> @render io @script @div @span $value) ==
        "<script><div><span>a&lt;b</span></div></script>"

    # `@text` and slot content follow the element they land in, not the one
    # the template wrote them under.
    @test bare(io -> @render io @script @div @text value) ==
        "<script><div>a&lt;b</div></script>"

    @component function nested_slot()
        @script @div @__slot__
    end

    @test bare(io -> @render io @<nested_slot $value) ==
        "<script><div>a&lt;b</div></script>"

    # `@<` over a variable only learns which element it is rendering at the
    # render itself, and that is when the decision is made.
    nested = Elements.div
    @test bare(io -> @render io @script @<nested $value) ==
        "<script><div>a&lt;b</div></script>"
end

@testitem "raw text end tags split across children" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    # A raw text element writes its children one call at a time, so the
    # sequence that ends it can arrive split between two of them.
    head = "x<"
    tail = "/script><img src=x onerror=alert(1)>"
    split = "<script>x<\\/script><img src=x onerror=alert(1)></script>"
    @test bare(io -> @render io @script $head $tail) == split
    # An interpolated string is written a piece at a time, which splits it the
    # same way inside a single child.
    @test bare(io -> @render io @script "$head$tail") == split
    # A literal child is neutralised while the macro expands, and one ending in
    # `<` leaves the decision to whatever follows it.
    @test bare(io -> @render io @script "x<" $tail) == split
    @test bare(io -> @render io @script $("x<") "/script>x") ==
        "<script>x<\\/script>x</script>"
    @test bare(io -> @render io @style $("a<") $("/style>b")) ==
        "<style>a<\\/style>b</style>"

    # A `<` that nothing completes is written as it stands, at the end of a
    # child or at the end of the element.
    @test bare(io -> @render io @script $("a<") $(" b")) == "<script>a< b</script>"
    @test bare(io -> @render io @script $("a<")) == "<script>a<</script>"
    @test bare(io -> @render io @script $("a<") $("<") $("/script")) ==
        "<script>a<<\\/script</script>"

    # Ordinary comparisons are untouched, whichever child they land in.
    @test bare(io -> @render io @script $("a < b") $("<= c") $("d << e")) ==
        "<script>a < b<= cd << e</script>"
end

@testitem "a SafeString in raw text cannot end the element" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    # A `SafeString` in a `script` is usually JSON built from a user's data,
    # where a `</script` would close the element and leave the rest as markup.
    @test bare(io -> @render io @script $(SafeString("</script><b>x</b>"))) ==
        "<script><\\/script><b>x</b></script>"
    # A `<script` only does anything from inside the escaped state, which the
    # neutralised comment keeps out of reach, so it is written as it stands.
    @test bare(io -> @render io @script $(SafeString("<!--<script>"))) ==
        "<script><\\!--<script></script>"
    @test bare(io -> @render io @style $(SafeString("</style>"))) ==
        "<style><\\/style></style>"

    # Written through the same writer as every other child, so a sequence
    # divided between it and its neighbour is caught either way round.
    @test bare(io -> @render io @script $(SafeString("x<")) "/script>") ==
        "<script>x<\\/script></script>"
    @test bare(io -> @render io @script "x<" $(SafeString("/script>"))) ==
        "<script>x<\\/script></script>"

    # Entities in it stay the characters they spell, and a `<` that ends
    # nothing stays as it is.
    @test bare(io -> @render io @script $(SafeString("a &lt; b &amp;&amp; c"))) ==
        "<script>a &lt; b &amp;&amp; c</script>"
    @test bare(io -> @render io @script $(SafeString("if (a < b) {}"))) ==
        "<script>if (a < b) {}</script>"

    # Outside a raw text element a `SafeString` is written exactly as it is.
    @test bare(io -> @render io @div $(SafeString("</script><b>x</b>"))) ==
        "<div></script><b>x</b></div>"
    @test bare(io -> @render io @textarea $(SafeString("</b>"))) ==
        "<textarea></b></textarea>"
end

@testitem "script data escaped states cannot be entered" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    # `<!--` enters script data escaped, where a `<script` reaches double
    # escaped and `</script>` stops ending the element. The comment is the only
    # way in, so neutralising it keeps both states out of reach.
    @test bare(io -> @render io @script "<!--") == "<script><\\!--</script>"
    @test bare(io -> @render io @script $("<!--<script>")) ==
        "<script><\\!--<script></script>"
    # So a `<script` needs nothing: with no comment ahead of it the tokenizer
    # is still in script data, where it is ordinary text.
    @test bare(io -> @render io @script "<script>") == "<script><script></script>"
    @test bare(io -> @render io @script $("<ScRiPt>")) == "<script><ScRiPt></script>"

    # The comment can arrive divided between two children, at any point.
    @test bare(io -> @render io @script $("<") $("!--")) == "<script><\\!--</script>"
    @test bare(io -> @render io @script $("<!-") $("-")) == "<script><\\!--</script>"
    # A literal ends a child the same way an interpolated value does.
    @test bare(io -> @render io @script "x<" $("!-- y")) ==
        "<script>x<\\!-- y</script>"

    # A `<` that begins nothing is left as it stands, however far into a
    # sequence it looked like going.
    @test bare(io -> @render io @script $("a < b") $("c <= d") $("e << f")) ==
        "<script>a < bc <= de << f</script>"
    @test bare(io -> @render io @script $("<!x") $("<!-y") $("<span>")) ==
        "<script><!x<!-y<span></script>"
    @test bare(io -> @render io @script $("</scr") $("x")) == "<script></scrx</script>"
    @test bare(io -> @render io @script $("</scrip")) == "<script></scrip</script>"
    # A `</` that ends nothing is an end tag the tokenizer hands back as text.
    @test bare(io -> @render io @script $("x</ y")) == "<script>x</ y</script>"

    # A `style` has no escaped state, so neither sequence means anything there.
    @test bare(io -> @render io @style $("<!--<script>")) ==
        "<style><!--<script></style>"
    @test bare(io -> @render io @style $("a<") $("/style>")) ==
        "<style>a<\\/style></style>"
    # Each element answers only for its own end tag.
    @test bare(io -> @render io @style $("</script>")) == "<style></script></style>"
    @test bare(io -> @render io @script $("</style>")) == "<script></style></script>"
end

@testitem "raw text pieces neutralise as the whole body would" tags = [:escaping] setup = [Templates] begin
    using HypertextTemplates.Elements
    import Random

    function bare(render)
        io = IOBuffer()
        render(IOContext(io, HypertextTemplates._include_data_htloc() => false))
        return String(take!(io))
    end

    # A scan over the body in one piece, to check the writer's piecewise one
    # against however the body was divided up.
    function reference(body::AbstractString; script::Bool)
        io = IOBuffer()
        endtag = script ? "</script" : "</style"
        index = 1
        while index <= lastindex(body)
            rest = SubString(body, index)
            matched = if lowercase(first(rest, length(endtag))) == endtag
                length(endtag)
            elseif script && startswith(rest, "<!--")
                4
            else
                0
            end
            if matched == 0
                print(io, body[index])
                index += 1
            else
                print(io, "<\\", SubString(rest, 2, matched))
                index += matched
            end
        end
        return String(take!(io))
    end

    # Built from the sequences and their parts, so completions, near misses
    # and split completions turn up often rather than by chance.
    fragments = [
        "<", "</", "<!", "<!-", "<!--", "</s", "</scr", "</script", "</ScRiPt",
        "</sty", "</style", "</STYLE", "</div", "<script", "<style",
        "/", "!", "-", "--", "s", "sc", "cript", "ript", "SCRIPT",
        "tyle", "yle", "le", "t", "e", ">",
        "x", " ", "a < b", "<=", "<<",
    ]
    rng = Random.MersenneTwister(20250901)
    for _ in 1:500
        first_piece, second, third =
            (join(rand(rng, fragments, rand(rng, 0:3))) for _ in 1:3)
        body = string(first_piece, second, third)
        @test bare(io -> @render io @script $first_piece $second $third) ==
            string("<script>", reference(body; script = true), "</script>")
        @test bare(io -> @render io @style $first_piece $second $third) ==
            string("<style>", reference(body; script = false), "</style>")
        # A `SafeString` child is written through the writer as any other is,
        # so the same body neutralises the same way.
        safe_first, safe_second, safe_third =
            SafeString(first_piece), SafeString(second), SafeString(third)
        @test bare(io -> @render io @script $safe_first $safe_second $safe_third) ==
            string("<script>", reference(body; script = true), "</script>")
        @test bare(io -> @render io @style $safe_first $safe_second $safe_third) ==
            string("<style>", reference(body; script = false), "</style>")
    end
end
