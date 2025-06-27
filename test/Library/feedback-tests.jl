using Test
using HypertextTemplates
using HypertextTemplates.Library
using ReferenceTests

@testset "Feedback Components" begin
    @testset "Alert" begin
        @test_reference "references/library/alert-variants.txt" begin
            @renderhtml begin
                @Alert {variant=:info} "Information message"
                @Alert {variant=:success} "Success message"
                @Alert {variant=:warning} "Warning message"
                @Alert {variant=:error} "Error message"
            end
        end

        @test_reference "references/library/alert-dismissible.txt" begin
            @renderhtml begin
                @Alert {variant=:info, dismissible=true} begin
                    "This alert can be dismissed"
                end
            end
        end

        @test_reference "references/library/alert-content.txt" begin
            @renderhtml begin
                @Alert {variant=:warning} begin
                    @p {class="font-semibold"} "Warning!"
                    @p "Please check your input."
                end
            end
        end
    end

    @testset "Progress" begin
        @test_reference "references/library/progress-default.txt" begin
            @renderhtml begin
                @Progress {value=50}
            end
        end

        @test_reference "references/library/progress-sizes.txt" begin
            @renderhtml begin
                @Progress {value=25, size=:sm}
                @Progress {value=50, size=:md}
                @Progress {value=75, size=:lg}
            end
        end

        @test_reference "references/library/progress-colors.txt" begin
            @renderhtml begin
                @Progress {value=30, color=:slate}
                @Progress {value=60, color=:primary}
                @Progress {value=90, color=:success}
            end
        end

        @test_reference "references/library/progress-options.txt" begin
            @renderhtml begin
                @Progress {value=70, striped=true}
                @Progress {value=40, label="Loading..."}
            end
        end
    end

    @testset "Spinner" begin
        @test_reference "references/library/spinner-default.txt" begin
            @renderhtml begin
                @Spinner {}
            end
        end

        @test_reference "references/library/spinner-sizes.txt" begin
            @renderhtml begin
                @Spinner {size=:sm}
                @Spinner {size=:md}
                @Spinner {size=:lg}
            end
        end

        @test_reference "references/library/spinner-colors.txt" begin
            @renderhtml begin
                @Spinner {color=:slate}
                @Spinner {color=:primary}
                @Spinner {color=:white}
            end
        end
    end
end
