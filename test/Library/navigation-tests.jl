using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Navigation Components" begin
    @testset "Breadcrumb" begin
        render_test("references/library/breadcrumb-default.txt") do io
            @render io @Breadcrumb {
                items=[
                    ("/", "Home"),
                    ("/products", "Products"),
                    ("/products/shoes", "Shoes"),
                ],
            }
        end

        render_test("references/library/breadcrumb-separator.txt") do io
            @render io @Breadcrumb {
                items=[("/", "Home"), ("/about", "About")],
                separator=">",
            }
        end
    end

    @testset "Pagination" begin
        render_test("references/library/pagination-default.txt") do io
            @render io @Pagination {current=1, total=5}
        end

        render_test("references/library/pagination-middle.txt") do io
            @render io @Pagination {current=5, total=10}
        end

        render_test("references/library/pagination-siblings.txt") do io
            @render io @Pagination {current=10, total=20, siblings=2}
        end

        render_test("references/library/pagination-custom-url.txt") do io
            @render io @Pagination {current=3, total=5, base_url="/page/"}
        end
    end

    @testset "Tabs" begin
        render_test("references/library/tabs-default.txt") do io
            @render io @Tabs {
                items=[("tab1", "Tab 1"), ("tab2", "Tab 2"), ("tab3", "Tab 3")],
            }
        end

        render_test("references/library/tabs-active.txt") do io
            @render io @Tabs {
                items=[
                    ("overview", "Overview"),
                    ("details", "Details"),
                    ("reviews", "Reviews"),
                ],
                active="details",
            }
        end
    end

    @testset "Dropdown Components" begin
        @testset "Basic DropdownMenu" begin
            render_test("references/library/dropdown-basic.txt") do io
                @render io @DropdownMenu begin
                    @DropdownTrigger begin
                        @button {type="button", class="px-4 py-2 bg-gray-200 rounded"} "Menu"
                    end
                    @DropdownContent begin
                        @DropdownItem "Option 1"
                        @DropdownItem "Option 2"
                        @DropdownItem "Option 3"
                    end
                end
            end
        end

        @testset "DropdownMenu with custom trigger" begin
            render_test("references/library/dropdown-custom-trigger.txt") do io
                @render io @DropdownMenu begin
                    @DropdownTrigger begin
                        @Icon {name="dots-vertical", size=:lg}
                    end
                    @DropdownContent begin
                        @DropdownItem "Edit"
                        @DropdownItem "Delete"
                    end
                end
            end
        end

        @testset "DropdownItem variations" begin
            render_test("references/library/dropdown-item-variations.txt") do io
                @render io @DropdownMenu begin
                    @DropdownTrigger begin
                        @button "Actions"
                    end
                    @DropdownContent begin
                        @DropdownItem "Default Item"
                        @DropdownItem {href="/profile"} "Link Item"
                        @DropdownItem {icon="user"} "Item with Icon"
                        @DropdownItem {variant=:danger} "Danger Item"
                        @DropdownItem {variant=:success} "Success Item"
                        @DropdownItem {disabled=true} "Disabled Item"
                        @DropdownItem {href="/disabled", disabled=true} "Disabled Link"
                        @DropdownItem {icon="settings", href="/settings"} "Settings Link with Icon"
                    end
                end
            end
        end

        @testset "DropdownDivider" begin
            render_test("references/library/dropdown-divider.txt") do io
                @render io @DropdownMenu begin
                    @DropdownTrigger begin
                        @button "User Menu"
                    end
                    @DropdownContent begin
                        @DropdownItem {icon="user"} "Profile"
                        @DropdownItem {icon="settings"} "Settings"
                        @DropdownDivider
                        @DropdownItem {icon="logout", variant=:danger} "Logout"
                    end
                end
            end
        end

        @testset "DropdownSubmenu basic" begin
            render_test("references/library/dropdown-submenu-basic.txt") do io
                @render io @DropdownMenu begin
                    @DropdownTrigger begin
                        @button "File"
                    end
                    @DropdownContent begin
                        @DropdownItem "New"
                        @DropdownItem "Open"
                        @DropdownSubmenu {label="Recent Files"} begin
                            @DropdownItem "document1.txt"
                            @DropdownItem "document2.txt"
                            @DropdownItem "document3.txt"
                        end
                        @DropdownDivider
                        @DropdownItem "Exit"
                    end
                end
            end
        end

        @testset "DropdownSubmenu with icon" begin
            render_test("references/library/dropdown-submenu-icon.txt") do io
                @render io @DropdownMenu begin
                    @DropdownTrigger begin
                        @button "Options"
                    end
                    @DropdownContent begin
                        @DropdownSubmenu {label="Export", icon="folder"} begin
                            @DropdownItem "Export as PDF"
                            @DropdownItem "Export as CSV"
                            @DropdownItem "Export as JSON"
                        end
                    end
                end
            end
        end

        @testset "Nested submenus" begin
            render_test("references/library/dropdown-nested-submenus.txt") do io
                @render io @DropdownMenu begin
                    @DropdownTrigger begin
                        @button "Edit"
                    end
                    @DropdownContent begin
                        @DropdownSubmenu {label="Format"} begin
                            @DropdownSubmenu {label="Text"} begin
                                @DropdownItem "Bold"
                                @DropdownItem "Italic"
                                @DropdownItem "Underline"
                            end
                            @DropdownSubmenu {label="Alignment"} begin
                                @DropdownItem "Left"
                                @DropdownItem "Center"
                                @DropdownItem "Right"
                            end
                        end
                    end
                end
            end
        end

        @testset "Complex dropdown composition" begin
            render_test("references/library/dropdown-complex.txt") do io
                @render io @DropdownMenu {class="custom-dropdown"} begin
                    @DropdownTrigger begin
                        @button {class="flex items-center gap-2"} begin
                            @Icon {name="user", size=:sm}
                            @span "John Doe"
                            @Icon {name="chevron-down", size=:xs}
                        end
                    end
                    @DropdownContent {class="min-w-[200px]"} begin
                        @div {class="px-4 py-2 border-b border-gray-200"} begin
                            @p {class="text-sm font-medium"} "Signed in as"
                            @p {class="text-sm text-gray-600"} "john@example.com"
                        end
                        @DropdownItem {icon="user", href="/profile"} "Your Profile"
                        @DropdownItem {icon="settings", href="/settings"} "Settings"
                        @DropdownDivider
                        @DropdownSubmenu {label="Theme", icon="settings"} begin
                            @DropdownItem "Light"
                            @DropdownItem "Dark"
                            @DropdownItem "System"
                        end
                        @DropdownDivider
                        @DropdownItem {icon="logout", variant=:danger} "Sign out"
                    end
                end
            end
        end

        @testset "Multiple dropdowns" begin
            render_test("references/library/dropdown-multiple.txt") do io
                @render io @div {class="flex gap-4"} begin
                    @DropdownMenu begin
                        @DropdownTrigger begin
                            @button "Dropdown 1"
                        end
                        @DropdownContent begin
                            @DropdownItem "Option A"
                            @DropdownItem "Option B"
                        end
                    end

                    @DropdownMenu begin
                        @DropdownTrigger begin
                            @button "Dropdown 2"
                        end
                        @DropdownContent begin
                            @DropdownItem "Option X"
                            @DropdownItem "Option Y"
                        end
                    end
                end
            end
        end

        @testset "Empty dropdown" begin
            render_test("references/library/dropdown-empty.txt") do io
                @render io @DropdownMenu begin
                    @DropdownTrigger begin
                        @button "Empty Menu"
                    end
                    @DropdownContent
                end
            end
        end
    end
end
