using Test
using HypertextTemplates
using HypertextTemplates.Library
using ReferenceTests

@testset "Table Components" begin
    @testset "Table" begin
        @test_reference "references/library/table-default.txt" begin
            @renderhtml begin
                @Table begin
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
        end

        @test_reference "references/library/table-striped.txt" begin
            @renderhtml begin
                @Table {striped=true} begin
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
        end

        @test_reference "references/library/table-options.txt" begin
            @renderhtml begin
                @Table {bordered=false, hover=false, compact=true} begin
                    @tbody begin
                        @tr begin
                            @td "Compact table"
                        end
                    end
                end
            end
        end
    end

    @testset "List" begin
        @test_reference "references/library/list-variants.txt" begin
            @renderhtml begin
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

        @test_reference "references/library/list-spacing.txt" begin
            @renderhtml begin
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
