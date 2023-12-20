module HypertextTemplatesCommonMarkExt

import CommonMark
import HypertextTemplates
import TOML

function HypertextTemplates._handle_commonmark_ext(
    ::HypertextTemplates.CommonMarkExtensionType,
    file,
    mod,
    suffix,
)
    if !isfile(file)
        error("markdown template file does not exist: $file")
    end

    parser = CommonMark._init_parser(mod, suffix)
    rule = CommonMark.FrontMatterRule(; toml = TOML.parse)
    CommonMark.enable!(parser, rule)

    ast = open(parser, file)

    frontmatter = CommonMark.frontmatter(ast)
    name = basename(file)
    name, _ = splitext(name)
    name = get(frontmatter, "name", name)

    props = join(get(Vector{String}, frontmatter, "props"), " ")
    props = isempty(props) ? props : " $props"

    str = "<function $name$props>$(html_str(ast))</function>"
    return HypertextTemplates._components_from_str(str, file, mod)
end

# Custom wrapper around CommonMark's HTML writer so that we can enable sourcepos
# which allows us to use goto definition in browsers when dev mode is enabled.
function html_str(ast::CommonMark.Node)
    html = CommonMark.HTML(; sourcepos = true)
    io = IOBuffer()
    env = Dict{String,Any}()
    w = CommonMark.Writer(html, io, env)
    CommonMark.write_html(w, ast)
    return String(take!(io))
end

end
