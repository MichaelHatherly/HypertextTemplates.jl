using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Card Components" begin
    @testset "Card" begin
        render_test("references/library/card-default.txt") do io
            @render io @Card begin
                "Card content"
            end
        end

        render_test("references/library/card-padding.txt") do io
            @render io begin
                @Card {padding=:none} "No padding"
                @Card {padding=:sm} "Small padding"
                @Card {padding=:lg} "Large padding"
            end
        end

        render_test("references/library/card-shadow.txt") do io
            @render io begin
                @Card {shadow=:none} "No shadow"
                @Card {shadow=:md} "Medium shadow"
                @Card {shadow=:lg} "Large shadow"
            end
        end

        render_test("references/library/card-options.txt") do io
            @render io begin
                @Card {border=false} "No border"
                @Card {rounded=:none} "No rounded corners"
                @Card {rounded=:sm} "Small rounded corners"
            end
        end
    end

    @testset "Badge" begin
        render_test("references/library/badge-variants.txt") do io
            @render io begin
                @Badge {variant=:default} "Default"
                @Badge {variant=:primary} "Primary"
                @Badge {variant=:success} "Success"
                @Badge {variant=:warning} "Warning"
                @Badge {variant=:danger} "Danger"
            end
        end

        render_test("references/library/badge-sizes.txt") do io
            @render io begin
                @Badge {size=:sm} "Small"
                @Badge {size=:md} "Medium"
                @Badge {size=:lg} "Large"
            end
        end

        render_test("references/library/badge-custom.txt") do io
            @render io @Badge {class="custom-class", id="my-badge"} "Custom Badge"
        end
    end
end
