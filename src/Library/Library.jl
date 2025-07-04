module Library

using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates: SafeString

@element svg
@deftag macro svg end

@element path
@deftag macro path end

# Utility functions
include("utils.jl")

# Theme system
include("theme/DefaultTheme.jl")
include("theme/ThemeUtils.jl")

# Utility components
include("utilities/Icon.jl")
include("utilities/Divider.jl")
include("utilities/Avatar.jl")
include("utilities/ThemeToggle.jl")

# Typography components
include("typography/Heading.jl")
include("typography/Text.jl")
include("typography/Link.jl")

# Form components
include("forms/Input.jl")
include("forms/Textarea.jl")
include("forms/Select.jl")
include("forms/Checkbox.jl")
include("forms/Radio.jl")
include("forms/FormGroup.jl")
include("forms/Button.jl")
include("forms/SelectDropdown.jl")
include("forms/Toggle.jl")

# Modal components
include("modals/Modal.jl")
include("modals/ModalTrigger.jl")
include("modals/ModalContent.jl")
include("modals/ModalHeader.jl")
include("modals/ModalFooter.jl")
include("modals/DrawerModal.jl")

# Navigation components
include("navigation/Breadcrumb.jl")
include("navigation/Pagination.jl")
include("navigation/Tabs.jl")
include("navigation/TabPanel.jl")
include("navigation/dropdown/DropdownMenu.jl")
include("navigation/dropdown/DropdownTrigger.jl")
include("navigation/dropdown/DropdownContent.jl")
include("navigation/dropdown/DropdownItem.jl")
include("navigation/dropdown/DropdownDivider.jl")
include("navigation/dropdown/DropdownSubmenu.jl")

# Feedback components
include("feedback/Alert.jl")
include("feedback/Progress.jl")
include("feedback/Spinner.jl")
include("feedback/Badge.jl")

# Layout components
include("layout/Container.jl")
include("layout/Stack.jl")
include("layout/Grid.jl")
include("layout/Section.jl")

# Timeline components
include("timeline/Timeline.jl")
include("timeline/TimelineItem.jl")
include("timeline/TimelineContent.jl")

# Tooltip components
include("tooltip/Tooltip.jl")
include("tooltip/TooltipWrapper.jl")
include("tooltip/TooltipTrigger.jl")
include("tooltip/TooltipContent.jl")

# Content components
include("content/Card.jl")
include("content/Table.jl")
include("content/List.jl")

export Input, Textarea, Select, Checkbox, Radio, FormGroup, Button, SelectDropdown, Toggle
export @Input,
    @Textarea, @Select, @Checkbox, @Radio, @FormGroup, @Button, @SelectDropdown, @Toggle

export Modal, ModalTrigger, ModalContent, ModalHeader, ModalFooter, DrawerModal
export @Modal, @ModalTrigger, @ModalContent, @ModalHeader, @ModalFooter, @DrawerModal

export Breadcrumb, Pagination, Tabs, TabPanel
export @Breadcrumb, @Pagination, @Tabs, @TabPanel

export DropdownMenu,
    DropdownTrigger, DropdownContent, DropdownItem, DropdownDivider, DropdownSubmenu
export @DropdownMenu,
    @DropdownTrigger, @DropdownContent, @DropdownItem, @DropdownDivider, @DropdownSubmenu

export Alert, Progress, Spinner, Badge
export @Alert, @Progress, @Spinner, @Badge

export Container, Stack, Grid, Section
export @Container, @Stack, @Grid, @Section

export Heading, Text, Link
export @Heading, @Text, @Link

export Timeline, TimelineItem, TimelineContent
export @Timeline, @TimelineItem, @TimelineContent

export Tooltip, TooltipWrapper, TooltipTrigger, TooltipContent
export @Tooltip, @TooltipWrapper, @TooltipTrigger, @TooltipContent

export Card, Table, List
export @Card, @Table, @List

export Icon, Divider, Avatar, ThemeToggle
export @Icon, @Divider, @Avatar, @ThemeToggle

# Theme system exports
export default_theme, get_theme_value, merge_theme, create_theme

end # module
