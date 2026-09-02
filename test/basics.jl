@testitem "element rendering" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements
    import HypertextTemplates.Elements: @time

    render_test("references/basics/html-elements.txt") do io
        @render io @html {lang = "en"} begin
            @head begin
                @meta {charset = "UTF-8"}
                @meta {name = "viewport", content = "width=device-width"}
                @title "Document title"
            end
            @body begin
                @header begin
                    @a {href = "#", class = "logo"} "Page Header"
                end
                @article begin
                    @header begin
                        @h1 "Article Title"
                        @time "01/01/2000"
                    end
                    # Test that `@text` works on non-string-literals.
                    content = "Content goes here."
                    @p @text content
                end
            end
        end
    end
    render_test("references/basics/prop_names.txt") do io
        # Supports both `=` and `:=` as property syntax since literal strings
        # raise warnings in LSPs, but we want to use the string syntax to support
        # property names that are not valid Julia syntax.
        @render io @div {"data-custom-prop" := true, hidden_prop = false}
    end
    render_test("references/basics/attribute-escaping.txt") do io
        # Literal strings are always marked as safe and are not
        # escaped. Anything that is added to an element as a variable,
        # that is potentially user-provided is escaped.
        class = "<script></script>"
        pre_escaped = SafeString("<script></script>")
        unsafe = "\"'"
        @render io @div {
            unsafe,
            class,
            unescaped = "<script></script>",
            pre = pre_escaped,
            interpolated = "\"$("\"")",
        }
    end
    render_test("references/basics/custom-elements.txt") do io
        @render io @div begin
            @custom_element {prop = "value"} begin
                @strong "content"
            end
        end
    end
    render_test("references/basics/looping.txt") do io
        @render io @ul begin
            for each in [1, 2, 3, 4]
                @li {id = each} @text each
            end
        end
    end
    render_test("references/basics/non-standard-prop-names.txt") do io
        @render io @div {"x-data" := "{ open: false }"} begin
            @button {"@click" := "open = true"} "Expand"
            @span {"x-show" := "open"} "Content..."
        end
    end
end

@testitem "component rendering" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    render_test("references/basics/custom-components.txt") do io
        @render io @custom_component {prop = "class-name"}
    end
    render_test("references/basics/nested-custom-components.txt") do io
        @render io @nested_component {prop = "class-name", captured = "captured"}
    end
    render_test("references/basics/component-slots.txt") do io
        @render io @slot_component begin
            named := @p "named slot content"
            @p "slot content"
        end
    end
    render_test("references/basics/conditional-component.txt") do io
        @render io @div begin
            @conditional_component {show = true}
            @conditional_component {show = false}
        end
    end
    render_test("references/basics/commonmark-component.txt") do io
        @render io @commonmark_component
    end
end

@testitem "a slot the caller did not pass" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    @component function needs_heading()
        @div @__slot__ heading
    end

    function message(f)
        try
            f()
            return nothing
        catch error
            return isa(error, ErrorException) ? error.msg : rethrow()
        end
    end

    # Every call site passes a default slot, so the message reports the named
    # slots the caller wrote and stays quiet about the one it did not.
    @test message(() -> @render @<needs_heading) ==
        "component `needs_heading` has no slot named `heading`: no named slots were passed."
    @test message(
        () -> @render @<needs_heading begin
            footing := @p "content"
        end
    ) ==
        "component `needs_heading` has no slot named `heading`: the named slots passed were `footing`."
    # Content written for the default slot is still not a named slot.
    @test message(() -> @render @<needs_heading "content") ==
        "component `needs_heading` has no slot named `heading`: no named slots were passed."
end

@testitem "tags used outside a render" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    # `@deftag` splices the element or component itself into the `@<` call, so
    # the name the message reports has to come back off that value rather than
    # off the expression the template wrote.
    function message(f)
        try
            f()
            return nothing
        catch error
            return isa(error, ErrorException) ? error.msg : rethrow()
        end
    end

    @test message(() -> @div "content") ==
        "`@div` and `@<div` cannot be used outside of a `@render` or `@component` macro."
    @test message(() -> @custom_element) ==
        "`@custom-element` and `@<custom-element` cannot be used outside of a `@render` or `@component` macro."
    @test message(() -> @custom_component) ==
        "`@custom_component` and `@<custom_component` cannot be used outside of a `@render` or `@component` macro."
end

@testitem "render root" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    function render_function()
        @__LINE__, @render @div begin
                @conditional_component {show = true}
                @conditional_component {show = false}
            end
    end
    line, html = render_function()
    @test contains(html, "data-htroot=\"$(@__FILE__):$(line)")
    @test contains(html, "data-htloc=\"$(@__FILE__):$(line)")
end

@testitem "output types" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    result = @render @p "content"
    @test isa(result, String)
    result_bytes = @render Vector{UInt8} @p "content"
    @test isa(result_bytes, Vector{UInt8})
end

@testitem "call site source information" tags = [:core] setup = [Templates] begin
    using HypertextTemplates.Elements

    line = @__LINE__
    file = @__FILE__
    result = @render @p "content"
    @test contains(result, "data-htloc=\"$file:$(line + 2)\"")
end
