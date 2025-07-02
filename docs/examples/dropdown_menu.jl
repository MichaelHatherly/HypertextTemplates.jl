using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Dropdown Menu Component Examples
# Showcases the flexible dropdown menu component with automatic positioning and nesting support

@component function DropdownMenuExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Dropdown Menu Components"

            # Basic dropdown menu
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Basic Dropdown Menu"
                    @Text "Click the button to reveal menu options."

                    @Stack {gap = 4} begin
                        @Stack {direction = :horizontal, gap = 4, wrap = true} begin
                            @DropdownMenu begin
                                @DropdownTrigger begin
                                    @Button "Options" {variant = :secondary}
                                end

                                @DropdownContent begin
                                    @DropdownSubmenu {
                                        label = "Recent Files",
                                        icon = "folder",
                                    } begin
                                        @DropdownItem "document1.txt"
                                        @DropdownItem "presentation.pptx"
                                        @DropdownItem "spreadsheet.xlsx"
                                        @DropdownDivider
                                        @DropdownItem "Clear Recent"
                                    end
                                    @DropdownItem {href = "/profile", icon = "user"} "Profile"
                                    @DropdownItem {href = "/settings", icon = "settings"} "Settings"
                                    @DropdownDivider
                                    @DropdownItem {variant = :danger, icon = "logout"} "Logout"
                                end
                            end

                            @DropdownMenu begin
                                @DropdownTrigger begin
                                    @Button "With Icons" {variant = :primary}
                                end

                                @DropdownContent begin
                                    @DropdownItem {icon = "plus"} "Create New"
                                    @DropdownItem {icon = "folder"} "Open File"
                                    @DropdownItem {icon = "arrow-right"} "Export"
                                    @DropdownDivider
                                    @DropdownItem {icon = "x", variant = :danger} "Delete"
                                end
                            end
                        end
                    end
                end
            end

            # Multiple dropdown examples
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Multiple Dropdown Examples"
                    @Text "Different dropdown variations and use cases."

                    @Stack {direction = :horizontal, gap = 4, wrap = true} begin
                        @DropdownMenu begin
                            @DropdownTrigger begin
                                @Button "Dropdown 1" {variant = :outline}
                            end
                            @DropdownContent begin
                                @DropdownItem "First Option"
                                @DropdownItem "Second Option"
                                @DropdownItem "Third Option"
                            end
                        end

                        @DropdownMenu begin
                            @DropdownTrigger begin
                                @Button "Dropdown 2" {variant = :outline}
                            end
                            @DropdownContent begin
                                @DropdownItem "Option A"
                                @DropdownItem "Option B"
                                @DropdownItem "Option C"
                            end
                        end

                        @DropdownMenu begin
                            @DropdownTrigger begin
                                @Button "Dropdown 3" {variant = :outline}
                            end
                            @DropdownContent begin
                                @DropdownItem "Choice 1"
                                @DropdownItem "Choice 2"
                                @DropdownItem "Choice 3"
                            end
                        end
                    end
                end
            end

            # Nested dropdowns
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Nested Dropdown Menus"
                    @Text "Create multi-level menus with submenu support."

                    @DropdownMenu begin
                        @DropdownTrigger begin
                            @Button "File Menu" {variant = :primary}
                        end

                        @DropdownContent begin
                            @DropdownItem {icon = "plus"} "New File"
                            @DropdownItem {icon = "folder"} "Open..."

                            @DropdownSubmenu {label = "Recent Files", icon = "folder"} begin
                                @DropdownItem "document1.txt"
                                @DropdownItem "presentation.pptx"
                                @DropdownItem "spreadsheet.xlsx"
                                @DropdownDivider
                                @DropdownItem "Clear Recent"
                            end

                            @DropdownDivider

                            @DropdownItem "Save"
                            @DropdownItem "Save As..."

                            @DropdownSubmenu {label = "Export", icon = "arrow-right"} begin
                                @DropdownItem "Export as PDF"
                                @DropdownItem "Export as Word"

                                @DropdownSubmenu {label = "Advanced Export"} begin
                                    @DropdownItem "Export with Comments"
                                    @DropdownItem "Export without Images"
                                    @DropdownItem "Export as Archive"
                                end
                            end

                            @DropdownDivider

                            @DropdownItem {variant = :danger} "Close"
                        end
                    end
                end
            end

            # Special triggers
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Custom Triggers"
                    @Text "Dropdowns can be triggered by any element, including icons and custom buttons."

                    @Grid {cols = 1, md = 2, gap = 6} begin
                        # Custom button trigger
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Custom Button Style"
                            @DropdownMenu begin
                                @DropdownTrigger begin
                                    @button {
                                        class = "px-4 py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-lg hover:from-purple-600 hover:to-pink-600 transition-all duration-200 shadow-md hover:shadow-lg",
                                        type = "button",
                                    } "Gradient Button"
                                end

                                @DropdownContent begin
                                    @DropdownItem {icon = "user"} "Account"
                                    @DropdownItem {icon = "settings"} "Preferences"
                                    @DropdownItem {icon = "search"} "Search"
                                    @DropdownDivider
                                    @DropdownItem "Help"
                                    @DropdownItem "About"
                                end
                            end
                        end

                        # Icon trigger
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Icon-Only Trigger"
                            @Stack {direction = :horizontal, gap = 3} begin
                                @DropdownMenu begin
                                    @DropdownTrigger begin
                                        @button {
                                            class = "p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors",
                                            type = "button",
                                        } begin
                                            @Icon {name = "dots-vertical", size = :md}
                                        end
                                    end

                                    @DropdownContent begin
                                        @DropdownItem {icon = "settings"} "Edit"
                                        @DropdownItem {icon = "folder"} "Move to..."
                                        @DropdownItem {icon = "plus"} "Duplicate"
                                        @DropdownDivider
                                        @DropdownItem {variant = :danger, icon = "x"} "Delete"
                                    end
                                end

                                @DropdownMenu begin
                                    @DropdownTrigger begin
                                        @button {
                                            class = "p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors",
                                            type = "button",
                                        } begin
                                            @Icon {name = "dots-horizontal", size = :md}
                                        end
                                    end

                                    @DropdownContent begin
                                        @DropdownItem "Quick Action 1"
                                        @DropdownItem "Quick Action 2"
                                        @DropdownItem "Quick Action 3"
                                    end
                                end
                            end
                        end
                    end
                end
            end

            # States and disabled items
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "States and Disabled Items"
                    @Text "Dropdown items support various states and can be disabled."

                    @Grid {cols = 1, md = 2, gap = 6} begin
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Item States"
                            @DropdownMenu begin
                                @DropdownTrigger begin
                                    @Button "Item Variants" {variant = :outline}
                                end

                                @DropdownContent begin
                                    @DropdownItem "Default Item"
                                    @DropdownItem {variant = :success} "Success Item"
                                    @DropdownItem {variant = :danger} "Danger Item"
                                    @DropdownDivider
                                    @DropdownItem {disabled = true} "Disabled Item"
                                    @DropdownItem {disabled = true, icon = "x"} "Disabled with Icon"
                                end
                            end
                        end

                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Mixed Content"
                            @DropdownMenu begin
                                @DropdownTrigger begin
                                    @Button "Actions" {variant = :outline}
                                end

                                @DropdownContent begin
                                    @DropdownItem "Cut"
                                    @DropdownItem "Copy"
                                    @DropdownItem {disabled = true} "Paste (Nothing to paste)"
                                    @DropdownDivider
                                    @DropdownItem "Select All"
                                    @DropdownItem {disabled = true} "Find (Not available)"
                                    @DropdownDivider
                                    @DropdownItem {variant = :danger} "Delete All"
                                end
                            end
                        end
                    end
                end
            end

            # Auto-positioning demo
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Automatic Positioning"
                    @Text "Dropdowns use Alpine Anchor with Floating UI for intelligent positioning."

                    @Stack {gap = 4} begin
                        @Text {color = "text-gray-600 dark:text-gray-400"} begin
                            @text "All dropdowns automatically adjust their position to stay within the viewport. They will flip from bottom to top when there's insufficient space below, and adjust horizontally to avoid overflow."
                        end

                        @Stack {direction = :horizontal, gap = 4, wrap = true} begin
                            @DropdownMenu begin
                                @DropdownTrigger begin
                                    @Button "Try Near Bottom" {variant = :gradient}
                                end

                                @DropdownContent begin
                                    @DropdownItem "Automatic positioning"
                                    @DropdownItem "Flips to top when needed"
                                    @DropdownItem "Adjusts horizontally too"
                                    @DropdownDivider
                                    @DropdownItem "No manual configuration needed!"
                                end
                            end

                            @Text {size = :sm, color = "text-gray-500 dark:text-gray-400"} begin
                                @text "Scroll to bottom of page and click to see the menu flip upward automatically."
                            end
                        end
                    end
                end
            end

            # Integration example
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Real-World Integration"
                    @Text "Dropdown menus integrated with other components."

                    @Alert {variant = :info, class = "mb-4"} begin
                        @Text {weight = :medium} "Note: "
                        @text "When using dropdowns inside tables, set "
                        @code "overflow=false"
                        @text " on the Table component to prevent the dropdown from being clipped by the table's overflow container."
                    end

                    # Table with dropdown actions
                    @Table {striped = true, hover = true, overflow = false} begin
                        @thead begin
                            @tr begin
                                @th "Name"
                                @th "Status"
                                @th "Role"
                                @th {class = "text-right"} "Actions"
                            end
                        end
                        @tbody begin
                            for i = 1:3
                                @tr begin
                                    @td begin
                                        @Stack {
                                            direction = :horizontal,
                                            gap = 2,
                                            align = :center,
                                        } begin
                                            @Avatar {size = :sm, fallback = "U$i"}
                                            @text "User $i"
                                        end
                                    end
                                    @td begin
                                        @Badge {variant = i == 2 ? :warning : :success} begin
                                            @text i == 2 ? "Inactive" : "Active"
                                        end
                                    end
                                    @td "Member"
                                    @td {class = "text-right"} begin
                                        @DropdownMenu begin
                                            @DropdownTrigger begin
                                                @button {
                                                    class = "px-3 py-1 text-sm rounded hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors",
                                                    type = "button",
                                                } "Actions ▼"
                                            end

                                            @DropdownContent begin
                                                @DropdownItem {icon = "user"} "View Profile"
                                                @DropdownItem {icon = "settings"} "Edit"
                                                @DropdownDivider
                                                @DropdownSubmenu {label = "Change Role"} begin
                                                    @DropdownItem "Admin"
                                                    @DropdownItem "Moderator"
                                                    @DropdownItem "Member"
                                                    @DropdownItem "Guest"
                                                end
                                                @DropdownDivider
                                                @DropdownItem {
                                                    variant = :danger,
                                                    icon = "x",
                                                } "Remove"
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
end

@deftag macro DropdownMenuExample end
