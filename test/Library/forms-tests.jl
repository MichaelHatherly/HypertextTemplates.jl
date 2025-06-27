using Test
using HypertextTemplates
using HypertextTemplates.Library
using ReferenceTests

@testset "Form Components" begin
    @testset "Input" begin
        @test_reference "references/library/input-default.txt" begin
            @renderhtml begin
                @Input {}
            end
        end

        @test_reference "references/library/input-types.txt" begin
            @renderhtml begin
                @Input {type="text", placeholder="Text input"}
                @Input {type="email", placeholder="Email input"}
                @Input {type="password", placeholder="Password input"}
            end
        end

        @test_reference "references/library/input-sizes.txt" begin
            @renderhtml begin
                @Input {size=:sm, placeholder="Small"}
                @Input {size=:md, placeholder="Medium"}
                @Input {size=:lg, placeholder="Large"}
            end
        end

        @test_reference "references/library/input-states.txt" begin
            @renderhtml begin
                @Input {state=:default, placeholder="Default"}
                @Input {state=:error, placeholder="Error"}
                @Input {state=:success, placeholder="Success"}
            end
        end

        @test_reference "references/library/input-options.txt" begin
            @renderhtml begin
                @Input {name="username", value="john_doe", required=true}
                @Input {disabled=true, placeholder="Disabled"}
                @Input {icon="<svg><path/></svg>", placeholder="With icon"}
            end
        end
    end

    @testset "Textarea" begin
        @test_reference "references/library/textarea-default.txt" begin
            @renderhtml begin
                @Textarea {placeholder="Enter text..."}
            end
        end

        @test_reference "references/library/textarea-options.txt" begin
            @renderhtml begin
                @Textarea {rows=6, resize=:none, placeholder="No resize"}
                @Textarea {state=:error, value="Error state"}
            end
        end
    end

    @testset "Select" begin
        @test_reference "references/library/select-default.txt" begin
            @renderhtml begin
                @Select {
                    options=[("value1", "Option 1"), ("value2", "Option 2")],
                    placeholder="Choose an option",
                }
            end
        end

        @test_reference "references/library/select-states.txt" begin
            @renderhtml begin
                @Select {options=[("a", "A"), ("b", "B")], value="a", state=:success}
            end
        end
    end

    @testset "Checkbox" begin
        @test_reference "references/library/checkbox-default.txt" begin
            @renderhtml begin
                @Checkbox {}
                @Checkbox {label="With label"}
            end
        end

        @test_reference "references/library/checkbox-options.txt" begin
            @renderhtml begin
                @Checkbox {size=:sm, label="Small", checked=true}
                @Checkbox {size=:lg, label="Large", color=:success}
                @Checkbox {disabled=true, label="Disabled"}
            end
        end
    end

    @testset "Radio" begin
        @test_reference "references/library/radio-default.txt" begin
            @renderhtml begin
                @Radio {
                    name="choice",
                    options=[("opt1", "Option 1"), ("opt2", "Option 2")],
                    value="opt1",
                }
            end
        end

        @test_reference "references/library/radio-styling.txt" begin
            @renderhtml begin
                @Radio {
                    name="size",
                    size=:lg,
                    color=:success,
                    options=[("s", "Small"), ("m", "Medium"), ("l", "Large")],
                }
            end
        end
    end

    @testset "FormGroup" begin
        @test_reference "references/library/formgroup-default.txt" begin
            @renderhtml begin
                @FormGroup {label="Email"} begin
                    @Input {type="email"}
                end
            end
        end

        @test_reference "references/library/formgroup-complete.txt" begin
            @renderhtml begin
                @FormGroup {
                    label="Username",
                    help="Choose a unique username",
                    required=true,
                } begin
                    @Input {}
                end

                @FormGroup {label="Password", error="Password is too short"} begin
                    @Input {type="password", state=:error}
                end
            end
        end
    end
end
