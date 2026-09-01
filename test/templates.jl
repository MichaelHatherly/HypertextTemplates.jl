# The templates the suite renders, and the helper that renders one against a
# stored reference. Test items reach these with `setup = [Templates]`.
#
# The imports here are what the whole suite runs against, not just the
# templates below: `Revise` puts the source tracking extension in play, and
# `CommonMark` and `HTTP` load the extensions whose methods the ambiguity check
# covers.
@testmodule Templates begin

    import CommonMark
    import HTTP
    import Revise
    using HypertextTemplates
    using HypertextTemplates.Elements
    using ReferenceTests
    using Test

    export render_test, allocations, steady_allocations
    export SCRATCH_BYTES, LAZY_ATTRIBUTE_BYTES
    export custom_element, @custom_element
    export custom_component, @custom_component
    export nested_component, @nested_component
    export slot_component, @slot_component
    export conditional_component, @conditional_component
    export commonmark_component, @commonmark_component
    export once_jquery, @once_jquery
    export once_button, @once_button
    export once_page, @once_page

    # Turns off source locations in the rendered HTML such that the reference
    # testing does not need to account for that variablity. Reference paths are
    # resolved against this directory rather than the working directory, so a
    # test item can live in a subdirectory and still name its reference the
    # same way.
    function render_test(f, file)
        io = IOBuffer()
        ctx = IOContext(io, HypertextTemplates._include_data_htloc() => false)
        f(ctx)
        return @test_reference(joinpath(@__DIR__, file), String(take!(io)))
    end

    # `@allocated` measures everything the expression does, and at a test item's
    # top level that includes reading the non-constant globals the call's
    # arguments come from. Measuring in here keeps them concrete locals, so what
    # is measured is the call.
    allocations(f, args...) = @allocated f(args...)

    # What a render costs once the one-time costs are behind it. Compilation
    # dominates the first call and, before Julia 1.11, a further round of it
    # lands on the second, which together run to several times the differences
    # these comparisons bound. `buffer` is emptied before each call so every
    # measurement starts from the same sink.
    function steady_allocations(f, buffer, args...)
        used = typemax(Int)
        for _ in 1:4
            take!(buffer)
            used = min(used, allocations(f, args...))
        end
        take!(buffer)
        return used
    end

    @element "custom-element" custom_element
    @deftag macro custom_element end

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

    # Julia stack allocates the temporaries the render path relies on only from
    # 1.11, where escape analysis can see that they never leave the function.
    # Before that the escapers' scratch buffer costs a fixed 16 or 32 bytes a
    # call, and the lazy attribute wrapper costs a couple of hundred bytes an
    # element.
    #
    # Both are constants -- per call and per element -- rather than costs per
    # byte, so the invariants the allocation tests exist to protect still hold
    # on those versions: escaping neither allocates per character nor copies its
    # input, and an interpolated attribute is still much cheaper than joining it
    # eagerly was (measured on 1.6, 204 bytes an element against 335). The
    # totals simply are not zero there, so they are bounded by these constants
    # instead, which from 1.11 on are zero and the assertions stay exact.
    const SCRATCH_BYTES = VERSION >= v"1.11" ? 0 : 64
    const LAZY_ATTRIBUTE_BYTES = VERSION >= v"1.11" ? 0 : 256

end
