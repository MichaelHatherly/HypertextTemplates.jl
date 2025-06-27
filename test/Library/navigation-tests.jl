using Test
using HypertextTemplates
using HypertextTemplates.Library
using ReferenceTests

@testset "Navigation Components" begin
    @testset "Breadcrumb" begin
        @test_reference "references/library/breadcrumb-default.txt" begin
            @renderhtml begin
                @Breadcrumb {
                    items=[
                        ("/", "Home"),
                        ("/products", "Products"),
                        ("/products/shoes", "Shoes"),
                    ],
                }
            end
        end

        @test_reference "references/library/breadcrumb-separator.txt" begin
            @renderhtml begin
                @Breadcrumb {items=[("/", "Home"), ("/about", "About")], separator=">"}
            end
        end
    end

    @testset "Pagination" begin
        @test_reference "references/library/pagination-default.txt" begin
            @renderhtml begin
                @Pagination {current=1, total=5}
            end
        end

        @test_reference "references/library/pagination-middle.txt" begin
            @renderhtml begin
                @Pagination {current=5, total=10}
            end
        end

        @test_reference "references/library/pagination-siblings.txt" begin
            @renderhtml begin
                @Pagination {current=10, total=20, siblings=2}
            end
        end

        @test_reference "references/library/pagination-custom-url.txt" begin
            @renderhtml begin
                @Pagination {current=3, total=5, base_url="/page/"}
            end
        end
    end

    @testset "Tabs" begin
        @test_reference "references/library/tabs-default.txt" begin
            @renderhtml begin
                @Tabs {items=[("tab1", "Tab 1"), ("tab2", "Tab 2"), ("tab3", "Tab 3")]}
            end
        end

        @test_reference "references/library/tabs-active.txt" begin
            @renderhtml begin
                @Tabs {
                    items=[
                        ("overview", "Overview"),
                        ("details", "Details"),
                        ("reviews", "Reviews"),
                    ],
                    active="details",
                }
            end
        end
    end
end
