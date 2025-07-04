using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Icon Gallery Examples

# Navigation Icons Component
@component function NavigationIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        # Home and arrows
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "home", size = :lg}
            @span {class = "text-xs text-gray-600"} "home"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "arrow-up", size = :lg}
            @span {class = "text-xs text-gray-600"} "arrow-up"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "arrow-down", size = :lg}
            @span {class = "text-xs text-gray-600"} "arrow-down"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "arrow-left", size = :lg}
            @span {class = "text-xs text-gray-600"} "arrow-left"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "arrow-right", size = :lg}
            @span {class = "text-xs text-gray-600"} "arrow-right"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "external-link", size = :lg}
            @span {class = "text-xs text-gray-600"} "external-link"
        end

        # Chevrons
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "chevron-up", size = :lg}
            @span {class = "text-xs text-gray-600"} "chevron-up"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "chevron-down", size = :lg}
            @span {class = "text-xs text-gray-600"} "chevron-down"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "chevron-left", size = :lg}
            @span {class = "text-xs text-gray-600"} "chevron-left"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "chevron-right", size = :lg}
            @span {class = "text-xs text-gray-600"} "chevron-right"
        end
    end
end
@deftag macro NavigationIcons end

# Action Icons Component
@component function ActionIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "edit", size = :lg}
            @span {class = "text-xs text-gray-600"} "edit"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "trash", size = :lg}
            @span {class = "text-xs text-gray-600"} "trash"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "save", size = :lg}
            @span {class = "text-xs text-gray-600"} "save"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "download", size = :lg}
            @span {class = "text-xs text-gray-600"} "download"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "upload", size = :lg}
            @span {class = "text-xs text-gray-600"} "upload"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "copy", size = :lg}
            @span {class = "text-xs text-gray-600"} "copy"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "refresh", size = :lg}
            @span {class = "text-xs text-gray-600"} "refresh"
        end
    end
end
@deftag macro ActionIcons end

# Communication Icons Component
@component function CommunicationIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "mail", size = :lg}
            @span {class = "text-xs text-gray-600"} "mail"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "phone", size = :lg}
            @span {class = "text-xs text-gray-600"} "phone"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "chat", size = :lg}
            @span {class = "text-xs text-gray-600"} "chat"
        end
    end
end
@deftag macro CommunicationIcons end

# Media Icons Component
@component function MediaIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "play", size = :lg}
            @span {class = "text-xs text-gray-600"} "play"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "pause", size = :lg}
            @span {class = "text-xs text-gray-600"} "pause"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "stop", size = :lg}
            @span {class = "text-xs text-gray-600"} "stop"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "camera", size = :lg}
            @span {class = "text-xs text-gray-600"} "camera"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "image", size = :lg}
            @span {class = "text-xs text-gray-600"} "image"
        end
    end
end
@deftag macro MediaIcons end

# Status Icons Component
@component function StatusIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "info", size = :lg}
            @span {class = "text-xs text-gray-600"} "info"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "warning", size = :lg}
            @span {class = "text-xs text-gray-600"} "warning"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "error", size = :lg}
            @span {class = "text-xs text-gray-600"} "error"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "question", size = :lg}
            @span {class = "text-xs text-gray-600"} "question"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "bell", size = :lg}
            @span {class = "text-xs text-gray-600"} "bell"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "info-circle", size = :lg}
            @span {class = "text-xs text-gray-600"} "info-circle"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "check-circle", size = :lg}
            @span {class = "text-xs text-gray-600"} "check-circle"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "exclamation-triangle", size = :lg}
            @span {class = "text-xs text-gray-600"} "exclamation-triangle"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "x-circle", size = :lg}
            @span {class = "text-xs text-gray-600"} "x-circle"
        end
    end
end
@deftag macro StatusIcons end

# File & Document Icons Component
@component function FileDocumentIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "file", size = :lg}
            @span {class = "text-xs text-gray-600"} "file"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "document", size = :lg}
            @span {class = "text-xs text-gray-600"} "document"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "folder", size = :lg}
            @span {class = "text-xs text-gray-600"} "folder"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "code", size = :lg}
            @span {class = "text-xs text-gray-600"} "code"
        end
    end
