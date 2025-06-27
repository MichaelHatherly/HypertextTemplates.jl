using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Feedback Components" begin
    @testset "Alert" begin
        render_test("references/library/alert-variants.txt") do io
            @render io begin
                @Alert {variant=:info} "Information message"
                @Alert {variant=:success} "Success message"
                @Alert {variant=:warning} "Warning message"
                @Alert {variant=:error} "Error message"
            end
        end

        render_test("references/library/alert-dismissible.txt") do io
            @render io @Alert {variant=:info, dismissible=true} begin
                "This alert can be dismissed"
            end
        end

        render_test("references/library/alert-content.txt") do io
            @render io @Alert {variant=:warning} begin
                @p {class="font-semibold"} "Warning!"
                @p "Please check your input."
            end
        end
    end

    @testset "Progress" begin
        render_test("references/library/progress-default.txt") do io
            @render io @Progress {value=50}
        end

        render_test("references/library/progress-sizes.txt") do io
            @render io begin
                @Progress {value=25, size=:sm}
                @Progress {value=50, size=:md}
                @Progress {value=75, size=:lg}
            end
        end

        render_test("references/library/progress-colors.txt") do io
            @render io begin
                @Progress {value=30, color=:slate}
                @Progress {value=60, color=:primary}
                @Progress {value=90, color=:success}
            end
        end

        render_test("references/library/progress-options.txt") do io
            @render io begin
                @Progress {value=70, striped=true}
                @Progress {value=40, label="Loading..."}
            end
        end
    end

    @testset "Spinner" begin
        render_test("references/library/spinner-default.txt") do io
            @render io @Spinner {}
        end

        render_test("references/library/spinner-sizes.txt") do io
            @render io begin
                @Spinner {size=:sm}
                @Spinner {size=:md}
                @Spinner {size=:lg}
            end
        end

        render_test("references/library/spinner-colors.txt") do io
            @render io begin
                @Spinner {color=:slate}
                @Spinner {color=:primary}
                @Spinner {color=:white}
            end
        end
    end
end
