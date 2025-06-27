module Library

using HypertextTemplates
using HypertextTemplates.Elements

# Export all components (both functions and macros)
# Layout components
export Container, @Container, Stack, @Stack, Grid, @Grid, Section, @Section
# Typography components
export Heading, @Heading, Text, @Text, Link, @Link
# Card components
export Card, @Card, Badge, @Badge
# Table components
export Table, @Table, List, @List
# Form components
export Input, @Input, Textarea, @Textarea, Select, @Select
export Checkbox, @Checkbox, Radio, @Radio, FormGroup, @FormGroup
# Feedback components
export Alert, @Alert, Progress, @Progress, Spinner, @Spinner
# Navigation components
export Breadcrumb, @Breadcrumb, Pagination, @Pagination, Tabs, @Tabs
# Utility components
export Divider, @Divider, Avatar, @Avatar, Icon, @Icon

# Layout components
include("Layout.jl")

# Typography components
include("Typography.jl")

# Card components
include("Cards.jl")

# Table components
include("Tables.jl")

# Form components
include("Forms.jl")

# Feedback components
include("Feedback.jl")

# Navigation components
include("Navigation.jl")

# Utility components
include("Utilities.jl")

end # module Library