end
@deftag macro FileDocumentIcons end

# UI Control Icons Component
@component function UIControlIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "filter", size = :lg}
            @span {class = "text-xs text-gray-600"} "filter"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "sort", size = :lg}
            @span {class = "text-xs text-gray-600"} "sort"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "grid", size = :lg}
            @span {class = "text-xs text-gray-600"} "grid"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "list", size = :lg}
            @span {class = "text-xs text-gray-600"} "list"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "eye", size = :lg}
            @span {class = "text-xs text-gray-600"} "eye"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "eye-off", size = :lg}
            @span {class = "text-xs text-gray-600"} "eye-off"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "lock", size = :lg}
            @span {class = "text-xs text-gray-600"} "lock"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "unlock", size = :lg}
            @span {class = "text-xs text-gray-600"} "unlock"
        end
    end
end
@deftag macro UIControlIcons end

# Common UI Icons Component
@component function CommonUIIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "check", size = :lg}
            @span {class = "text-xs text-gray-600"} "check"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "x", size = :lg}
            @span {class = "text-xs text-gray-600"} "x"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "plus", size = :lg}
            @span {class = "text-xs text-gray-600"} "plus"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "minus", size = :lg}
            @span {class = "text-xs text-gray-600"} "minus"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "menu", size = :lg}
            @span {class = "text-xs text-gray-600"} "menu"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "search", size = :lg}
            @span {class = "text-xs text-gray-600"} "search"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "user", size = :lg}
            @span {class = "text-xs text-gray-600"} "user"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "settings", size = :lg}
            @span {class = "text-xs text-gray-600"} "settings"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "logout", size = :lg}
            @span {class = "text-xs text-gray-600"} "logout"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "dots-vertical", size = :lg}
            @span {class = "text-xs text-gray-600"} "dots-vertical"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "dots-horizontal", size = :lg}
            @span {class = "text-xs text-gray-600"} "dots-horizontal"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "spinner", size = :lg}
            @span {class = "text-xs text-gray-600"} "spinner"
        end
    end
end
@deftag macro CommonUIIcons end

# Time & Date Icons Component
@component function TimeDateIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "calendar", size = :lg}
            @span {class = "text-xs text-gray-600"} "calendar"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "clock", size = :lg}
            @span {class = "text-xs text-gray-600"} "clock"
        end
    end
end
@deftag macro TimeDateIcons end

# E-commerce Icons Component
@component function EcommerceIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "cart", size = :lg}
            @span {class = "text-xs text-gray-600"} "cart"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "credit-card", size = :lg}
            @span {class = "text-xs text-gray-600"} "credit-card"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "tag", size = :lg}
            @span {class = "text-xs text-gray-600"} "tag"
        end
    end
end
@deftag macro EcommerceIcons end

# Social Icons Component
@component function SocialIcons()
    @div {class = "grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-4"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "heart", size = :lg}
            @span {class = "text-xs text-gray-600"} "heart"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "star", size = :lg}
            @span {class = "text-xs text-gray-600"} "star"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "bookmark", size = :lg}
            @span {class = "text-xs text-gray-600"} "bookmark"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "share", size = :lg}
            @span {class = "text-xs text-gray-600"} "share"
        end
    end
end
@deftag macro SocialIcons end

# Icon Sizes Component
@component function IconSizes()
    @div {class = "flex items-center gap-6 flex-wrap"} begin
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "heart", size = :xs}
            @span {class = "text-xs text-gray-600"} "xs (12px)"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "heart", size = :sm}
            @span {class = "text-xs text-gray-600"} "sm (16px)"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "heart", size = :md}
            @span {class = "text-xs text-gray-600"} "md (20px)"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "heart", size = :lg}
            @span {class = "text-xs text-gray-600"} "lg (24px)"
        end
        @div {class = "flex flex-col items-center gap-2"} begin
            @Icon {name = "heart", size = :xl}
            @span {class = "text-xs text-gray-600"} "xl (32px)"
        end
    end
