using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Layout Components" begin
    @testset "Container" begin
        render_test("references/library/container-default.txt") do io
            @render io @Container begin
                "Container content"
            end
        end

        render_test("references/library/container-sizes.txt") do io
            @render io begin
                @Container {size=:sm} "Small container"
                @Container {size=:lg} "Large container"
                @Container {size=Symbol("2xl")} "2XL container"
            end
        end

        render_test("references/library/container-options.txt") do io
            @render io begin
                @Container {padding=false} "No padding"
                @Container {centered=false} "Not centered"
                @Container {class="custom-class"} "With custom class"
            end
        end
    end

    @testset "Stack" begin
        render_test("references/library/stack-default.txt") do io
            @render io @Stack begin
                @div "Item 1"
                @div "Item 2"
                @div "Item 3"
            end
        end

        render_test("references/library/stack-horizontal.txt") do io
            @render io @Stack {direction=:horizontal, gap=2} begin
                @div "Item 1"
                @div "Item 2"
                @div "Item 3"
            end
        end

        render_test("references/library/stack-alignment.txt") do io
            @render io @Stack {align=:center, justify=:between} begin
                @div "Item 1"
                @div "Item 2"
            end
        end
    end

    @testset "Grid" begin
        render_test("references/library/grid-default.txt") do io
            @render io @Grid {cols=3} begin
                @div "Cell 1"
                @div "Cell 2"
                @div "Cell 3"
            end
        end

        render_test("references/library/grid-responsive.txt") do io
            @render io @Grid {cols=1, sm=2, md=3, lg=4} begin
                @div "Cell 1"
                @div "Cell 2"
                @div "Cell 3"
                @div "Cell 4"
            end
        end

        render_test("references/library/grid-gap.txt") do io
            @render io @Grid {cols=2, gap=8} begin
                @div "Cell 1"
                @div "Cell 2"
            end
        end
    end

    @testset "Section" begin
        render_test("references/library/section-default.txt") do io
            @render io @Section begin
                "Section content"
            end
        end

        render_test("references/library/section-spacing.txt") do io
            @render io begin
                @Section {spacing=:sm} "Small spacing"
                @Section {spacing=:lg} "Large spacing"
            end
        end

        render_test("references/library/section-background.txt") do io
            @render io @Section {background="bg-slate-100"} begin
                "Section with background"
            end
        end
    end
end
