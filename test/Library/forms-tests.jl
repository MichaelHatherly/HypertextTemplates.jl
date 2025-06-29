using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Form Components" begin
    @testset "Input" begin
        render_test("references/library/input-default.txt") do io
            @render io @Input {}
        end

        render_test("references/library/input-types.txt") do io
            @render io begin
                @Input {type = "text", placeholder = "Text input"}
                @Input {type = "email", placeholder = "Email input"}
                @Input {type = "password", placeholder = "Password input"}
            end
        end

        render_test("references/library/input-sizes.txt") do io
            @render io begin
                @Input {size = :sm, placeholder = "Small"}
                @Input {size = :md, placeholder = "Medium"}
                @Input {size = :lg, placeholder = "Large"}
            end
        end

        render_test("references/library/input-states.txt") do io
            @render io begin
                @Input {state = :default, placeholder = "Default"}
                @Input {state = :error, placeholder = "Error"}
                @Input {state = :success, placeholder = "Success"}
            end
        end

        render_test("references/library/input-options.txt") do io
            @render io begin
                @Input {name = "username", value = "john_doe", required = true}
                @Input {disabled = true, placeholder = "Disabled"}
                @Input {icon = "<svg><path/></svg>", placeholder = "With icon"}
            end
        end
    end

    @testset "Textarea" begin
        render_test("references/library/textarea-default.txt") do io
            @render io @Textarea {placeholder = "Enter text..."}
        end

        render_test("references/library/textarea-options.txt") do io
            @render io begin
                @Textarea {rows = 6, resize = :none, placeholder = "No resize"}
                @Textarea {state = :error, value = "Error state"}
            end
        end
    end

    @testset "Select" begin
        render_test("references/library/select-default.txt") do io
            @render io @Select {
                options = [("value1", "Option 1"), ("value2", "Option 2")],
                placeholder = "Choose an option",
            }
        end

        render_test("references/library/select-states.txt") do io
            @render io @Select {
                options = [("a", "A"), ("b", "B")],
                value = "a",
                state = :success,
            }
        end
    end

    @testset "Checkbox" begin
        render_test("references/library/checkbox-default.txt") do io
            @render io begin
                @Checkbox {}
                @Checkbox {label = "With label"}
            end
        end

        render_test("references/library/checkbox-options.txt") do io
            @render io begin
                @Checkbox {size = :sm, label = "Small", checked = true}
                @Checkbox {size = :lg, label = "Large", color = :success}
                @Checkbox {disabled = true, label = "Disabled"}
            end
        end
    end

    @testset "Radio" begin
        render_test("references/library/radio-default.txt") do io
            @render io @Radio {
                name = "choice",
                options = [("opt1", "Option 1"), ("opt2", "Option 2")],
                value = "opt1",
            }
        end

        render_test("references/library/radio-styling.txt") do io
            @render io @Radio {
                name = "size",
                size = :lg,
                color = :success,
                options = [("s", "Small"), ("m", "Medium"), ("l", "Large")],
            }
        end
    end

    @testset "FormGroup" begin
        render_test("references/library/formgroup-default.txt") do io
            @render io @FormGroup {label = "Email", _hash = 0} begin
                @Input {type = "email"}
            end
        end

        render_test("references/library/formgroup-complete.txt") do io
            @render io begin
                @FormGroup {
                    label = "Username",
                    help = "Choose a unique username",
                    required = true,
                    _hash = 0,
                } begin
                    @Input {}
                end

                @FormGroup {label = "Password", error = "Password is too short", _hash = 0} begin
                    @Input {type = "password", state = :error}
                end
            end
        end
    end
end
