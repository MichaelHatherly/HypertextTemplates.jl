using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Navigation Components" begin
    @testset "Breadcrumb" begin
        render_test("references/library/breadcrumb-default.txt") do io
            @render io @Breadcrumb {
                items=[
                    ("/", "Home"),
                    ("/products", "Products"),
                    ("/products/shoes", "Shoes"),
                ],
            }
        end

        render_test("references/library/breadcrumb-separator.txt") do io
            @render io @Breadcrumb {items=[("/", "Home"), ("/about", "About")], separator=">"}
        end
    end

    @testset "Pagination" begin
        render_test("references/library/pagination-default.txt") do io
            @render io @Pagination {current=1, total=5}
        end

        render_test("references/library/pagination-middle.txt") do io
            @render io @Pagination {current=5, total=10}
        end

        render_test("references/library/pagination-siblings.txt") do io
            @render io @Pagination {current=10, total=20, siblings=2}
        end

        render_test("references/library/pagination-custom-url.txt") do io
            @render io @Pagination {current=3, total=5, base_url="/page/"}
        end
    end

    @testset "Tabs" begin
        render_test("references/library/tabs-default.txt") do io
            @render io @Tabs {items=[("tab1", "Tab 1"), ("tab2", "Tab 2"), ("tab3", "Tab 3")]}
        end

        render_test("references/library/tabs-active.txt") do io
            @render io @Tabs {
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
