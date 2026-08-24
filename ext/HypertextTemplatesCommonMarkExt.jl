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
        # The cached form, so a page with many markdown components resolves
        # each component's offset once per render rather than once per node.
        offset = isjulia ? HypertextTemplates._dynamic_line_offset(io, revise) : 0
        # `source` is the same for every node in the document, so it is stat'ed
        # once here rather than once inside the callback below, which CommonMark
        # invokes for each node it emits.
        exists = isfile(source)
        function sourcepos(pos)
            line = pos[1][1]
            if line > 0 && exists
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

function HypertextTemplates._parse_cm_content(
    mod::Module,
    content::Symbol,
    file::AbstractString,
)
    ji = CM.JuliaInterpolationRule()
    parser = CM._init_parser(mod, "jmd")
    CM.enable!(parser, ji)

    CM.enable!(parser, CM.FrontMatterRule(toml = TOML.parse))

    text = String(content)
    ast = parser(text; source = file, line = 1)

    expr = Expr(:block, :(values = []))
    for v in ji.captured
        push!(expr.args, :(
            let x = $(v.ex)
                push!(values, x)
            end
        ))
    end
    push!(expr.args, :($(CM)._interp!($ast, $(ji.captured), values)))

    return expr
end

end
