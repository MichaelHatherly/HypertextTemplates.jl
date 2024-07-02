import Pkg
import Pkg.Artifacts
import Clang.Generators
import Clang.Generators.JLLEnvs
import lexbor_jll
import JuliaFormatter

cd(@__DIR__) do
    include_dir = normpath(joinpath(lexbor_jll.artifact_dir, "include"))
    @assert isdir(include_dir)

    options = Generators.load_options(joinpath(@__DIR__, "generator.toml"))

    args = Generators.get_default_args()
    push!(args, "-I$include_dir")

    header_files = [joinpath(include_dir, "lexbor", "html", "html.h")]

    ctx = Generators.create_context(header_files, args, options)

    Generators.build!(ctx, Generators.BUILDSTAGE_NO_PRINTING)

    function rewrite!(e::Expr)
        if Meta.isexpr(e, :function)
            name = e.args[1].args[1]
            if name === :lxb_css_syntax_token
                e.args[1].args[2] = :($(e.args[1].args[2])::Ptr{lxb_css_syntax_tokenizer_t})
            end
        end
        return e
    end

    function rewrite!(dag::Generators.ExprDAG)
        for node in Generators.get_nodes(dag)
            for expr in Generators.get_exprs(node)
                rewrite!(expr)
            end
        end
    end

    rewrite!(ctx.dag)

    Generators.build!(ctx, Generators.BUILDSTAGE_PRINTING_ONLY)
end
