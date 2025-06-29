# Advanced Component Examples
# Showcases complex component compositions and advanced features

@component function AdvancedComponentsExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Advanced Component Features"

            # Complex Table with Modern Styling
            @Card {padding = :lg, shadow = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Advanced Table Features"

                    @Table {
                        striped = true,
                        hover = true,
                        bordered = false,
                        caption = "Employee performance metrics",
                    } begin
                        @thead begin
                            @tr begin
                                @th "Employee"
                                @th "Department"
                                @th "Performance"
                                @th "Projects"
                                @th "Rating"
                            end
                        end
                        @tbody begin
                            for i = 1:10
                                @tr begin
                                    @td begin
                                        @Stack {
                                            direction = :horizontal,
                                            gap = 3,
                                            align = :center,
                                        } begin
                                            @Avatar {
                                                src = "https://i.pravatar.cc/150?img=$(i)",
                                                alt = "Picture of Employee $i",
                                                fallback = "E$i",
                                                size = :sm,
                                            }
                                            @Stack {gap = 0} begin
                                                @Text {weight = :medium} "Employee $i"
                                                @Text {size = :sm, color = "text-gray-500"} "employee$i@company.com"
                                            end
                                        end
                                    end
                                    @td begin
                                        dept =
                                            ["Engineering", "Design", "Marketing", "Sales"][mod(
                                                i-1,
                                                4,
                                            )+1]
                                        @Badge {
                                            variant =
                                                [:primary, :secondary, :warning, :success][mod(
                                                    i-1,
                                                    4,
                                                )+1],
                                        } $dept
                                    end
                                    @td begin
                                        perf = 60 + i * 4
                                        @Stack {gap = 1} begin
                                            @Progress {
                                                value = perf,
                                                size = :sm,
                                                color = perf > 80 ? :success : :primary,
                                            }
                                            @Text {size = :xs, align = :center} "$perf%"
                                        end
                                    end
                                    @td begin
                                        @div {class = "flex items-center"} begin
                                            @div {class = "flex -space-x-2"} begin
                                                for j = 1:min(3, i)
                                                    colors = [
                                                        "bg-blue-500",
                                                        "bg-green-500",
                                                        "bg-purple-500",
                                                    ]
                                                    # Add z-index to ensure proper stacking
                                                    z_index = 4 - j  # Higher index for earlier items
                                                    @Avatar {
                                                        size = :xs,
                                                        fallback = "P$j",
                                                        class = "ring-2 ring-white dark:ring-gray-900 $(colors[j]) relative",
                                                        style = "z-index: $z_index;",
                                                    }
                                                end
                                            end
                                            if i > 3
                                                @div {
                                                    class = "ml-1 flex items-center justify-center w-6 h-6 rounded-full bg-gray-300 dark:bg-gray-700 text-xs font-medium ring-2 ring-white dark:ring-gray-900 text-gray-700 dark:text-gray-300",
                                                } "+$(i-3)"
                                            end
                                        end
                                    end
                                    @td begin
                                        rating = min(5, 3 + mod(i, 3))
                                        @Stack {direction = :horizontal, gap = 1} begin
                                            for star = 1:5
                                                if star <= rating
                                                    @Icon {
                                                        name = "star",
                                                        size = :sm,
                                                        color = "text-amber-500",
                                                    }
                                                else
                                                    @Icon {
                                                        name = "star",
                                                        size = :sm,
                                                        color = "text-gray-300",
                                                    }
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

            # Advanced Form with Validation States
            @Card {padding = :lg, variant = :gradient} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Advanced Form Patterns"

                    @form {class = "space-y-6"} begin
                        # Multi-column form layout
                        @Grid {cols = 1, md = 2, gap = 6} begin
                            @FormGroup {
                                label = "Project Name",
                                help = "Choose a unique name for your project",
                                required = true,
                            } begin
                                @Input {
                                    placeholder = "my-awesome-project",
                                    icon = """<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path></svg>""",
                                }
                            end

                            @FormGroup {
                                label = "Environment",
                                help = "Select deployment environment",
                            } begin
                                @Select {
                                    options = [
                                        ("", "Choose environment"),
                                        ("dev", "Development"),
                                        ("staging", "Staging"),
                                        ("prod", "Production"),
                                    ],
                                }
                            end
                        end

                        # Full width description
                        @FormGroup {
                            label = "Project Description",
                            help = "Provide a detailed description of your project",
                        } begin
                            @Textarea {
                                rows = 4,
                                placeholder = "This project aims to...",
                                resize = :vertical,
                            }
                        end

                        # Advanced checkbox group
                        @FormGroup {label = "Features to Enable"} begin
                            @Card {padding = :sm, shadow = :sm} begin
                                @Stack {gap = 3} begin
                                    @div {
                                        class = "divide-y divide-gray-200 dark:divide-gray-700",
                                    } begin
                                        @div {class = "py-3 first:pt-0"} begin
                                            @Stack {
                                                direction = :horizontal,
                                                justify = :between,
                                                align = :center,
                                            } begin
                                                @Stack {gap = 1} begin
                                                    @Checkbox {
                                                        name = "ci_cd",
                                                        label = "CI/CD Pipeline",
                                                    }
                                                    @Text {
                                                        size = :sm,
                                                        color = "text-gray-500",
                                                    } "Automated testing and deployment"
                                                end
                                                @Badge {variant = :success, size = :sm} "Recommended"
                                            end
                                        end

                                        @div {class = "py-3"} begin
                                            @Stack {
                                                direction = :horizontal,
                                                justify = :between,
                                                align = :center,
                                            } begin
                                                @Stack {gap = 1} begin
                                                    @Checkbox {
                                                        name = "monitoring",
                                                        label = "Application Monitoring",
                                                    }
                                                    @Text {
                                                        size = :sm,
                                                        color = "text-gray-500",
                                                    } "Real-time performance tracking"
                                                end
                                                @Badge {variant = :primary, size = :sm} "Popular"
                                            end
                                        end

                                        @div {class = "py-3 last:pb-0"} begin
                                            @Stack {
                                                direction = :horizontal,
                                                justify = :between,
                                                align = :center,
                                            } begin
                                                @Stack {gap = 1} begin
                                                    @Checkbox {
                                                        name = "analytics",
                                                        label = "Analytics Dashboard",
                                                    }
                                                    @Text {
                                                        size = :sm,
                                                        color = "text-gray-500",
                                                    } "Usage statistics and insights"
                                                end
                                                @Badge {variant = :warning, size = :sm} "Beta"
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        # Advanced radio group with descriptions
                        @FormGroup {label = "Deployment Strategy"} begin
                            @Stack {gap = 3} begin
                                @Card {padding = :sm, shadow = :sm, hoverable = true} begin
                                    @Stack {gap = 2} begin
                                        @Radio {
                                            name = "deployment",
                                            options = [("rolling", "Rolling Deployment")],
                                            value = "rolling",
                                        }
                                        @Text {
                                            size = :sm,
                                            color = "text-gray-600 dark:text-gray-400",
                                            class = "ml-6",
                                        } begin
                                            "Gradually replace instances with zero downtime"
                                        end
                                    end
                                end

                                @Card {padding = :sm, shadow = :sm, hoverable = true} begin
                                    @Stack {gap = 2} begin
                                        @Radio {
                                            name = "deployment",
                                            options =
                                                [("blue_green", "Blue/Green Deployment")],
                                        }
                                        @Text {
                                            size = :sm,
                                            color = "text-gray-600 dark:text-gray-400",
                                            class = "ml-6",
                                        } begin
                                            "Switch between two identical environments"
                                        end
                                    end
                                end

                                @Card {padding = :sm, shadow = :sm, hoverable = true} begin
                                    @Stack {gap = 2} begin
                                        @Radio {
                                            name = "deployment",
                                            options = [("canary", "Canary Deployment")],
                                        }
                                        @Text {
                                            size = :sm,
                                            color = "text-gray-600 dark:text-gray-400",
                                            class = "ml-6",
                                        } begin
                                            "Test with a small percentage of traffic first"
                                        end
                                    end
                                end
                            end
                        end

                        # Action buttons
                        @Stack {direction = :horizontal, gap = 3, justify = :end} begin
                            @Button {variant = :ghost, rounded = :lg} "Save as Draft"
                            @Button {variant = :outline, rounded = :lg} "Preview"
                            @Button {
                                variant = :gradient,
                                rounded = :lg,
                                icon_right = """<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path></svg>""",
                            } "Deploy Project"
                        end
                    end
                end
            end

            # Complex Dashboard Cards
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Dashboard Card Compositions"

                    @Grid {cols = 1, md = 2, lg = 3, gap = 4} begin
                        # Metric card with trend
                        @Card {padding = :base, hoverable = true} begin
                            @Stack {gap = 3} begin
                                @Stack {
                                    direction = :horizontal,
                                    justify = :between,
                                    align = :start,
                                } begin
                                    @Icon {
                                        name = "arrow-up",
                                        size = :lg,
                                        color = "text-emerald-500",
                                    }
                                    @Badge {variant = :success, size = :sm} "+23%"
                                end
                                @Stack {gap = 1} begin
                                    @Text {
                                        size = :sm,
                                        color = "text-gray-600 dark:text-gray-400",
                                    } "Total Revenue"
                                    @Heading {level = 3, size = "2xl"} "\$48,291"
                                end
                                @Progress {value = 78, size = :sm, color = :success}
                            end
                        end

                        # Activity feed card
                        @Card {padding = :base, variant = :glass} begin
                            @Stack {gap = 3} begin
                                @Stack {direction = :horizontal, justify = :between} begin
                                    @Text {weight = :semibold} "Recent Activity"
                                    @Spinner {size = :sm}
                                end
                                @Stack {gap = 2} begin
                                    for i = 1:3
                                        @Stack {
                                            direction = :horizontal,
                                            gap = 2,
                                            align = :start,
                                        } begin
                                            @div {
                                                class = "mt-1 w-2 h-2 rounded-full bg-blue-500 flex-shrink-0",
                                            }
                                            @Stack {gap = 0} begin
                                                @Text {size = :sm} "User action #$i"
                                                @Text {size = :xs, color = "text-gray-500"} "$(5*i) min ago"
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        # Status card with icons
                        @Card {padding = :base, border = :glow, glow = :primary} begin
                            @Stack {gap = 3} begin
                                @Stack {direction = :horizontal, justify = :between} begin
                                    @Text {weight = :semibold} "System Status"
                                    @Badge {variant = :primary, animated = true} "Live"
                                end
                                @Stack {gap = 2} begin
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 2,
                                        align = :center,
                                    } begin
                                        @Icon {
                                            name = "check",
                                            size = :sm,
                                            color = "text-emerald-500",
                                        }
                                        @Text {size = :sm} "API: Operational"
                                    end
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 2,
                                        align = :center,
                                    } begin
                                        @Icon {
                                            name = "check",
                                            size = :sm,
                                            color = "text-emerald-500",
                                        }
                                        @Text {size = :sm} "Database: Healthy"
                                    end
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 2,
                                        align = :center,
                                    } begin
                                        @Icon {
                                            name = "alert",
                                            size = :sm,
                                            color = "text-amber-500",
                                        }
                                        @Text {size = :sm} "CDN: High latency"
                                    end
                                end
                            end
                        end
                    end
                end
            end

            # Advanced List Compositions
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Advanced List Patterns"

                    @Grid {cols = 1, md = 2, gap = 6} begin
                        # Timeline list
                        @Stack {gap = 4} begin
                            @Heading {level = 3} "Timeline"
                            @Timeline begin
                                for i = 1:4
                                    @TimelineItem {icon = string(i), last = i == 4} begin
                                        @TimelineContent {
                                            title = "Milestone $i",
                                            subtitle = "$(i*2) hours ago",
                                        } begin
                                            @Text {
                                                size = :sm,
                                                color = "text-gray-600 dark:text-gray-400",
                                            } "Completed important task with significant impact"
                                        end
                                    end
                                end
                            end
                        end

                        # Feature comparison list
                        @Stack {gap = 4} begin
                            @Heading {level = 3} "Feature Comparison"
                            @Card {padding = :base, variant = :gradient} begin
                                @Stack {gap = 3} begin
                                    @Stack {
                                        direction = :horizontal,
                                        justify = :between,
                                        align = :center,
                                    } begin
                                        @Text {weight = :bold} "Pro Plan"
                                        @Badge {variant = :gradient} "Popular"
                                    end

                                    @List {variant = :none, spacing = :normal} begin
                                        features = [
                                            ("Unlimited projects", true),
                                            ("Advanced analytics", true),
                                            ("Priority support", true),
                                            ("Custom domains", true),
                                            ("White-label options", false),
                                        ]

                                        for (feature, included) in features
                                            @li begin
                                                @Stack {
                                                    direction = :horizontal,
                                                    gap = 2,
                                                    align = :center,
                                                } begin
                                                    if included
                                                        @Icon {
                                                            name = "check",
                                                            size = :sm,
                                                            color = "text-emerald-500",
                                                        }
                                                    else
                                                        @Icon {
                                                            name = "x",
                                                            size = :sm,
                                                            color = "text-gray-400",
                                                        }
                                                    end
                                                    @Text {
                                                        size = :sm,
                                                        color =
                                                            included ? nothing :
                                                            "text-gray-500 dark:text-gray-600",
                                                    } feature
                                                end
                                            end
                                        end
                                    end

                                    @Button {
                                        variant = :primary,
                                        full_width = true,
                                        rounded = :lg,
                                    } begin
                                        "Upgrade to Pro"
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
@deftag macro AdvancedComponentsExample end
