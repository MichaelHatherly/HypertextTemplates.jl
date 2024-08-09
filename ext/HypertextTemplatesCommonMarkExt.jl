module HypertextTemplatesCommonMarkExt

import CommonMark as CM
import HypertextTemplates
import MacroTools
import TOML

function HypertextTemplates.escape_html(io::IO, md::CM.Node, revise)
    html = if HypertextTemplates._should_render_data_htloc(io)
        source = get(md.meta, "source", "")
        isjulia = endswith(source, ".jl")
        # Line offsets only apply to markdown embedded in Julia source files.
        # If it is from a markdown file then offsets do not make sense.
        offset = isjulia ? HypertextTemplates._compute_dynamic_line_offset(revise) : 0
        function sourcepos(pos)
            line = pos[1][1]
            if line > 0 && isfile(source)
                return "data-htloc" => "$(source):$(line + offset)"
            else
                return nothing
            end
        end
        CM.html(md; sourcepos)
    else
        CM.html(md)
    end
    print(io, strip(html))
end

function HypertextTemplates._cm_file_expr(
    mod::Module,
    file::HypertextTemplates.CMFile,
    ::Nothing,
)
    ji = CM.JuliaInterpolationRule()
    parser = CM._init_parser(file.mod, "jmd")
    CM.enable!(parser, ji)

    CM.enable!(parser, CM.FrontMatterRule(toml = TOML.parse))

    text = read(file.file, String)
    ast = parser(text; source = file.file, line = 1)

    parameters = file.parameters

    expr = Expr(:block, :(values = []))
    for v in ji.captured
        push!(expr.args, :(
            let x = $(v.ex)
                push!(values, x)
            end
        ))
    end
    push!(expr.args, :($(CM)._interp!($ast, $(ji.captured), values)))

    line, component_expr = @__LINE__() + 2,
    quote
        $(HypertextTemplates).@component function $(file.name)(; $(parameters...))
            $(HypertextTemplates).@text $(expr)
        end
    end

    # Rewrite line numbers within the function expression such that the
    # `functionloc` of this function matches the definition location rather
    # than the `quote` location.
    return MacroTools.postwalk(component_expr) do each
        if isa(each, LineNumberNode) &&
           String(each.file) == @__FILE__() &&
           each.line == line
            return LineNumberNode(1, file.file)
        else
            return each
        end
    end
end

end
