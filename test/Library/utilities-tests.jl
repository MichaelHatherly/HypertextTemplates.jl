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

    @testset "ThemeToggle" begin
        render_test("references/library/theme-toggle-default.txt") do io
            @render io @ThemeToggle {}
        end

        render_test("references/library/theme-toggle-custom.txt") do io
            @render io @ThemeToggle {
                variant = :ghost,
                size = :sm,
                show_label = false,
                id = "custom-toggle",
            }
        end
    end

    @testset "Tooltip" begin
        render_test("references/library/tooltip-default.txt") do io
            @render io @Tooltip {text = "Hello tooltip"} begin
                @button "Hover me"
            end
        end

        render_test("references/library/tooltip-placements.txt") do io
            @render io begin
                @Tooltip {text = "Top tooltip", placement = :top} begin
                    @button "Top"
                end
                @Tooltip {text = "Bottom tooltip", placement = :bottom} begin
                    @button "Bottom"
                end
                @Tooltip {text = "Left tooltip", placement = :left} begin
                    @button "Left"
                end
                @Tooltip {text = "Right tooltip", placement = :right} begin
                    @button "Right"
                end
            end
        end

        render_test("references/library/tooltip-variants.txt") do io
            @render io begin
                @Tooltip {text = "Dark tooltip", variant = :dark} begin
                    @span "Dark"
                end
                @Tooltip {text = "Light tooltip", variant = :light} begin
                    @span "Light"
                end
            end
        end

        render_test("references/library/tooltip-delays.txt") do io
            @render io begin
                @Tooltip {text = "No delay", delay = 0} begin
                    @button "Instant"
                end
                @Tooltip {text = "Long delay", delay = 1000} begin
                    @button "Slow"
                end
            end
        end
    end

    @testset "TooltipWrapper" begin
        render_test("references/library/tooltip-wrapper-basic.txt") do io
            @render io @TooltipWrapper {} begin
                @TooltipTrigger begin
                    @button "Click for info"
                end
                @TooltipContent begin
                    @div "This is the tooltip content"
                end
            end
        end

        render_test("references/library/tooltip-wrapper-interactive.txt") do io
            @render io @TooltipWrapper {
                interactive = true,
                trigger = :click,
                placement = :right,
            } begin
                @TooltipTrigger begin
                    @span "Click me"
                end
                @TooltipContent {variant = :light} begin
                    @div begin
                        @h4 "Interactive Tooltip"
                        @p "This tooltip stays open when you hover over it."
                    end
                end
            end
        end
    end
end
