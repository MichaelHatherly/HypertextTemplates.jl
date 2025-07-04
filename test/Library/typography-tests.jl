using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Typography Components" begin
    @testset "Heading" begin
        render_test("references/library/heading-levels.txt") do io
            @render io begin
                @Heading {level=1} "Heading 1"
                @Heading {level=2} "Heading 2"
                @Heading {level=3} "Heading 3"
                @Heading {level=4} "Heading 4"
                @Heading {level=5} "Heading 5"
                @Heading {level=6} "Heading 6"
            end
        end

        render_test("references/library/heading-sizes.txt") do io
            @render io begin
                @Heading {level=1, size=:base} "Base size H1"
                @Heading {level=1, size=Symbol("5xl")} "5XL size H1"
            end
        end

        render_test("references/library/heading-weights.txt") do io
            @render io begin
                @Heading {weight=:normal} "Normal weight"
                @Heading {weight=:medium} "Medium weight"
                @Heading {weight=:bold} "Bold weight"
            end
        end

        render_test("references/library/heading-color.txt") do io
            @render io @Heading {color="text-blue-600"} "Blue heading"
        end
    end

    @testset "Text" begin
        render_test("references/library/text-variants.txt") do io
            @render io begin
                @Text {variant=:body} "Body text"
                @Text {variant=:lead} "Lead text"
                @Text {variant=:small} "Small text"
            end
        end

        render_test("references/library/text-alignment.txt") do io
            @render io begin
                @Text {align=:left} "Left aligned"
                @Text {align=:center} "Center aligned"
                @Text {align=:right} "Right aligned"
                @Text {align=:justify} "Justified text"
            end
        end

        render_test("references/library/text-styling.txt") do io
            @render io begin
                @Text {weight=:semibold, size=:lg} "Large semibold text"
                @Text {color="text-green-600"} "Green text"
            end
        end
    end

    @testset "Link" begin
        render_test("references/library/link-variants.txt") do io
            @render io begin
                @Link {href="/page", variant=:default} "Default link"
                @Link {href="/page", variant=:underline} "Underlined link"
                @Link {href="/page", variant=:hover_underline} "Hover underline"
            end
        end

        render_test("references/library/link-external.txt") do io
            @render io @Link {href="https://example.com", external=true} "External link"
        end

        render_test("references/library/link-color.txt") do io
            @render io @Link {href="/page", color="text-purple-600 hover:text-purple-800"} "Purple link"
        end
    end
end
