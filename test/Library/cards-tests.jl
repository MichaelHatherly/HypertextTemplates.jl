using Test
using HypertextTemplates
using HypertextTemplates.Library
using ReferenceTests

@testset "Card Components" begin
    @testset "Card" begin
        @test_reference "references/library/card-default.txt" begin
            @renderhtml begin
                @Card begin
                    "Card content"
                end
            end
        end

        @test_reference "references/library/card-padding.txt" begin
            @renderhtml begin
                @Card {padding=:none} "No padding"
                @Card {padding=:sm} "Small padding"
                @Card {padding=:lg} "Large padding"
            end
        end

        @test_reference "references/library/card-shadow.txt" begin
            @renderhtml begin
                @Card {shadow=:none} "No shadow"
                @Card {shadow=:md} "Medium shadow"
                @Card {shadow=:lg} "Large shadow"
            end
        end

        @test_reference "references/library/card-options.txt" begin
            @renderhtml begin
                @Card {border=false} "No border"
                @Card {rounded=:none} "No rounded corners"
                @Card {rounded=:sm} "Small rounded corners"
            end
        end
    end

    @testset "Badge" begin
        @test_reference "references/library/badge-variants.txt" begin
            @renderhtml begin
                @Badge {variant=:default} "Default"
                @Badge {variant=:primary} "Primary"
                @Badge {variant=:success} "Success"
                @Badge {variant=:warning} "Warning"
                @Badge {variant=:danger} "Danger"
            end
        end

        @test_reference "references/library/badge-sizes.txt" begin
            @renderhtml begin
                @Badge {size=:sm} "Small"
                @Badge {size=:md} "Medium"
                @Badge {size=:lg} "Large"
            end
        end

        @test_reference "references/library/badge-custom.txt" begin
            @renderhtml begin
                @Badge {class="custom-class", id="my-badge"} "Custom Badge"
            end
        end
    end
end
