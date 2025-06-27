using Test
using HypertextTemplates
using HypertextTemplates.Library
using ReferenceTests

@testset "Utility Components" begin
    @testset "Divider" begin
        @test_reference "references/library/divider-horizontal.txt" begin
            @renderhtml begin
                @div "Content above"
                @Divider {}
                @div "Content below"
            end
        end

        @test_reference "references/library/divider-vertical.txt" begin
            @renderhtml begin
                @div {class="flex items-center"} begin
                    @span "Left"
                    @Divider {orientation=:vertical}
                    @span "Right"
                end
            end
        end

        @test_reference "references/library/divider-custom.txt" begin
            @renderhtml begin
                @Divider {spacing="my-8", color="border-red-500"}
            end
        end
    end

    @testset "Avatar" begin
        @test_reference "references/library/avatar-default.txt" begin
            @renderhtml begin
                @Avatar {}
            end
        end

        @test_reference "references/library/avatar-image.txt" begin
            @renderhtml begin
                @Avatar {src="/user.jpg", alt="User profile"}
            end
        end

        @test_reference "references/library/avatar-sizes.txt" begin
            @renderhtml begin
                @Avatar {size=:xs, fallback="XS"}
                @Avatar {size=:sm, fallback="S"}
                @Avatar {size=:md, fallback="M"}
                @Avatar {size=:lg, fallback="L"}
                @Avatar {size=:xl, fallback="XL"}
            end
        end

        @test_reference "references/library/avatar-shape.txt" begin
            @renderhtml begin
                @Avatar {shape=:circle, fallback="C"}
                @Avatar {shape=:square, fallback="S"}
            end
        end
    end

    @testset "Icon" begin
        @test_reference "references/library/icon-default.txt" begin
            @renderhtml begin
                @Icon {} begin
                    HypertextTemplates.SafeString("<svg><path/></svg>")
                end
            end
        end

        @test_reference "references/library/icon-builtin.txt" begin
            @renderhtml begin
                @Icon {name="check"}
                @Icon {name="x"}
                @Icon {name="arrow-right"}
                @Icon {name="menu"}
            end
        end

        @test_reference "references/library/icon-sizes.txt" begin
            @renderhtml begin
                @Icon {name="search", size=:xs}
                @Icon {name="search", size=:sm}
                @Icon {name="search", size=:md}
                @Icon {name="search", size=:lg}
                @Icon {name="search", size=:xl}
            end
        end

        @test_reference "references/library/icon-color.txt" begin
            @renderhtml begin
                @Icon {name="plus", color="text-green-600"}
                @Icon {name="minus", color="text-red-600"}
            end
        end
    end
end
