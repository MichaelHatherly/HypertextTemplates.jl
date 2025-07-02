using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Complete Application Example
@component function AppExample()
    @Container {size = "2xl", class = "py-8"} begin
        @Stack {gap = 8} begin
            # Header
            @Card {padding = :lg, shadow = :lg} begin
                @Stack {gap = 6} begin
                    @Stack {direction = :horizontal, justify = :between, align = :center} begin
                        @Stack {gap = 2} begin
                            @Heading {level = 1} "Project Dashboard"
                            @Text {
                                variant = :lead,
                                color = "text-slate-600 dark:text-slate-400",
                            } "Manage your projects and team"
                        end
                        @Stack {direction = :horizontal, gap = 3} begin
                            @Badge {variant = :success, size = :lg} "Pro Plan"
                            @Avatar {fallback = "JD", size = :lg}
                        end
                    end

                    @Tabs {
                        items = [
                            ("overview", "Overview"),
                            ("projects", "Projects"),
                            ("team", "Team"),
                            ("settings", "Settings"),
                        ],
                        active = "overview",
                    } begin
                        @TabPanel {id = "overview"} begin
                            @Stack {gap = 4} begin
                                @Text {
                                    size = :sm,
                                    color = "text-slate-600 dark:text-slate-400",
                                } "Welcome back! Here's what's happening with your projects."
                                @Grid {cols = 1, md = 2, gap = 4} begin
                                    @Card {padding = :sm} begin
                                        @Text {weight = :medium} "Recent Activity"
                                        @Text {size = :sm} "24 commits this week"
                                    end
                                    @Card {padding = :sm} begin
                                        @Text {weight = :medium} "Upcoming Deadlines"
                                        @Text {size = :sm} "3 projects due this month"
                                    end
                                end
                            end
                        end

                        @TabPanel {id = "projects"} begin
                            @Stack {gap = 3} begin
                                @Stack {
                                    direction = :horizontal,
                                    justify = :between,
                                    align = :center,
                                } begin
                                    @Text {weight = :medium} "All Projects"
                                    @Button {size = :sm, variant = :primary} "New Project"
                                end
                                @Text {
                                    size = :sm,
                                    color = "text-slate-600 dark:text-slate-400",
                                } "24 total projects across 4 teams"
                            end
                        end

                        @TabPanel {id = "team"} begin
                            @Stack {gap = 3} begin
                                @Text {weight = :medium} "Team Members"
                                @Grid {cols = 2, md = 4, gap = 3} begin
                                    for i = 1:8
                                        @Stack {gap = 1, align = :center} begin
                                            @Avatar {size = :md, fallback = "U$i"}
                                            @Text {size = :sm} "User $i"
                                        end
                                    end
                                end
                            end
                        end

                        @TabPanel {id = "settings"} begin
                            @Stack {gap = 4} begin
                                @Text {weight = :medium} "Project Settings"
                                @Stack {gap = 3} begin
                                    @Stack {
                                        direction = :horizontal,
                                        justify = :between,
                                        align = :center,
                                    } begin
                                        @Text {size = :sm} "Email Notifications"
                                        @Badge {variant = :success} "Enabled"
                                    end
                                    @Stack {
                                        direction = :horizontal,
                                        justify = :between,
                                        align = :center,
                                    } begin
                                        @Text {size = :sm} "API Access"
                                        @Badge {variant = :warning} "Limited"
                                    end
                                    @Stack {
                                        direction = :horizontal,
                                        justify = :between,
                                        align = :center,
                                    } begin
                                        @Text {size = :sm} "Data Export"
                                        @Badge {} "Available"
                                    end
                                end
                            end
                        end
                    end
                end
            end

            # Stats Grid
            @Grid {cols = 1, sm = 2, lg = 4, gap = 4} begin
                @Card {padding = :md} begin
                    @Stack {gap = 2} begin
                        @Stack {
                            direction = :horizontal,
                            justify = :between,
                            align = :center,
                        } begin
                            @Text {
                                size = :sm,
                                weight = :medium,
                                color = "text-slate-600 dark:text-slate-400",
                            } "Total Projects"
                            @Icon {
                                name = "arrow-right",
                                size = :sm,
                                color = "text-green-600",
                            }
                        end
                        @Text {size = "2xl", weight = :bold} "24"
                        @Progress {value = 75, size = :sm, color = :success}
                    end
                end

                @Card {padding = :md} begin
                    @Stack {gap = 2} begin
                        @Stack {
                            direction = :horizontal,
                            justify = :between,
                            align = :center,
                        } begin
                            @Text {
                                size = :sm,
                                weight = :medium,
                                color = "text-slate-600 dark:text-slate-400",
                            } "Active Tasks"
                            @Icon {name = "check", size = :sm, color = "text-blue-600"}
                        end
                        @Text {size = "2xl", weight = :bold} "142"
                        @Progress {value = 60, size = :sm, color = :primary}
                    end
                end

                @Card {padding = :md} begin
                    @Stack {gap = 2} begin
                        @Stack {
                            direction = :horizontal,
                            justify = :between,
                            align = :center,
                        } begin
                            @Text {
                                size = :sm,
                                weight = :medium,
                                color = "text-slate-600 dark:text-slate-400",
                            } "Team Members"
                            @Icon {name = "plus", size = :sm, color = "text-slate-600"}
                        end
                        @Text {size = "2xl", weight = :bold} "8"
                        @Stack {direction = :horizontal, gap = 1} begin
                            for i = 1:4
                                @Avatar {size = :xs, fallback = string(i)}
                            end
                        end
                    end
                end

                @Card {padding = :md} begin
                    @Stack {gap = 2} begin
                        @Stack {
                            direction = :horizontal,
                            justify = :between,
                            align = :center,
                        } begin
                            @Text {
                                size = :sm,
                                weight = :medium,
                                color = "text-slate-600 dark:text-slate-400",
                            } "Completion"
                            @Spinner {size = :sm}
                        end
                        @Text {size = "2xl", weight = :bold} "87%"
                        @Text {size = :sm, color = "text-green-600 dark:text-green-400"} "+12% from last month"
                    end
                end
            end

            # Main Content Area
            @Grid {cols = 1, lg = 3, gap = 6} begin
                # Projects List
                @div {class = "lg:col-span-2"} begin
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Stack {
                                direction = :horizontal,
                                justify = :between,
                                align = :center,
                            } begin
                                @Heading {level = 2} "Recent Projects"
                                @Link {href = "#", variant = :hover_underline} "View all"
                            end

                            @Table {striped = true, hover = true} begin
                                @thead begin
                                    @tr begin
                                        @th "Project"
                                        @th "Status"
                                        @th "Progress"
                                        @th "Team"
                                    end
                                end
                                @tbody begin
                                    @tr begin
                                        @td begin
                                            @Stack {gap = 1} begin
                                                @Text {weight = :semibold} "Website Redesign"
                                                @Text {
                                                    size = :sm,
                                                    color = "text-slate-600 dark:text-slate-400",
                                                } "Due in 2 weeks"
                                            end
                                        end
                                        @td begin
                                            @Badge {variant = :success} "On Track"
                                        end
                                        @td begin
                                            @Progress {value = 65, size = :sm}
                                        end
                                        @td begin
                                            @Stack {direction = :horizontal, gap = 1} begin
                                                @Avatar {size = :xs, fallback = "A"}
                                                @Avatar {size = :xs, fallback = "B"}
                                                @Avatar {size = :xs, fallback = "C"}
                                            end
                                        end
                                    end

                                    @tr begin
                                        @td begin
                                            @Stack {gap = 1} begin
                                                @Text {weight = :semibold} "Mobile App"
                                                @Text {
                                                    size = :sm,
                                                    color = "text-slate-600 dark:text-slate-400",
                                                } "Due next month"
                                            end
                                        end
                                        @td begin
                                            @Badge {variant = :warning} "At Risk"
                                        end
                                        @td begin
                                            @Progress {
                                                value = 35,
                                                size = :sm,
                                                color = :warning,
                                            }
                                        end
                                        @td begin
                                            @Stack {direction = :horizontal, gap = 1} begin
                                                @Avatar {size = :xs, fallback = "D"}
                                                @Avatar {size = :xs, fallback = "E"}
                                            end
                                        end
                                    end

                                    @tr begin
                                        @td begin
                                            @Stack {gap = 1} begin
                                                @Text {weight = :semibold} "API Integration"
                                                @Text {
                                                    size = :sm,
                                                    color = "text-slate-600 dark:text-slate-400",
                                                } "Due in 3 days"
                                            end
                                        end
                                        @td begin
                                            @Badge {variant = :primary} "In Progress"
                                        end
                                        @td begin
                                            @Progress {value = 85, size = :sm}
                                        end
                                        @td begin
                                            @Stack {direction = :horizontal, gap = 1} begin
                                                @Avatar {size = :xs, fallback = "F"}
                                                @Avatar {size = :xs, fallback = "G"}
                                                @Avatar {size = :xs, fallback = "H"}
                                            end
                                        end
                                    end
                                end
                            end

                            @Pagination {current = 1, total = 5}
                        end
                    end
                end

                # Sidebar
                @Stack {gap = 4} begin
                    # Activity Feed
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 3} "Recent Activity"

                            @List {variant = :none, spacing = :loose} begin
                                @li begin
                                    @Stack {gap = 1} begin
                                        @Stack {
                                            direction = :horizontal,
                                            gap = 2,
                                            align = :center,
                                        } begin
                                            @Avatar {size = :sm, fallback = "JD"}
                                            @Text {size = :sm, weight = :medium} "John deployed to production"
                                        end
                                        @Text {
                                            size = :sm,
                                            color = "text-slate-600 dark:text-slate-400",
                                        } "2 hours ago"
                                    end
                                end

                                @li begin
                                    @Stack {gap = 1} begin
                                        @Stack {
                                            direction = :horizontal,
                                            gap = 2,
                                            align = :center,
                                        } begin
                                            @Avatar {size = :sm, fallback = "AS"}
                                            @Text {size = :sm, weight = :medium} "Alice completed task #142"
                                        end
                                        @Text {
                                            size = :sm,
                                            color = "text-slate-600 dark:text-slate-400",
                                        } "5 hours ago"
                                    end
                                end

                                @li begin
                                    @Stack {gap = 1} begin
                                        @Stack {
                                            direction = :horizontal,
                                            gap = 2,
                                            align = :center,
                                        } begin
                                            @Avatar {size = :sm, fallback = "MJ"}
                                            @Text {size = :sm, weight = :medium} "Mike joined the team"
                                        end
                                        @Text {
                                            size = :sm,
                                            color = "text-slate-600 dark:text-slate-400",
                                        } "Yesterday"
                                    end
                                end
                            end
                        end
                    end

                    # Quick Actions
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 3} "Quick Actions"

                            @Stack {gap = 2} begin
                                @button {
                                    class = "w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors text-sm font-medium",
                                } "Create New Project"

                                @button {
                                    class = "w-full px-4 py-2 border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors text-sm font-medium",
                                } "Invite Team Member"

                                @button {
                                    class = "w-full px-4 py-2 border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors text-sm font-medium",
                                } "View Reports"
                            end
                        end
                    end
                end
            end
        end
    end
end
@deftag macro AppExample end
