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

    str = "<function $name$props>$(CommonMark.html(ast))</function>"
    return HypertextTemplates._components_from_str(str, file, mod)
end

function format_prop(k) end

end
