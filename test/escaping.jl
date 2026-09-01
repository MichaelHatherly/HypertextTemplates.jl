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
Base.show(io::IO, ::ShowsLongMixed) = print(io, repeat("a<b>&c\"d'e ", 200))
const shows_long_mixed = ShowsLongMixed()

struct ShowsLongPlain end
Base.show(io::IO, ::ShowsLongPlain) = print(io, repeat("plain text here ", 200))
const shows_long_plain = ShowsLongPlain()

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
    # Joining first cost roughly 7 extra allocations per element.
    @test interpolated <= literal + 1_000
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
        @testset "$name" begin
            @test (@allocated repeatedly(
                HypertextTemplates.escape_html,
                subject,
                500,
            )) == 0
            @test (@allocated repeatedly(
                HypertextTemplates.escape_attr,
                subject,
                500,
            )) == 0
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
            @test sprint(HypertextTemplates.escape_attr, subject) == replace(
                subject,
                "&" => "&amp;",
                "<" => "&lt;",
                ">" => "&gt;",
                "\"" => "&quot;",
                "'" => "&#39;",
            )
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
                  replace(subject, "&" => "&amp;", "<" => "&lt;", ">" => "&gt;")
            @test sprint(HypertextTemplates.escape_attr, subject) == replace(
                subject,
                "&" => "&amp;",
                "<" => "&lt;",
                ">" => "&gt;",
                "\"" => "&quot;",
                "'" => "&#39;",
            )
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
    for gap in (0, 1, 5, 31, 32, 33, 100), entities = 1:3
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
