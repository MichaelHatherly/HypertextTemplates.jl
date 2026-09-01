import CommonMark
import HTTP
import Random
import Revise
using HypertextTemplates
using HypertextTemplates.Elements
import HypertextTemplates.Elements: @time
using ReferenceTests
using Test

# Turns off source locations in the rendered HTML such that the reference
# testing does not need to account for that variablity.
function render_test(f, file)
    io = IOBuffer()
    ctx = IOContext(io, HypertextTemplates._include_data_htloc() => false)
    f(ctx)
    return @test_reference(file, String(take!(io)))
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

@testset "HypertestTemplates" begin
    include("basics.jl")
    include("markdown.jl")
    include("streaming.jl")
    include("props.jl")
    include("render-buffer.jl")
    include("escaping.jl")
    include("once.jl")
    include("source-tracking.jl")
    include("hygiene.jl")
    include("precompile.jl")
end
