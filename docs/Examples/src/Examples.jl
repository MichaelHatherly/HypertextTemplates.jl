module Examples

module Templates

using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Shared components
include("shared/html_document.jl")

# Composite components
include("examples/AdvancedComponentsExample.jl")
include("examples/AppExample.jl")
include("examples/DarkModeExample.jl")
include("examples/DropdownMenuExample.jl")
include("examples/FeedbackExample.jl")
include("examples/FormExample.jl")
include("examples/IconGalleryExample.jl")
include("examples/LayoutExample.jl")
include("examples/ModalExample.jl")
include("examples/ModernStylingExample.jl")
include("examples/NavigationExample.jl")
include("examples/TableListExample.jl")
include("examples/TypographyExample.jl")
include("examples/UtilityExample.jl")

end

# Server routes
include("Routes.jl")

# Server config
include("Server.jl")

end # module Examples
