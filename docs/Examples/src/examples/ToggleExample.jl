using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@component function ToggleExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Toggle Components"

            # Switch Toggles
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Switch Toggles"
                    @Text "iOS-style sliding switches for settings and preferences."

                    # Basic switches
                    @Stack {gap = 4} begin
                        @Heading {level = 3, class = "text-lg"} "Basic Switches"

                        @Stack {gap = 3} begin
                            @Toggle {label = "Enable notifications", name = "notifications"}
                            @Toggle {
                                label = "Auto-save documents",
                                name = "autosave",
                                checked = true,
                            }
                            @Toggle {
                                label = "Maintenance mode",
                                name = "maintenance",
                                disabled = true,
                            }
                        end
                    end

                    @Divider {}

                    # Sizes
                    @Stack {gap = 4} begin
                        @Heading {level = 3, class = "text-lg"} "Sizes"

                        @Stack {gap = 3} begin
                            @Toggle {size = :xs, label = "Extra small toggle"}
                            @Toggle {size = :sm, label = "Small toggle"}
                            @Toggle {
                                size = :base,
                                label = "Base size toggle",
                                checked = true,
                            }
                            @Toggle {size = :lg, label = "Large toggle"}
                            @Toggle {size = :xl, label = "Extra large toggle"}
                        end
                    end

                    @Divider {}

                    # Colors
                    @Stack {gap = 4} begin
                        @Heading {level = 3, class = "text-lg"} "Color Variants"

                        @Stack {gap = 3} begin
                            @Toggle {
                                color = :primary,
                                label = "Primary color",
                                checked = true,
                            }
                            @Toggle {
                                color = :success,
                                label = "Success color",
                                checked = true,
                            }
                            @Toggle {
                                color = :danger,
                                label = "Danger color",
                                checked = true,
                            }
                        end
                    end

                    @Divider {}

                    # With Icons
                    @Stack {gap = 4} begin
                        @Heading {level = 3, class = "text-lg"} "With Icons"

                        @Stack {gap = 3} begin
                            @Toggle {label = "Dark mode", show_icons = true, checked = true} begin
                                icon_on := @Icon {name = "moon", size = :xs}
                                icon_off := @Icon {name = "sun", size = :xs}
                            end

                            @Toggle {label = "Sound", show_icons = true} begin
                                icon_on := @text "🔊"
                                icon_off := @text "🔇"
                            end

                            # Default icons when none provided
                            @Toggle {label = "Accept terms", show_icons = true}
                        end
                    end
                end
            end

            # Button Toggles
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Button Toggles"
                    @Text "Use the button variant for toolbar-style toggles."

                    # Text Formatting
                    @Stack {gap = 4} begin
                        @Heading {level = 3, class = "text-lg"} "Text Formatting"

                        @div {class = "flex gap-2"} begin
                            @Toggle {
                                variant = :button,
                                name = "bold",
                                size = :sm,
                                checked = true,
                            } begin
                                @strong "B"
                            end
                            @Toggle {variant = :button, name = "italic", size = :sm} begin
                                @em "I"
                            end
                            @Toggle {variant = :button, name = "underline", size = :sm} begin
                                @span {class = "underline"} "U"
                            end
                            @Toggle {variant = :button, name = "strikethrough", size = :sm} begin
                                @span {class = "line-through"} "S"
                            end
                        end
                    end

                    @Divider {}

                    # Icon Toggles
                    @Stack {gap = 4} begin
                        @Heading {level = 3, class = "text-lg"} "Icon Toggles"

                        @Stack {gap = 3} begin
                            @Text {class = "text-sm text-gray-600"} "View options:"
                            @div {class = "flex gap-2"} begin
                                @Toggle {
                                    variant = :button,
                                    name = "view_grid",
                                    checked = true,
                                } begin
                                    @Icon {name = "grid", size = :sm}
                                end
                                @Toggle {variant = :button, name = "view_list"} begin
                                    @Icon {name = "list", size = :sm}
                                end
                                @Toggle {variant = :button, name = "view_card"} begin
                                    @Icon {name = "card", size = :sm}
                                end
                            end
                        end
                    end

                    @Divider {}

                    # Mixed Content
                    @Stack {gap = 4} begin
                        @Heading {level = 3, class = "text-lg"} "Mixed Content"

                        @div {class = "flex gap-2"} begin
                            @Toggle {variant = :button, name = "edit_mode", checked = true} begin
                                @Icon {name = "edit", size = :sm}
                                @span {class = "ml-2"} "Edit"
                            end
                            @Toggle {variant = :button, name = "preview_mode"} begin
                                @Icon {name = "eye", size = :sm}
                                @span {class = "ml-2"} "Preview"
                            end
                            @Toggle {variant = :button, name = "split_mode"} begin
                                @Icon {name = "columns", size = :sm}
                                @span {class = "ml-2"} "Split"
                            end
                        end
                    end

                    @Divider {}

                    # Button Sizes
                    @Stack {gap = 4} begin
                        @Heading {level = 3, class = "text-lg"} "Button Sizes"

                        @Stack {gap = 3} begin
                            @div {class = "flex items-center gap-2"} begin
                                @Toggle {variant = :button, size = :xs, name = "xs_toggle"} "XS"
                                @Toggle {variant = :button, size = :sm, name = "sm_toggle"} "Small"
                                @Toggle {
                                    variant = :button,
                                    size = :base,
                                    name = "base_toggle",
                                    checked = true,
                                } "Base"
                                @Toggle {variant = :button, size = :lg, name = "lg_toggle"} "Large"
                                @Toggle {variant = :button, size = :xl, name = "xl_toggle"} "XL"
                            end
                        end
                    end
                end
            end

            # Usage Examples
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Common Use Cases"

                    @Stack {gap = 6} begin
                        # Settings Panel
                        @div {class = "p-6 bg-gray-50 dark:bg-gray-900 rounded-lg"} begin
                            @Stack {gap = 4} begin
                                @Heading {level = 3, class = "text-lg"} "Notification Settings"

                                @Stack {gap = 3} begin
                                    @div {class = "flex items-center justify-between"} begin
                                        @Stack {gap = 1, class = "flex-1"} begin
                                            @Text {class = "font-medium"} "Email Notifications"
                                            @Text {class = "text-sm text-gray-600"} "Receive email updates about your account"
                                        end
                                        @Toggle {name = "email_notif", checked = true}
                                    end

                                    @div {class = "flex items-center justify-between"} begin
                                        @Stack {gap = 1, class = "flex-1"} begin
                                            @Text {class = "font-medium"} "Push Notifications"
                                            @Text {class = "text-sm text-gray-600"} "Receive push notifications on your devices"
                                        end
                                        @Toggle {name = "push_notif"}
                                    end

                                    @div {class = "flex items-center justify-between"} begin
                                        @Stack {gap = 1, class = "flex-1"} begin
                                            @Text {class = "font-medium"} "SMS Alerts"
                                            @Text {class = "text-sm text-gray-600"} "Get important alerts via SMS"
                                        end
                                        @Toggle {name = "sms_alerts", color = :danger}
                                    end
                                end
                            end
                        end

                        # Editor Toolbar
                        @div {class = "p-4 bg-gray-50 dark:bg-gray-900 rounded-lg"} begin
                            @Stack {gap = 3} begin
                                @Text {
                                    class = "text-sm font-medium text-gray-700 dark:text-gray-300",
                                } "Editor Toolbar"

                                @div {class = "flex items-center gap-2"} begin
                                    @div {class = "flex gap-1"} begin
                                        @Toggle {
                                            variant = :button,
                                            size = :sm,
                                            name = "editor_bold",
                                        } begin
                                            @strong "B"
                                        end
                                        @Toggle {
                                            variant = :button,
                                            size = :sm,
                                            name = "editor_italic",
                                        } begin
                                            @em "I"
                                        end
                                        @Toggle {
                                            variant = :button,
                                            size = :sm,
                                            name = "editor_underline",
                                        } begin
                                            @span {class = "underline"} "U"
                                        end
                                    end

                                    @div {class = "w-px h-6 bg-gray-300 dark:bg-gray-700"}

                                    @div {class = "flex gap-1"} begin
                                        @Toggle {
                                            variant = :button,
                                            size = :sm,
                                            name = "editor_left",
                                        } begin
                                            @Icon {name = "align-left", size = :xs}
                                        end
                                        @Toggle {
                                            variant = :button,
                                            size = :sm,
                                            name = "editor_center",
                                            checked = true,
                                        } begin
                                            @Icon {name = "align-center", size = :xs}
                                        end
                                        @Toggle {
                                            variant = :button,
                                            size = :sm,
                                            name = "editor_right",
                                        } begin
                                            @Icon {name = "align-right", size = :xs}
                                        end
                                    end

                                    @div {class = "w-px h-6 bg-gray-300 dark:bg-gray-700"}

                                    @div {class = "flex gap-1"} begin
                                        @Toggle {
                                            variant = :button,
                                            size = :sm,
                                            name = "editor_list",
                                        } begin
                                            @Icon {name = "list", size = :xs}
                                        end
                                        @Toggle {
                                            variant = :button,
                                            size = :sm,
                                            name = "editor_numbered",
                                        } begin
                                            @Icon {name = "numbered-list", size = :xs}
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

@deftag macro ToggleExample end

component_title(::typeof(ToggleExample)) = "Toggle Components"
