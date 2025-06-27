"""
    HypertextTemplates.Elements

Standard HTML elements for use with HypertextTemplates.

This module provides all standard HTML5 elements as both functions and macros. Each element
can be used either as a macro (e.g., `@div`) or accessed as a function (e.g., `Elements.div`).

# Usage
```julia
using HypertextTemplates, HypertextTemplates.Elements

# Use elements as macros
@render @div {class = "container"} begin
    @h1 "Title"
    @p "Content"
end

# Or access them as values for dynamic rendering
element = rand() > 0.5 ? Elements.div : Elements.span
@render @<element "Dynamic content"
```

# Available Elements
All standard HTML5 elements are available, including:
- Document structure: `html`, `head`, `body`, `div`, `span`
- Text content: `p`, `h1`-`h6`, `blockquote`, `pre`
- Forms: `form`, `input`, `textarea`, `select`, `button`
- Media: `img`, `video`, `audio`, `canvas`
- Tables: `table`, `tr`, `td`, `th`
- And many more...

# Special Behavior
- The `@html` element automatically includes `<!DOCTYPE html>`
- Void elements (like `br`, `img`, `input`) are self-closing
"""
module Elements

using HypertextTemplates

const elements = Set([
    :a,
    :abbr,
    :address,
    :area,
    :article,
    :aside,
    :audio,
    :b,
    :base,
    :bdi,
    :bdo,
    :blockquote,
    :body,
    :br,
    :button,
    :canvas,
    :caption,
    :cite,
    :code,
    :col,
    :colgroup,
    :data,
    :datalist,
    :dd,
    :del,
    :details,
    :dfn,
    :dialog,
    :div,
    :dl,
    :dt,
    :em,
    :embed,
    :fencedframe,
    :fieldset,
    :figcaption,
    :figure,
    :footer,
    :form,
    :h1,
    :h2,
    :h3,
    :h4,
    :h5,
    :h6,
    :head,
    :header,
    :hgroup,
    :hr,
    :html,
    :i,
    :iframe,
    :img,
    :input,
    :ins,
    :kbd,
    :label,
    :legend,
    :li,
    :link,
    :main,
    :map,
    :mark,
    :menu,
    :meta,
    :meter,
    :nav,
    :noscript,
    :object,
    :ol,
    :optgroup,
    :option,
    :output,
    :p,
    :picture,
    :portal,
    :pre,
    :progress,
    :q,
    :rp,
    :rt,
    :ruby,
    :s,
    :samp,
    :script,
    :search,
    :section,
    :select,
    :slot,
    :small,
    :source,
    :span,
    :strong,
    :style,
    :sub,
    :summary,
    :sup,
    :table,
    :tbody,
    :td,
    :template,
    :textarea,
    :tfoot,
    :th,
    :thead,
    :time,
    :title,
    :tr,
    :track,
    :u,
    :ul,
    :var,
    :video,
    :wbr,
])

for each in elements
    @eval @element $each
    @eval @deftag $each
    @eval export $each, $(Symbol("@$each"))
end

# The `html` element always needs a prefixed doctype before it.
HypertextTemplates._render_prefix(io::IO, ::htmlType) = print(io, "<!DOCTYPE html>")

end
