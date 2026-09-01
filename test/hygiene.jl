@testset "Macro Hygiene" begin
    # The macro that `@deftag` generates is defined in, and expands in, the
    # caller's module, so a caller that defines a binding named `esc`,
    # `Expr`, `GlobalRef` or `Symbol` used to break every tag macro in
    # their module. Importing the package under another name, without
    # `using` it, used to fail for the same reason.
    cases = [
        "esc" => """
            module HygieneEsc
            using HypertextTemplates, HypertextTemplates.Elements
            esc = "shadowed"
            @component function w(; n)
                @div \$n
            end
            @deftag macro w end
            run() = @render @w {n = 1}
            end
            HygieneEsc.run()
        """,
        "Expr" => """
            module HygieneExpr
            using HypertextTemplates, HypertextTemplates.Elements
            Expr = "shadowed"
            @component function w(; n)
                @div \$n
            end
            @deftag macro w end
            run() = @render @w {n = 1}
            end
            HygieneExpr.run()
        """,
        "GlobalRef" => """
            module HygieneGlobalRef
            using HypertextTemplates, HypertextTemplates.Elements
            GlobalRef = "shadowed"
            @component function w(; n)
                @div \$n
            end
            @deftag macro w end
            run() = @render @w {n = 1}
            end
            HygieneGlobalRef.run()
        """,
        "Symbol" => """
            module HygieneSymbol
            using HypertextTemplates, HypertextTemplates.Elements
            Symbol = "shadowed"
            @component function w(; n)
                @div \$n
            end
            @deftag macro w end
            run() = @render @w {n = 1}
            end
            HygieneSymbol.run()
        """,
    ]
    for (shadowed, code) in cases
        @testset "shadowed `$shadowed`" begin
            @test include_string(Main, code) == "<div>1</div>"
        end
    end
    # `@element` goes through the same code path as `@component`.
    @test include_string(
        Main,
        """
        module HygieneElement
        using HypertextTemplates
        esc = "shadowed"
        @element "my-widget" my_widget
        @deftag macro my_widget end
        run() = @render @my_widget {id = "a"} "x"
        end
        HygieneElement.run()
        """,
    ) == "<my-widget id=\"a\">x</my-widget>"
    # The package need not be in scope under its own name.
    @test include_string(
        Main,
        """
        module HygieneRenamed
        import HypertextTemplates as HTT
        import HypertextTemplates.Elements as E
        HTT.@component function w(; n)
            E.@div \$n
        end
        HTT.@deftag macro w end
        run() = HTT.@render @w {n = 1}
        end
        HygieneRenamed.run()
        """,
    ) == "<div>1</div>"
end
