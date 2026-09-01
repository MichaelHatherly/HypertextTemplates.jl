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

    # A context built by hand out of some other kind of `Ref` still
    # renders, it just does not get the fast path above.
    handmade = IOContext(
        IOBuffer(),
        :__once__ => Ref{Any}(Set{Symbol}()),
        HypertextTemplates._include_data_htloc() => false,
    )
    @render handmade @div begin
        @once_button
        @once_button
    end
    handmade_output = String(take!(handmade.io))
    @test count("jquery-3.6.0.min.js", handmade_output) == 1
end
