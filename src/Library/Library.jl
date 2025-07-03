module Library

using HypertextTemplates
using HypertextTemplates.Elements

@element svg
@deftag macro svg end

@element path
@deftag macro path end

# Export all components (both functions and macros)
# Layout components
export Container, @Container, Stack, @Stack, Grid, @Grid, Section, @Section
# Typography components
export Heading, @Heading, Text, @Text, Link, @Link
# Card components
export Card, @Card, Badge, @Badge
# Table components
export Table, @Table, List, @List
# List components
export Timeline, @Timeline, TimelineItem, @TimelineItem, TimelineContent, @TimelineContent
# Form components
export Input, @Input, Textarea, @Textarea, Select, @Select, SelectDropdown, @SelectDropdown
export Checkbox, @Checkbox, Radio, @Radio, FormGroup, @FormGroup
export Button, @Button, Toggle, @Toggle
# Feedback components
export Alert, @Alert, Progress, @Progress, Spinner, @Spinner
# Modal components
export Modal, @Modal, ModalTrigger, @ModalTrigger, ModalContent, @ModalContent
export ModalHeader, @ModalHeader, ModalFooter, @ModalFooter
export DrawerModal, @DrawerModal
# Navigation components
export Breadcrumb, @Breadcrumb, Pagination, @Pagination, Tabs, @Tabs, TabPanel, @TabPanel
export DropdownMenu,
    @DropdownMenu, DropdownTrigger, @DropdownTrigger, DropdownContent, @DropdownContent
export DropdownItem,
    @DropdownItem, DropdownDivider, @DropdownDivider, DropdownSubmenu, @DropdownSubmenu
# Utility components
export Divider,
    @Divider,
    Avatar,
    @Avatar,
    Icon,
    @Icon,
    ThemeToggle,
    @ThemeToggle,
    Tooltip,
    @Tooltip,
    TooltipWrapper,
    @TooltipWrapper,
    TooltipTrigger,
    @TooltipTrigger,
    TooltipContent,
    @TooltipContent

# Utility functions
include("utils.jl")

# Icon components (needed by many other components)
include("Icons.jl")

# Layout components
include("Layout.jl")

# Typography components
include("Typography.jl")

# Card components
include("Cards.jl")

# Table components
include("Tables.jl")

# List components
include("Lists.jl")

# Form components
include("Forms.jl")

# Feedback components
include("Feedback.jl")

# Modal components
include("Modals.jl")

# Navigation components
include("Navigation.jl")

# Utility components
include("Utilities.jl")

end # module Library
