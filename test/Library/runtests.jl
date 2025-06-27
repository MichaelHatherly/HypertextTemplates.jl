using Test

@testset "HypertextTemplates.Library" begin
    include("layout-tests.jl")
    include("typography-tests.jl")
    include("cards-tests.jl")
    include("tables-tests.jl")
    include("forms-tests.jl")
    include("feedback-tests.jl")
    include("navigation-tests.jl")
    include("utilities-tests.jl")
end
