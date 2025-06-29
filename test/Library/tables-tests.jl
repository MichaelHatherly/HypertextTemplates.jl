using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Table Components" begin
    @testset "Table" begin
        render_test("references/library/table-default.txt") do io
            @render io @Table begin
                @thead begin
                    @tr begin
                        @th "Name"
                        @th "Age"
                    end
                end
                @tbody begin
                    @tr begin
                        @td "John"
                        @td "30"
                    end
                    @tr begin
                        @td "Jane"
                        @td "25"
                    end
                end
            end
        end

        render_test("references/library/table-striped.txt") do io
            @render io @Table {striped=true} begin
                @tbody begin
                    @tr begin
                        @td "Row 1"
                    end
                    @tr begin
                        @td "Row 2"
                    end
                    @tr begin
                        @td "Row 3"
                    end
                end
            end
        end

        render_test("references/library/table-options.txt") do io
            @render io @Table {bordered=false, hover=false, compact=true} begin
                @tbody begin
                    @tr begin
                        @td "Compact table"
                    end
                end
            end
        end
    end

    @testset "List" begin
        render_test("references/library/list-variants.txt") do io
            @render io begin
                @List {variant=:bullet} begin
                    @li "Bullet item 1"
                    @li "Bullet item 2"
                end
                @List {variant=:number} begin
                    @li "Number item 1"
                    @li "Number item 2"
                end
                @List {variant=:check} begin
                    @li "Check item 1"
                    @li "Check item 2"
                end
                @List {variant=:none} begin
                    @li "No marker 1"
                    @li "No marker 2"
                end
            end
        end

        render_test("references/library/list-spacing.txt") do io
            @render io begin
                @List {spacing=:tight} begin
                    @li "Tight spacing"
                    @li "Item 2"
                end
                @List {spacing=:loose} begin
                    @li "Loose spacing"
                    @li "Item 2"
                end
            end
        end
    end
end