end
@deftag macro IconSizes end

# Icon Colors Component
@component function IconColors()
    @div {class = "flex items-center gap-4 flex-wrap"} begin
        @Icon {name = "star", size = :lg, color = "text-gray-600"}
        @Icon {name = "star", size = :lg, color = "text-red-500"}
        @Icon {name = "star", size = :lg, color = "text-yellow-500"}
        @Icon {name = "star", size = :lg, color = "text-green-500"}
        @Icon {name = "star", size = :lg, color = "text-blue-500"}
        @Icon {name = "star", size = :lg, color = "text-indigo-500"}
        @Icon {name = "star", size = :lg, color = "text-purple-500"}
        @Icon {name = "star", size = :lg, color = "text-pink-500"}
    end
end
@deftag macro IconColors end

# Icons in Buttons Component
@component function IconsInButtons()
    @div {class = "flex gap-3 flex-wrap"} begin
        @Button {variant = :primary} begin
            @Icon {name = "download", size = :sm}
            @span "Download"
        end

        @Button {variant = :secondary} begin
            @Icon {name = "edit", size = :sm}
            @span "Edit"
        end

        @Button {variant = :danger} begin
            @Icon {name = "trash", size = :sm}
            @span "Delete"
        end

        # Icon-only buttons
        @Button {variant = :ghost, class = "p-2"} begin
            @Icon {name = "settings", size = :md}
        end

        @Button {variant = :outline, class = "p-2"} begin
            @Icon {name = "heart", size = :md}
        end
    end
end
@deftag macro IconsInButtons end

# Icon gallery examples array
icon_gallery_examples = [
    (
        title = "Navigation Icons",
        description = "Icons for navigation and directional controls",
        component = NavigationIcons,
    ),
    (
        title = "Action Icons",
        description = "Icons for common user actions and operations",
        component = ActionIcons,
    ),
    (
        title = "Communication Icons",
        description = "Icons for messaging and communication features",
        component = CommunicationIcons,
    ),
    (
        title = "Media Icons",
        description = "Icons for media controls and content",
        component = MediaIcons,
    ),
    (
        title = "Status Icons",
        description = "Icons for alerts, notifications, and status indicators",
        component = StatusIcons,
    ),
    (
        title = "File & Document Icons",
        description = "Icons for files, documents, and code",
        component = FileDocumentIcons,
    ),
    (
        title = "UI Control Icons",
        description = "Icons for user interface controls and interactions",
        component = UIControlIcons,
    ),
    (
        title = "Common UI Icons",
        description = "Frequently used interface icons",
        component = CommonUIIcons,
    ),
    (
        title = "Time & Date Icons",
        description = "Icons for time-related features",
        component = TimeDateIcons,
    ),
    (
        title = "E-commerce Icons",
        description = "Icons for shopping and commerce features",
        component = EcommerceIcons,
    ),
    (
        title = "Social Icons",
        description = "Icons for social features and engagement",
        component = SocialIcons,
    ),
    (
        title = "Icon Sizes",
        description = "Different size variations for icons",
        component = IconSizes,
    ),
    (
        title = "Icon Colors",
        description = "Apply different colors to icons",
        component = IconColors,
    ),
    (
        title = "Icons in Buttons",
        description = "Using icons within button components",
        component = IconsInButtons,
    ),
]

@component function IconGalleryExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 6} begin
            @Heading {level = 1, class = "text-center mb-8"} "Icon Gallery"
            @Text {variant = :lead, class = "text-center mb-8"} "Complete collection of available icons in the HypertextTemplates Library"

            for example in icon_gallery_examples
                @Card {padding = :lg, class = "mb-6"} begin
                    @Stack {gap = 4} begin
                        @Heading {level = 2} example.title
                        if haskey(example, :description) && !isnothing(example.description)
                            @Text {color = "text-gray-600 dark:text-gray-400"} example.description
                        end
                        @<example.component
                    end
                end
            end
        end
    end
end
@deftag macro IconGalleryExample end

component_title(::typeof(IconGalleryExample)) = "Icon Gallery"
