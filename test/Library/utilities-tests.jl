using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Utility Components" begin
    @testset "Divider" begin
        render_test("references/library/divider-horizontal.txt") do io
            @render io begin
                @div "Content above"
                @Divider {}
                @div "Content below"
            end
        end

        render_test("references/library/divider-vertical.txt") do io
            @render io @div {class="flex items-center"} begin
                @span "Left"
                @Divider {orientation=:vertical}
                @span "Right"
            end
        end

        render_test("references/library/divider-custom.txt") do io
            @render io @Divider {spacing="my-8", color="border-red-500"}
        end
    end

    @testset "Avatar" begin
        render_test("references/library/avatar-default.txt") do io
            @render io @Avatar {}
        end

        render_test("references/library/avatar-image.txt") do io
            @render io @Avatar {src="/user.jpg", alt="User profile"}
        end

        render_test("references/library/avatar-sizes.txt") do io
            @render io begin
                @Avatar {size=:xs, fallback="XS"}
                @Avatar {size=:sm, fallback="S"}
                @Avatar {size=:md, fallback="M"}
                @Avatar {size=:lg, fallback="L"}
                @Avatar {size=:xl, fallback="XL"}
            end
        end

        render_test("references/library/avatar-shape.txt") do io
            @render io begin
                @Avatar {shape=:circle, fallback="C"}
                @Avatar {shape=:square, fallback="S"}
            end
        end
    end

    @testset "Icon" begin
        render_test("references/library/icon-default.txt") do io
            @render io @Icon {} begin
                HypertextTemplates.SafeString("<svg><path/></svg>")
            end
        end

        render_test("references/library/icon-builtin.txt") do io
            @render io begin
                @Icon {name="check"}
                @Icon {name="x"}
                @Icon {name="arrow-right"}
                @Icon {name="menu"}
            end
        end

        render_test("references/library/icon-sizes.txt") do io
            @render io begin
                @Icon {name="search", size=:xs}
                @Icon {name="search", size=:sm}
                @Icon {name="search", size=:md}
                @Icon {name="search", size=:lg}
                @Icon {name="search", size=:xl}
            end
        end

        render_test("references/library/icon-color.txt") do io
            @render io begin
                @Icon {name="plus", color="text-green-600"}
                @Icon {name="minus", color="text-red-600"}
            end
        end
    end
end
