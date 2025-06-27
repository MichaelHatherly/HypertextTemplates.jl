using Test
using HypertextTemplates
using HypertextTemplates.Library
using ReferenceTests

@testset "Layout Components" begin
    @testset "Container" begin
        @test_reference "references/library/container-default.txt" begin
            @renderhtml begin
                @Container begin
                    "Container content"
                end
            end
        end

        @test_reference "references/library/container-sizes.txt" begin
            @renderhtml begin
                @Container {size=:sm} "Small container"
                @Container {size=:lg} "Large container"
                @Container {size=Symbol("2xl")} "2XL container"
            end
        end

        @test_reference "references/library/container-options.txt" begin
            @renderhtml begin
                @Container {padding=false} "No padding"
                @Container {centered=false} "Not centered"
                @Container {class="custom-class"} "With custom class"
            end
        end
    end

    @testset "Stack" begin
        @test_reference "references/library/stack-default.txt" begin
            @renderhtml begin
                @Stack begin
                    @div "Item 1"
                    @div "Item 2"
                    @div "Item 3"
                end
            end
        end

        @test_reference "references/library/stack-horizontal.txt" begin
            @renderhtml begin
                @Stack {direction=:horizontal, gap=2} begin
                    @div "Item 1"
                    @div "Item 2"
                    @div "Item 3"
                end
            end
        end

        @test_reference "references/library/stack-alignment.txt" begin
            @renderhtml begin
                @Stack {align=:center, justify=:between} begin
                    @div "Item 1"
                    @div "Item 2"
                end
            end
        end
    end

    @testset "Grid" begin
        @test_reference "references/library/grid-default.txt" begin
            @renderhtml begin
                @Grid {cols=3} begin
                    @div "Cell 1"
                    @div "Cell 2"
                    @div "Cell 3"
                end
            end
        end

        @test_reference "references/library/grid-responsive.txt" begin
            @renderhtml begin
                @Grid {cols=1, sm=2, md=3, lg=4} begin
                    @div "Cell 1"
                    @div "Cell 2"
                    @div "Cell 3"
                    @div "Cell 4"
                end
            end
        end

        @test_reference "references/library/grid-gap.txt" begin
            @renderhtml begin
                @Grid {cols=2, gap=8} begin
                    @div "Cell 1"
                    @div "Cell 2"
                end
            end
        end
    end

    @testset "Section" begin
        @test_reference "references/library/section-default.txt" begin
            @renderhtml begin
                @Section begin
                    "Section content"
                end
            end
        end

        @test_reference "references/library/section-spacing.txt" begin
            @renderhtml begin
                @Section {spacing=:sm} "Small spacing"
                @Section {spacing=:lg} "Large spacing"
            end
        end

        @test_reference "references/library/section-background.txt" begin
            @renderhtml begin
                @Section {background="bg-slate-100"} begin
                    "Section with background"
                end
            end
        end
    end
end
