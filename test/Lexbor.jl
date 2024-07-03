using Test, HypertextTemplates, AbstractTrees

@testset "Lexbor" begin
    html_templates = String[]
    for (root, _, files) in walkdir(joinpath(@__DIR__, "templates"))
        for file in files
            if endswith(file, ".html")
                push!(html_templates, joinpath(root, file))
            end
        end
    end

    @testset "Basic tokenization" begin
        for file in html_templates
            relfile = relpath(file, @__DIR__)
            @testset "$relfile" begin
                text = read(file, String)
                tokens = HypertextTemplates.Lexbor._token_positions(text)
                @test !isempty(tokens)
            end
        end
    end

    function _token_test(f, file)
        @testset "tokens $file" begin
            fullpath = joinpath(@__DIR__, file)
            str = read(fullpath, String)
            tokens = HypertextTemplates.Lexbor._token_positions(str)
            f(tokens)
        end
    end

    _token_test("templates/basic/slot.html") do tokens
        tag, close, line, col = tokens[1]
        @test tag == "function"
        @test close == false
        @test line == 1
        @test col == 1

        tag, close, line, col = tokens[5]
        @test tag == "h1"
        @test close == false
        @test line == 3
        @test col == 9

        tag, close, line, col = tokens[26]
        @test tag == "p"
        @test close == false
        @test line == 12
        @test col == 13

        tag, close, line, col = tokens[28]
        @test tag == "julia"
        @test close == false
        @test line == 12
        @test col == 30
    end

    _token_test("templates/complex/layouts/base-layout.html") do tokens
        tag, close, line, col = tokens[1]
        @test tag == "!doctype"
        @test close == false
        @test line == 1
        @test col == 1

        tag, close, line, col = tokens[3]
        @test tag == "html"
        @test close == false
        @test line == 2
        @test col == 1

        tag, close, line, col = tokens[14]
        @test tag == "slot"
        @test close == false
        @test line == 7
        @test col == 5
    end

    @testset "Parsing" begin
        for file in html_templates
            relfile = relpath(file, @__DIR__)
            @testset "$relfile" begin
                text = read(file, String)
                dom = HypertextTemplates.Lexbor.Document(text)
                @test dom.source === nothing
                dom = open(HypertextTemplates.Lexbor.Document, file)
                @test dom.source == file
                @test !isempty(dom.root.children)
            end
        end
    end

    function _node_test(f, file)
        @testset "nodes $file" begin
            dom = open(HypertextTemplates.Lexbor.Document, joinpath(@__DIR__, file))
            @test splitpath(relpath(dom.source, @__DIR__)) == splitpath(file)
            @test !isempty(dom.root.children)
            f(dom)
        end
    end

    function _find_node(f, root)
        for node in AbstractTrees.PostOrderDFS(root)
            f(node) && return node
        end
        return nothing
    end
    function _find_all_nodes(f, root)
        results = []
        for node in AbstractTrees.PostOrderDFS(root)
            f(node) && push!(results, node)
        end
        return results
    end

    function _is_tag(tag)
        f(node::HypertextTemplates.Lexbor.Node) = node.tag == tag
        f(other) = false
        return f
    end

    _node_test("templates/basic/show.html") do doc
        @test doc.root.tag == "#document"
        funcs = _find_all_nodes(_is_tag("function"), doc.root)
        @test length(funcs) == 2

        @test funcs[1].attributes == ["show-example" => nothing, "value" => nothing]
        @test funcs[1].source == (1, 1)
        show = _find_node(_is_tag("show"), funcs[1])
        @test !isnothing(show)
        @test length(show.children) == 2
        @test show.attributes == ["when" => "value == 1"]

        fallback = _find_node(_is_tag("fallback"), funcs[1])
        @test !isnothing(fallback)
        @test length(fallback.children) == 1
        @test fallback.source == (5, 13)

        @test funcs[2].attributes == ["show-example-2" => nothing, "value" => nothing]
        @test funcs[2].source == (12, 1)
        fallback = _find_node(_is_tag("fallback"), funcs[2])
        @test isnothing(fallback)
    end

    _node_test("templates/basic/props.html") do doc
        @test doc.root.tag == "#document"
        funcs = _find_all_nodes(_is_tag("function"), doc.root)
        @test length(funcs) == 4

        @test funcs[1].attributes == ["props-example" => nothing]
        @test funcs[1].source == (1, 1)

        p = _find_node(_is_tag("p"), funcs[1])
        @test !isnothing(p)
        @test p.attributes == ["class" => "bg-blue-300 p-2"]
        @test p.source == (2, 5)

        @test funcs[2].attributes ==
              ["dynamic-props-example" => nothing, "class" => nothing]
        @test funcs[2].source == (5, 1)

        p = _find_node(_is_tag("p"), funcs[2])
        @test !isnothing(p)
        @test p.attributes == [".class" => "class"]
        @test p.source == (6, 5)

        @test funcs[3].attributes ==
              ["dollar-props-example" => nothing, "class" => nothing, "id" => nothing]
        @test funcs[3].source == (9, 1)

        p = _find_node(_is_tag("p"), funcs[3])
        @test !isnothing(p)
        @test p.attributes ==
              ["\$class" => "\$class bg-blue-200", "\$hx-get" => "/contact/\$id/edit"]
        @test p.source == (10, 5)

        @test funcs[4].attributes ==
              ["wrapped-props-example" => nothing, "class" => nothing]
        @test funcs[4].source == (13, 1)

        node = _find_node(_is_tag("dynamic-props-example"), funcs[4])
        @test !isnothing(node)
        @test node.attributes == [".class" => nothing]
        @test node.source == (14, 5)
    end

    _node_test("templates/complex/layouts/base-layout.html") do doc
        @test doc.root.tag == "#document"
        doctype = _find_node(_is_tag("!doctype"), doc.root)
        @test !isnothing(doctype)
        @test doctype.source == (1, 1)

        html = _find_node(_is_tag("html"), doc.root)
        @test !isnothing(html)
        @test length(html.children) == 2
        @test html.source == (2, 1)

        head = _find_node(_is_tag("head"), html)
        @test !isnothing(head)
        @test length(head.children) == 1
        @test head.source == (3, 1)

        body = _find_node(_is_tag("body"), html)
        @test !isnothing(body)
        @test length(body.children) == 1
        @test body.source == (6, 1)

        slot = _find_node(_is_tag("slot"), body)
        @test !isnothing(slot)
        @test length(slot.children) == 0
        @test slot.source == (7, 5)
    end
end
