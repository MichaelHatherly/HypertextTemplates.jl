module HypertextTemplatesBonitoExt

import Bonito
import HypertextTemplates

function HypertextTemplates.escape_html(io::IO, app::Bonito.App, revise)
    show(io, MIME"text/html"(), app)
    return nothing
end

end
