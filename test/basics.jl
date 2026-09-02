@testitem "element rendering" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements
    import HypertextTemplates.Elements: @time

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
    render_test("references/basics/non-standard-prop-names.txt") do io
        @render io @div {"x-data" := "{ open: false }"} begin
            @button {"@click" := "open = true"} "Expand"
            @span {"x-show" := "open"} "Content..."
        end
    end
end

@testitem "component rendering" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

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
end

@testitem "a slot the caller did not pass" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    @component function needs_heading()
        @div @__slot__ heading
    end

    function message(f)
        try
            f()
            return nothing
        catch error
            return isa(error, ErrorException) ? error.msg : rethrow()
        end
    end

    # Every call site passes a default slot, so the message reports the named
    # slots the caller wrote and stays quiet about the one it did not.
    @test message(() -> @render @<needs_heading) ==
        "component `needs_heading` has no slot named `heading`: no named slots were passed."
    @test message(
        () -> @render @<needs_heading begin
            footing := @p "content"
        end
    ) ==
        "component `needs_heading` has no slot named `heading`: the named slots passed were `footing`."
    # Content written for the default slot is still not a named slot.
    @test message(() -> @render @<needs_heading "content") ==
        "component `needs_heading` has no slot named `heading`: no named slots were passed."
end

@testitem "tags used outside a render" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    # `@deftag` splices the element or component itself into the `@<` call, so
    # the name the message reports has to come back off that value rather than
    # off the expression the template wrote.
    function message(f)
        try
            f()
            return nothing
        catch error
            return isa(error, ErrorException) ? error.msg : rethrow()
        end
    end

    @test message(() -> @div "content") ==
        "`@div` and `@<div` cannot be used outside of a `@render` or `@component` macro."
    @test message(() -> @custom_element) ==
        "`@custom-element` and `@<custom-element` cannot be used outside of a `@render` or `@component` macro."
    @test message(() -> @custom_component) ==
        "`@custom_component` and `@<custom_component` cannot be used outside of a `@render` or `@component` macro."
end

@testitem "render root" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

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

@testitem "output types" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    result = @render @p "content"
    @test isa(result, String)
    result_bytes = @render Vector{UInt8} @p "content"
    @test isa(result_bytes, Vector{UInt8})

    # A render adds its own entries to the caller's stream, so the bytes
    # still have to land in the stream that was passed, and that same object
    # has to come back. Source attributes are left in here, so the opening
    # tag is only checked for its name.
    buffer = IOBuffer()
    @test (@render buffer @p "content") === buffer
    @test contains(String(take!(buffer)), "content</p>")

    context = IOContext(buffer, :compact => true)
    @test (@render context @p "content") === context
    @test contains(String(take!(buffer)), "content</p>")

    mktemp() do path, handle
        @render handle @p "content"
        close(handle)
        @test contains(read(path, String), "content</p>")
    end
end

@testitem "a render's stream answers for its destination" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    # A value that reports what the stream it is handed says about itself, the
    # way a `show` method that lays its output out to the terminal width does.
    struct Probe end
    report(io::IO) =
        print(io, displaysize(io), isopen(io), iswritable(io), isreadable(io))
    HypertextTemplates.escape_html(io::IO, probe::Probe, revise) =
        show(io, MIME"text/html"(), probe)
    Base.show(io::IO, ::MIME"text/html", ::Probe) = report(io)
    # Raw text writes a value with `print`, which reaches this instead.
    Base.show(io::IO, ::Probe) = report(io)

    buffer = IOBuffer(; read = false, write = true)
    context = IOContext(
        buffer,
        :displaysize => (10, 20),
        HypertextTemplates._include_data_htloc() => false,
    )
    expected = string((10, 20), true, true, false)

    @render context @p $(Probe())
    @test String(take!(buffer)) == "<p>$(expected)</p>"

    # The writer a raw text element's children go through stands in for the
    # destination in the same way.
    @render context @script $(Probe())
    @test String(take!(buffer)) == "<script>$(expected)</script>"

    # A value with no `escape_html` method of its own is printed through the
    # escaping wrapper, which stands in for the destination too: the same value
    # has to lay itself out the same way whichever element it lands in.
    struct Printed end
    Base.show(io::IO, ::Printed) = print(io, displaysize(io), get(io, :flavour, :none))
    flavoured = IOContext(context, :flavour => :terse)
    laid_out = string((10, 20), :terse)

    @render flavoured @p $(Printed())
    @test String(take!(buffer)) == "<p>$(laid_out)</p>"
    @render flavoured @script $(Printed())
    @test String(take!(buffer)) == "<script>$(laid_out)</script>"
    # An attribute value goes through the escaping wrapper too.
    printed = Printed()
    @render flavoured @div {title = printed}
    @test String(take!(buffer)) == "<div title=\"$(laid_out)\"></div>"
end

@testitem "a wrapped stream forwards what it is asked" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    # A destination that records the calls a wrapper is supposed to pass on
    # rather than answer itself.
    mutable struct Recorder <: IO
        io::IOBuffer
        properties::Dict{Symbol, Any}
        locks::Int
        unlocks::Int
        flushes::Int
    end
    Recorder(properties) = Recorder(IOBuffer(), properties, 0, 0, 0)

    Base.unsafe_write(r::Recorder, p::Ptr{UInt8}, n::UInt) = unsafe_write(r.io, p, n)
    Base.write(r::Recorder, byte::UInt8) = write(r.io, byte)
    Base.get(r::Recorder, key, default) = get(r.properties, key, default)
    Base.getindex(r::Recorder, key) = r.properties[key]
    Base.haskey(r::Recorder, key) = haskey(r.properties, key)
    Base.lock(r::Recorder) = (r.locks += 1; nothing)
    Base.unlock(r::Recorder) = (r.unlocks += 1; nothing)
    Base.flush(r::Recorder) = (r.flushes += 1; nothing)
    Base.displaysize(r::Recorder) = (7, 13)
    Base.isopen(r::Recorder) = isopen(r.io)
    Base.iswritable(r::Recorder) = iswritable(r.io)
    Base.isreadable(r::Recorder) = isreadable(r.io)

    # Every wrapper the render path puts in front of a destination. Asked of
    # the wrappers rather than through a render, since what a render asks of
    # its stream is its own business and these have to answer whoever asks.
    recorder = Recorder(Dict{Symbol, Any}(:label => "carried"))
    wrappers = (
        HypertextTemplates.RawTextWriter{true}(recorder),
        HypertextTemplates.RawTextWriter{false}(recorder),
        HypertextTemplates.MarkupWriter(recorder),
        HypertextTemplates.EscapeStream{false}(recorder),
        HypertextTemplates.EscapeStream{true}(recorder),
    )
    for wrapper in wrappers
        @test wrapper isa HypertextTemplates.WrappedIO
        @test get(wrapper, :label, "absent") == "carried"
        @test wrapper[:label] == "carried"
        @test haskey(wrapper, :label)
        @test !haskey(wrapper, :missing)
        @test displaysize(wrapper) == displaysize(recorder)
        @test isopen(wrapper) == isopen(recorder)
        @test iswritable(wrapper) == iswritable(recorder)
        @test isreadable(wrapper) == isreadable(recorder)
        lock(wrapper)
        unlock(wrapper)
        flush(wrapper)
    end
    @test recorder.locks == length(wrappers)
    @test recorder.unlocks == length(wrappers)
    @test recorder.flushes == length(wrappers)
end

@testitem "call site source information" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    line = @__LINE__
    file = @__FILE__
    result = @render @p "content"
    @test contains(result, "data-htloc=\"$file:$(line + 2)\"")
end
