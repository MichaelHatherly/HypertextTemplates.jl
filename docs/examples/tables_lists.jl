using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# 7. Table and List Components Example
@component function TableListExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Table & List Components Demo"

            # Tables
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Table Component"
                    @Text "Display structured data in responsive tables."

                    @Table {striped = true, hover = true} begin
                        @thead begin
                            @tr begin
                                @th "Employee"
                                @th "Department"
                                @th "Status"
                                @th "Hire Date"
                                @th "Actions"
                            end
                        end
                        @tbody begin
                            @tr begin
                                @td begin
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 3,
                                        align = :center,
                                    } begin
                                        @Avatar {fallback = "JS", size = :sm}
                                        @Stack {gap = 0} begin
                                            @Text {weight = :medium} "John Smith"
                                            @Text {
                                                size = :sm,
                                                color = "text-slate-600 dark:text-slate-400",
                                            } "john.smith@company.com"
                                        end
                                    end
                                end
                                @td "Engineering"
                                @td begin
                                    @Badge {variant = :success} "Active"
                                end
                                @td "Jan 15, 2022"
                                @td begin
                                    @Stack {direction = :horizontal, gap = 2} begin
                                        @Link {href = "#"} "Edit"
                                        @text " | "
                                        @Link {
                                            href = "#",
                                            color = "text-red-600 dark:text-red-400",
                                        } "Delete"
                                    end
                                end
                            end

                            @tr begin
                                @td begin
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 3,
                                        align = :center,
                                    } begin
                                        @Avatar {fallback = "ED", size = :sm}
                                        @Stack {gap = 0} begin
                                            @Text {weight = :medium} "Emily Davis"
                                            @Text {
                                                size = :sm,
                                                color = "text-slate-600 dark:text-slate-400",
                                            } "emily.davis@company.com"
                                        end
                                    end
                                end
                                @td "Marketing"
                                @td begin
                                    @Badge {variant = :warning} "On Leave"
                                end
                                @td "Mar 22, 2021"
                                @td begin
                                    @Stack {direction = :horizontal, gap = 2} begin
                                        @Link {href = "#"} "Edit"
                                        @text " | "
                                        @Link {
                                            href = "#",
                                            color = "text-red-600 dark:text-red-400",
                                        } "Delete"
                                    end
                                end
                            end

                            @tr begin
                                @td begin
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 3,
                                        align = :center,
                                    } begin
                                        @Avatar {fallback = "MB", size = :sm}
                                        @Stack {gap = 0} begin
                                            @Text {weight = :medium} "Michael Brown"
                                            @Text {
                                                size = :sm,
                                                color = "text-slate-600 dark:text-slate-400",
                                            } "michael.brown@company.com"
                                        end
                                    end
                                end
                                @td "Sales"
                                @td begin
                                    @Badge {variant = :success} "Active"
                                end
                                @td "Nov 8, 2023"
                                @td begin
                                    @Stack {direction = :horizontal, gap = 2} begin
                                        @Link {href = "#"} "Edit"
                                        @text " | "
                                        @Link {
                                            href = "#",
                                            color = "text-red-600 dark:text-red-400",
                                        } "Delete"
                                    end
                                end
                            end
                        end
                    end

                    @Divider {}

                    @Text {weight = :semibold} "Compact Table"
                    @Table {compact = true, bordered = false} begin
                        @thead begin
                            @tr begin
                                @th "Metric"
                                @th "Value"
                                @th "Change"
                            end
                        end
                        @tbody begin
                            @tr begin
                                @td "Revenue"
                                @td "\$125,420"
                                @td {class = "text-green-600 dark:text-green-400"} "+12.5%"
                            end
                            @tr begin
                                @td "Users"
                                @td "8,291"
                                @td {class = "text-green-600 dark:text-green-400"} "+5.2%"
                            end
                            @tr begin
                                @td "Bounce Rate"
                                @td "42.1%"
                                @td {class = "text-red-600 dark:text-red-400"} "-2.3%"
                            end
                        end
                    end
                end
            end

            # Lists
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "List Component"
                    @Text "Various list styles for different content types."

                    @Grid {cols = 1, md = 2, gap = 6} begin
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Bullet List"
                            @List {variant = :bullet} begin
                                @li "First item in the list"
                                @li "Second item with more content"
                                @li begin
                                    @text "Third item with "
                                    @Link {href = "#"} "a link"
                                end
                                @li "Fourth and final item"
                            end
                        end

                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Numbered List"
                            @List {variant = :number} begin
                                @li "Step one: Initialize project"
                                @li "Step two: Install dependencies"
                                @li "Step three: Configure settings"
                                @li "Step four: Deploy to production"
                            end
                        end

                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Checklist (Visual)"
                            @List {variant = :check, spacing = :loose} begin
                                @li "✓ Completed task"
                                @li "✓ Another finished item"
                                @li "✓ Successfully deployed"
                                @li "○ Pending review"
                            end
                        end

                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Feature List"
                            @List {variant = :none, spacing = :loose} begin
                                @li begin
                                    @Stack {direction = :horizontal, gap = 3} begin
                                        @Icon {
                                            name = "check",
                                            size = :sm,
                                            color = "text-green-600",
                                        }
                                        @Stack {gap = 1} begin
                                            @Text {weight = :medium} "Unlimited Projects"
                                            @Text {
                                                size = :sm,
                                                color = "text-slate-600 dark:text-slate-400",
                                            } "Create as many projects as you need"
                                        end
                                    end
                                end
                                @li begin
                                    @Stack {direction = :horizontal, gap = 3} begin
                                        @Icon {
                                            name = "check",
                                            size = :sm,
                                            color = "text-green-600",
                                        }
                                        @Stack {gap = 1} begin
                                            @Text {weight = :medium} "Team Collaboration"
                                            @Text {
                                                size = :sm,
                                                color = "text-slate-600 dark:text-slate-400",
                                            } "Work together in real-time"
                                        end
                                    end
                                end
                                @li begin
                                    @Stack {direction = :horizontal, gap = 3} begin
                                        @Icon {
                                            name = "check",
                                            size = :sm,
                                            color = "text-green-600",
                                        }
                                        @Stack {gap = 1} begin
                                            @Text {weight = :medium} "Advanced Analytics"
                                            @Text {
                                                size = :sm,
                                                color = "text-slate-600 dark:text-slate-400",
                                            } "Track performance metrics"
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
@deftag macro TableListExample end
