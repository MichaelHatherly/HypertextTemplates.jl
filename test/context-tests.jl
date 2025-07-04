@testset "Context System" begin
    using HypertextTemplates
    using HypertextTemplates.Elements

    # Define test components
    @component function context_reader()
        value = @get_context(:test_key, "default")
        @span $value
    end

    @component function multi_context_reader()
        theme = @get_context(:theme, "light")
        user = @get_context(:user, "guest")
        lang = @get_context(:lang, "en")
        @div begin
            @span {class = "theme"} $theme
            @span {class = "user"} $user
            @span {class = "lang"} $lang
        end
    end

    @component function nested_reader()
        outer = @get_context(:value, "none")
        inner = @get_context(:inner_value, "none")
        @div begin
            @span {class = "outer"} $outer
            @span {class = "inner"} $inner
        end
    end

    @component function child_component()
        value = @get_context(:shared_value, "not_found")
        @p {class = "child"} $value
    end

    @component function parent_component()
        @div {class = "parent"} begin
            @h2 "Parent"
            @<child_component
        end
    end

    @component function type_reader()
        str_val = @get_context(:string_val, "")
        num_val = @get_context(:number_val, 0)
        bool_val = @get_context(:bool_val, false)
        arr_val = @get_context(:array_val, [])
        dict_val = @get_context(:dict_val, Dict())

        @div begin
            @span {id = "str"} $str_val
            @span {id = "num"} $(num_val * 2)
            bool_val && @span {id = "bool"} "true"
            @span {id = "arr"} $(join(arr_val, ","))
            @span {id = "dict"} $(get(dict_val, :key, "none"))
        end
    end

    # This component demonstrates that slots execute in parent context
    @component function wrapper_component()
        @div {class = "wrapper"} @__slot__
    end

    @component function context_slot_reader()
        val = @get_context(:parent_value, "none")
        @span $val
    end

    @component function string_key_reader()
        val = @get_context("string_key", "default")
        @span $val
    end

    @component function user_card()
        user = @get_context(:user, Dict(:name => "Guest", :role => "visitor"))
        theme = @get_context(:theme, "light")

        @div {class = "card card-$theme"} begin
            @h3 $(user[:name])
            @p {class = "role"} $(user[:role])
        end
    end

    @component function app_layout()
        @context {theme = "dark"} begin
            Elements.@main begin
                @context {user = Dict(:name => "Admin", :role => "administrator")} begin
                    @<user_card
                end
            end
        end
    end

    # Tests
    render_test("references/context/basic-with-context.txt") do io
        @render io @context {test_key = "test_value"} begin
            @<context_reader
        end
    end

    render_test("references/context/basic-without-context.txt") do io
        @render io @<context_reader
    end

    render_test("references/context/multiple-values.txt") do io
        @render io @context {theme = "dark", user = "alice", lang = "fr"} begin
            @<multi_context_reader
        end
    end

    render_test("references/context/nested-contexts.txt") do io
        @render io @context {value = "outer", inner_value = "outer_inner"} begin
            @div {id = "outer"} begin
                @<nested_reader
                @context {value = "inner"} begin
                    @div {id = "inner"} @<nested_reader
                end
            end
        end
    end

    render_test("references/context/propagation.txt") do io
        @render io @context {shared_value = "propagated"} begin
            @<parent_component
        end
    end

    render_test("references/context/different-types.txt") do io
        @render io @context {
            string_val = "hello",
            number_val = 42,
            bool_val = true,
            array_val = [1, 2, 3],
            dict_val = Dict(:key => "value"),
        } begin
            @<type_reader
        end
    end

    render_test("references/context/with-slots.txt") do io
        @render io @context {parent_value = "from_parent"} begin
            @<wrapper_component begin
                @<context_slot_reader
            end
        end
    end

    # Additional slot-related tests
    @component function context_setting_component(; inner_value)
        @context {component_ctx = inner_value} begin
            @div {class = "context-setter"} begin
                @span "Component sets: $inner_value"
                @__slot__
            end
        end
    end

    @component function slot_context_reader()
        parent_val = @get_context(:parent_ctx, "no_parent")
        component_val = @get_context(:component_ctx, "no_component")
        @div begin
            @span {class = "parent"} "Parent: $parent_val"
            @span {class = "component"} "Component: $component_val"
        end
    end

    render_test("references/context/slot-parent-priority.txt") do io
        # Test that slot content sees parent context, not component's internal context
        @render io @context {parent_ctx = "parent_value"} begin
            @<context_setting_component {inner_value = "component_value"} begin
                @<slot_context_reader
            end
        end
    end

    @component function nested_slot_component()
        @div {class = "outer"} begin
            @context {outer_ctx = "outer"} begin
                @__slot__ outer
                @div {class = "middle"} begin
                    @context {middle_ctx = "middle"} begin
                        @__slot__ middle
                        @div {class = "inner"} begin
                            @context {inner_ctx = "inner"} begin
                                @__slot__ inner
                            end
                        end
                    end
                end
            end
        end
    end

    @component function multi_context_reader_2()
        outer = @get_context(:outer_ctx, "missing")
        middle = @get_context(:middle_ctx, "missing")
        inner = @get_context(:inner_ctx, "missing")
        parent = @get_context(:parent_ctx, "missing")
        @span "[$parent|$outer|$middle|$inner]"
    end

    render_test("references/context/nested-slots-context.txt") do io
        # Test context visibility in deeply nested slots
        @render io @context {parent_ctx = "parent"} begin
            @<nested_slot_component begin
                outer := @<multi_context_reader_2
                middle := @<multi_context_reader_2
                inner := @<multi_context_reader_2
            end
        end
    end

    @component function conditional_context_component(; show_context = true)
        @div begin
            if show_context
                @context {conditional = "visible"} begin
                    @__slot__
                end
            else
                @__slot__
            end
        end
    end

    @component function conditional_reader()
        val = @get_context(:conditional, "not_set")
        @span $val
    end

    render_test("references/context/conditional-context-true.txt") do io
        @render io @<conditional_context_component {show_context = true} begin
            @<conditional_reader
        end
    end

    render_test("references/context/conditional-context-false.txt") do io
        @render io @<conditional_context_component {show_context = false} begin
            @<conditional_reader
        end
    end

    @component function multiple_slot_contexts()
        @div begin
            @context {slot_name = "first"} begin
                @div {class = "first"} @__slot__ first
            end
            @context {slot_name = "second"} begin
                @div {class = "second"} @__slot__ second
            end
        end
    end

    @component function slot_name_reader()
        name = @get_context(:slot_name, "default")
        @span $name
    end

    render_test("references/context/multiple-named-slots.txt") do io
        @render io @<multiple_slot_contexts begin
            first := @<slot_name_reader
            second := @<slot_name_reader
        end
    end

    # Test context override behavior with slots
    @component function override_test_component()
        @context {shared_key = "component_value"} begin
            @div begin
                @span {class = "component-direct"} $(@get_context(:shared_key, "none"))
                @__slot__
            end
        end
    end

    @component function override_reader()
        val = @get_context(:shared_key, "none")
        @span {class = "slot-content"} $val
    end

    render_test("references/context/slot-override-context.txt") do io
        # Parent context should be visible in slot, not component's context
        @render io @context {shared_key = "parent_value"} begin
            @<override_test_component begin
                @<override_reader
            end
        end
    end

    # Test dynamic context values
    @component function dynamic_context_component(; ctx_value)
        @context {dynamic = ctx_value * 2} begin
            @div @__slot__
        end
    end

    @component function dynamic_reader()
        val = @get_context(:dynamic, 0)
        @span "Value: $val"
    end

    render_test("references/context/dynamic-context-value.txt") do io
        @render io @<dynamic_context_component {ctx_value = 21} begin
            @<dynamic_reader
        end
    end

    render_test("references/context/string-key.txt") do io
        @render io @context {string_key = "string_value"} begin
            @<string_key_reader
        end
    end

    render_test("references/context/complex-nested.txt") do io
        @render io @<app_layout
    end

    @testset "Missing context without default" begin
        # This one tests error handling, so we can't use render_test
        @component function no_default_reader()
            try
                val = @get_context(:missing_key)
                @span "Found: $val"
            catch e
                @span "Error: $(e.msg)"
            end
        end

        result = @render @<no_default_reader
        @test contains(result, "Error: Context key `missing_key` not found.")
    end

    # Shorthand syntax tests
    @component function shorthand_reader()
        val = @get_context(:theme, "none")
        @span $val
    end

    @component function multi_shorthand_reader()
        user_val = @get_context(:user, "none")
        locale_val = @get_context(:locale, "none")
        @div begin
            @span {id = "user"} $user_val
            @span {id = "locale"} $locale_val
        end
    end

    @component function mixed_syntax_reader()
        theme_val = @get_context(:theme, "none")
        mode_val = @get_context(:mode, "none")
        @div begin
            @span {id = "theme"} $theme_val
            @span {id = "mode"} $mode_val
        end
    end

    render_test("references/context/shorthand-single.txt") do io
        theme = "dark"
        @render io @context {theme} begin
            @<shorthand_reader
        end
    end

    render_test("references/context/shorthand-multiple.txt") do io
        user = "alice"
        locale = "en-US"
        @render io @context {user, locale} begin
            @<multi_shorthand_reader
        end
    end

    render_test("references/context/shorthand-mixed.txt") do io
        theme = "blue"
        @render io @context {theme, mode = "compact"} begin
            @<mixed_syntax_reader
        end
    end
end
