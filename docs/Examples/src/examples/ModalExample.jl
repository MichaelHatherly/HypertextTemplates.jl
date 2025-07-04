using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Modal Components Example
@component function ModalExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Modal Components Demo"

            # Basic Modals
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Basic Modals"
                    @Text "Standard modal dialogs with various sizes and configurations."

                    @Stack {direction = :horizontal, gap = 3, wrap = true} begin
                        @ModalTrigger {target = "modal-small", variant = :secondary} "Small Modal"
                        @ModalTrigger {target = "modal-medium", variant = :secondary} "Medium Modal"
                        @ModalTrigger {target = "modal-large", variant = :secondary} "Large Modal"
                        @ModalTrigger {target = "modal-persistent", variant = :primary} "Persistent Modal"
                    end
                end
            end

            # Drawer Modals
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Drawer Modals"
                    @Text "Slide-in modals from different screen edges."

                    @Stack {direction = :horizontal, gap = 3, wrap = true} begin
                        @ModalTrigger {target = "drawer-left", variant = :secondary} begin
                            @Icon {name = "arrow-right", size = :sm}
                            @text " Left Drawer"
                        end

                        @ModalTrigger {target = "drawer-right", variant = :secondary} begin
                            @Icon {name = "arrow-left", size = :sm}
                            @text " Right Drawer"
                        end

                        @ModalTrigger {target = "drawer-top", variant = :secondary} begin
                            @Icon {name = "arrow-down", size = :sm}
                            @text " Top Drawer"
                        end

                        @ModalTrigger {target = "drawer-bottom", variant = :secondary} begin
                            @Icon {name = "arrow-up", size = :sm}
                            @text " Bottom Drawer"
                        end
                    end
                end
            end

            # Modal Definitions

            # Basic Size Modals
            @Modal {id = "modal-small", size = :sm} begin
                @ModalHeader "Confirm Action"
                @ModalContent begin
                    @Text "This action cannot be undone. Are you sure?"
                end
                @ModalFooter begin
                    @Button {variant = :secondary, var"@click" = "close()"} "Cancel"
                    @Button {variant = :primary, var"@click" = "close()"} "Continue"
                end
            end

            @Modal {id = "modal-medium"} begin
                @ModalHeader "Update Complete"
                @ModalContent begin
                    @Stack {gap = 4, align = :center} begin
                        @div {
                            class = "w-16 h-16 bg-green-100 dark:bg-green-900/30 rounded-full flex items-center justify-center",
                        } begin
                            @Icon {
                                name = "check",
                                size = :lg,
                                class = "text-green-600 dark:text-green-400",
                            }
                        end
                        @Text {class = "text-gray-600 dark:text-gray-300 text-center"} "Your project has been successfully updated to version 2.4.0"
                        @Card {
                            padding = :sm,
                            class = "bg-gray-50 dark:bg-gray-800/50 w-full",
                        } begin
                            @Stack {gap = 2} begin
                                @div {class = "flex items-center gap-2"} begin
                                    @Icon {
                                        name = "sparkles",
                                        size = :xs,
                                        class = "text-blue-500",
                                    }
                                    @Text {size = :sm} "5 new features added"
                                end
                                @div {class = "flex items-center gap-2"} begin
                                    @Icon {
                                        name = "shield-check",
                                        size = :xs,
                                        class = "text-green-500",
                                    }
                                    @Text {size = :sm} "Security patches applied"
                                end
                                @div {class = "flex items-center gap-2"} begin
                                    @Icon {
                                        name = "bolt",
                                        size = :xs,
                                        class = "text-purple-500",
                                    }
                                    @Text {size = :sm} "Performance optimized"
                                end
                            end
                        end
                    end
                end
                @ModalFooter {justify = :center} begin
                    @Button {variant = :secondary, var"@click" = "close()"} "View Changelog"
                    @Button {variant = :primary, var"@click" = "close()"} "Continue"
                end
            end

            @Modal {id = "modal-large", size = :xl} begin
                @ModalHeader "Create New Project"
                @ModalContent begin
                    @Stack {gap = 6} begin
                        @Grid {cols = 2, gap = 4} begin
                            @FormGroup {label = "Project Name"} begin
                                @Input {placeholder = "Enter project name"}
                            end
                            @FormGroup {label = "Project Type"} begin
                                @SelectDropdown {
                                    options = [
                                        ("web", "Web Application"),
                                        ("mobile", "Mobile App"),
                                        ("api", "API Service"),
                                        ("desktop", "Desktop Application"),
                                    ],
                                    value = "web",
                                }
                            end
                        end

                        @FormGroup {label = "Description"} begin
                            @Textarea {
                                rows = 4,
                                placeholder = "Provide a detailed description of your project, its goals, and key features...",
                            }
                        end

                        @Grid {cols = 2, gap = 4} begin
                            @FormGroup {label = "Repository"} begin
                                @Input {
                                    placeholder = "github.com/username/repo",
                                    type = "url",
                                }
                            end
                            @FormGroup {label = "Project URL"} begin
                                @Input {placeholder = "https://example.com", type = "url"}
                            end
                        end

                        @FormGroup {label = "Team Members"} begin
                            @SelectDropdown {
                                options = [
                                    ("john", "John Doe - Developer"),
                                    ("jane", "Jane Smith - Designer"),
                                    ("bob", "Bob Wilson - Product Manager"),
                                    ("alice", "Alice Johnson - QA Engineer"),
                                    ("charlie", "Charlie Brown - DevOps"),
                                ],
                                placeholder = "Select team members",
                                multiple = true,
                            }
                        end

                        @Card {padding = :md, class = "bg-gray-50 dark:bg-gray-800/50"} begin
                            @Stack {gap = 3} begin
                                @Text {
                                    weight = :medium,
                                    class = "text-gray-900 dark:text-gray-100",
                                } "Project Settings"
                                @Grid {cols = 2, gap = 3} begin
                                    @Checkbox {label = "Enable CI/CD pipeline"}
                                    @Checkbox {label = "Set up monitoring"}
                                    @Checkbox {label = "Create staging environment"}
                                    @Checkbox {label = "Enable auto-deployment"}
                                end
                            end
                        end
                    end
                end
                @ModalFooter begin
                    @Button {variant = :ghost} "Save as Template"
                    @div {class = "flex-1"}
                    @Button {variant = :secondary, var"@click" = "close()"} "Cancel"
                    @Button {variant = :primary} "Create Project"
                end
            end

            @Modal {id = "modal-persistent", persistent = true} begin
                @ModalHeader "Terms Updated"
                @ModalContent begin
                    @Stack {gap = 4} begin
                        @Text {class = "text-gray-600 dark:text-gray-300"} "We've updated our terms of service to better protect your data and improve our services."
                        @Card {
                            padding = :sm,
                            class = "bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700",
                        } begin
                            @Text {size = :sm} "Key changes: Enhanced privacy controls, clearer data usage policies, and improved security measures."
                        end
                    end
                end
                @ModalFooter {justify = :center} begin
                    @Button {variant = :primary, var"@click" = "close()"} "Accept & Continue"
                end
            end

            # Drawer Modals
            @DrawerModal {id = "drawer-left", position = :left, size = :lg} begin
                @ModalHeader "Navigation"
                @ModalContent begin
                    @Stack {gap = 1, class = "w-64"} begin
                        @button {
                            class = "flex items-center justify-between px-4 py-3 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors text-left w-full",
                        } begin
                            @div {class = "flex items-center gap-3"} begin
                                @Icon {name = "home", size = :sm}
                                @div begin
                                    @Text {weight = :medium} "Dashboard"
                                    @Text {
                                        size = :xs,
                                        class = "text-gray-500 dark:text-gray-400",
                                    } "Overview & analytics"
                                end
                            end
                        end
                        @button {
                            class = "flex items-center justify-between px-4 py-3 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors text-left w-full",
                        } begin
                            @div {class = "flex items-center gap-3"} begin
                                @Icon {name = "folder", size = :sm}
                                @div begin
                                    @Text {weight = :medium} "Projects"
                                    @Text {
                                        size = :xs,
                                        class = "text-gray-500 dark:text-gray-400",
                                    } "12 active projects"
                                end
                            end
                        end
                        @button {
                            class = "flex items-center justify-between px-4 py-3 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors text-left w-full",
                        } begin
                            @div {class = "flex items-center gap-3"} begin
                                @Icon {name = "users", size = :sm}
                                @div begin
                                    @Text {weight = :medium} "Team Members"
                                    @Text {
                                        size = :xs,
                                        class = "text-gray-500 dark:text-gray-400",
                                    } "8 members online"
                                end
                            end
                        end
                        @Divider {class = "my-3"}
                        @button {
                            class = "flex items-center justify-between px-4 py-3 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors text-left w-full",
                        } begin
                            @div {class = "flex items-center gap-3"} begin
                                @Icon {name = "cog", size = :sm}
                                @div begin
                                    @Text {weight = :medium} "Settings"
                                    @Text {
                                        size = :xs,
                                        class = "text-gray-500 dark:text-gray-400",
                                    } "Account & preferences"
                                end
                            end
                        end
                    end
                end
            end

            @DrawerModal {id = "drawer-right", position = :right, size = :lg} begin
                @ModalHeader "Settings"
                @ModalContent begin
                    @Stack {gap = 6} begin
                        # Appearance Section
                        @Stack {gap = 3} begin
                            @Text {
                                weight = :semibold,
                                class = "text-gray-900 dark:text-gray-100",
                            } "Appearance"
                            @div begin
                                @Stack {gap = 3} begin
                                    @div {class = "flex items-center gap-2 justify-between"} begin
                                        @div begin
                                            @Text {weight = :medium} "Theme"
                                            @Text {
                                                size = :xs,
                                                class = "text-gray-500 dark:text-gray-400",
                                            } "Choose your preferred color scheme"
                                        end
                                        @ThemeToggle
                                    end
                                    @Divider
                                    @div {class = "flex items-center justify-between"} begin
                                        @div begin
                                            @Text {weight = :medium} "Compact View"
                                            @Text {
                                                size = :xs,
                                                class = "text-gray-500 dark:text-gray-400",
                                            } "Reduce spacing between elements"
                                        end
                                        @Checkbox {checked = false}
                                    end
                                end
                            end
                        end

                        # Notifications Section
                        @Stack {gap = 3} begin
                            @Text {
                                weight = :semibold,
                                class = "text-gray-900 dark:text-gray-100",
                            } "Notifications"
                            @div begin
                                @Stack {gap = 3} begin
                                    @div {class = "flex items-center justify-between"} begin
                                        @div begin
                                            @Text {weight = :medium} "Email Notifications"
                                            @Text {
                                                size = :xs,
                                                class = "text-gray-500 dark:text-gray-400",
                                            } "Receive updates via email"
                                        end
                                        @Checkbox {checked = true}
                                    end
                                    @div {class = "flex items-center justify-between"} begin
                                        @div begin
                                            @Text {weight = :medium} "Push Notifications"
                                            @Text {
                                                size = :xs,
                                                class = "text-gray-500 dark:text-gray-400",
                                            } "Browser notifications"
                                        end
                                        @Checkbox {checked = true}
                                    end
                                    @div {class = "flex items-center justify-between"} begin
                                        @div begin
                                            @Text {weight = :medium} "Weekly Digest"
                                            @Text {
                                                size = :xs,
                                                class = "text-gray-500 dark:text-gray-400",
                                            } "Summary of your activity"
                                        end
                                        @Checkbox {checked = false}
                                    end
                                end
                            end
                        end

                        # General Section
                        @Stack {gap = 3} begin
                            @Text {
                                weight = :semibold,
                                class = "text-gray-900 dark:text-gray-100",
                            } "General"
                            @div begin
                                @Stack {gap = 3} begin
                                    @div {class = "flex items-center justify-between"} begin
                                        @div begin
                                            @Text {weight = :medium} "Language"
                                            @Text {
                                                size = :xs,
                                                class = "text-gray-500 dark:text-gray-400",
                                            } "Choose your language"
                                        end
                                        @SelectDropdown {
                                            options = [
                                                ("en", "English"),
                                                ("es", "Español"),
                                                ("fr", "Français"),
                                                ("de", "Deutsch"),
                                            ],
                                            value = "en",
                                            size = :sm,
                                        }
                                    end
                                    @div {class = "flex items-center justify-between"} begin
                                        @div begin
                                            @Text {weight = :medium} "Timezone"
                                            @Text {
                                                size = :xs,
                                                class = "text-gray-500 dark:text-gray-400",
                                            } "Your local timezone"
                                        end
                                        @Badge {variant = :secondary} "UTC-5"
                                    end
                                end
                            end
                        end

                        # Footer Actions
                        @Stack {direction = :horizontal, gap = 3, class = "pt-4"} begin
                            @Button {
                                variant = :ghost,
                                class = "text-red-600 dark:text-red-400",
                            } "Reset to Defaults"
                            @div {class = "flex-1"}
                            @Button {variant = :primary, var"@click" = "close()"} "Save Changes"
                        end
                    end
                end
            end

            @DrawerModal {id = "drawer-top", position = :top} begin
                @ModalContent begin
                    @Stack {direction = :horizontal, align = :center, gap = 4} begin
                        @Stack {direction = :horizontal, gap = 3, align = :center} begin
                            @Icon {
                                name = "information-circle",
                                size = :md,
                                class = "text-blue-500",
                            }
                            @Text {class = "text-gray-700 dark:text-gray-200"} "This site uses cookies for analytics and personalization."
                        end
                        @Stack {direction = :horizontal, gap = 2} begin
                            @Button {variant = :ghost, size = :sm} "Learn More"
                            @Button {
                                variant = :primary,
                                size = :sm,
                                var"@click" = "close()",
                            } "Accept"
                        end
                    end
                end
            end

            @DrawerModal {id = "drawer-bottom", position = :bottom} begin
                @ModalContent begin
                    @div {class = "max-w-md mx-auto"} begin
                        @Stack {gap = 4, align = :center} begin
                            @Heading {
                                level = 3,
                                class = "text-lg font-semibold text-gray-900 dark:text-gray-100 text-center",
                            } "Subscribe to Updates"
                            @Text {
                                size = :sm,
                                class = "text-gray-600 dark:text-gray-300 text-center",
                            } "Get notified about new features and important updates."
                            @Stack {
                                direction = :horizontal,
                                gap = 3,
                                class = "w-full max-w-sm",
                            } begin
                                @div {class = "flex-1"} begin
                                    @Input {
                                        placeholder = "Enter your email",
                                        type = "email",
                                    }
                                end
                                @Button {variant = :primary} "Subscribe"
                            end
                            @Text {size = :xs, class = "text-gray-500 dark:text-gray-400"} "No spam, unsubscribe anytime."
                        end
                    end
                end
            end
        end
    end
end
@deftag macro ModalExample end

component_title(::typeof(ModalExample)) = "Modal Components"
