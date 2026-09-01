@testitem "method ambiguities" tags = [:core] setup = [Templates] begin
    # `StreamingRender` hands its writer to user code, so a `write` method
    # that is ambiguous against `Base` turns every call on it into a
    # `MethodError`. The extensions are loaded by the setup module, which
    # brings their methods into the search on the Julia versions that reach
    # them as submodules.
    @test isempty(Test.detect_ambiguities(HypertextTemplates; recursive = true))
end
