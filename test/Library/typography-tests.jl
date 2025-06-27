using Test
using HypertextTemplates
using HypertextTemplates.Library
using ReferenceTests

@testset "Typography Components" begin
    @testset "Heading" begin
        @test_reference "references/library/heading-levels.txt" begin
            @renderhtml begin
                @Heading {level=1} "Heading 1"
                @Heading {level=2} "Heading 2"
                @Heading {level=3} "Heading 3"
                @Heading {level=4} "Heading 4"
                @Heading {level=5} "Heading 5"
                @Heading {level=6} "Heading 6"
            end
        end

        @test_reference "references/library/heading-sizes.txt" begin
            @renderhtml begin
                @Heading {level=1, size=:base} "Base size H1"
                @Heading {level=1, size=Symbol("5xl")} "5XL size H1"
            end
        end

        @test_reference "references/library/heading-weights.txt" begin
            @renderhtml begin
                @Heading {weight=:normal} "Normal weight"
                @Heading {weight=:medium} "Medium weight"
                @Heading {weight=:bold} "Bold weight"
            end
        end

        @test_reference "references/library/heading-color.txt" begin
            @renderhtml begin
                @Heading {color="text-blue-600"} "Blue heading"
            end
        end
    end

    @testset "Text" begin
        @test_reference "references/library/text-variants.txt" begin
            @renderhtml begin
                @Text {variant=:body} "Body text"
                @Text {variant=:lead} "Lead text"
                @Text {variant=:small} "Small text"
            end
        end

        @test_reference "references/library/text-alignment.txt" begin
            @renderhtml begin
                @Text {align=:left} "Left aligned"
                @Text {align=:center} "Center aligned"
                @Text {align=:right} "Right aligned"
                @Text {align=:justify} "Justified text"
            end
        end

        @test_reference "references/library/text-styling.txt" begin
            @renderhtml begin
                @Text {weight=:semibold, size=:lg} "Large semibold text"
                @Text {color="text-green-600"} "Green text"
            end
        end
    end

    @testset "Link" begin
        @test_reference "references/library/link-variants.txt" begin
            @renderhtml begin
                @Link {href="/page", variant=:default} "Default link"
                @Link {href="/page", variant=:underline} "Underlined link"
                @Link {href="/page", variant=:hover_underline} "Hover underline"
            end
        end

        @test_reference "references/library/link-external.txt" begin
            @renderhtml begin
                @Link {href="https://example.com", external=true} "External link"
            end
        end

        @test_reference "references/library/link-color.txt" begin
            @renderhtml begin
                @Link {href="/page", color="text-purple-600 hover:text-purple-800"} "Purple link"
            end
        end
    end
end
