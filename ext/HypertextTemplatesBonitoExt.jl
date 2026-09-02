module HypertextTemplatesBonitoExt

import Bonito
import HypertextTemplates

function HypertextTemplates.escape_html(io::IO, app::Bonito.App, revise)
    show(_destination(io), MIME"text/html"(), app)
    return nothing
end

# Bonito takes the caller's `IOContext` only when the stream it is handed is
# itself one. Behind one of this package's wrappers it would fall back to a
# context built around `stdout`, so the wrapper is unwrapped first.
_destination(io::HypertextTemplates.WrappedIO) = _destination(io.io)
_destination(io::IO) = io

end
