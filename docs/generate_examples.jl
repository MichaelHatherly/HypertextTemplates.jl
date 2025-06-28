using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Component for complete HTML document with Tailwind CSS
@component function HTMLDocument(; title::String, current_page::String = "")
    @html {lang = "en"} begin
        @head begin
            @meta {charset = "UTF-8"}
            @meta {name = "viewport", content = "width=device-width, initial-scale=1.0"}
            @title title
            @script {src = "https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"}
            @script begin
                HypertextTemplates.SafeString("""
                tailwind.config = {
                    darkMode: 'class',
                    theme: {
                        extend: {}
                    }
                }
                """)
            end
        end
        @body {
            class = "bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 min-h-screen flex",
        } begin
            # Navigation sidebar - not fixed, part of flex layout
            @div {
                class = "w-80 bg-white dark:bg-slate-800 border-r border-slate-200 dark:border-slate-700 overflow-y-auto flex-shrink-0",
            } begin
                @div {class = "p-6"} begin
                    @Stack {gap = 6} begin
                        # Header
                        @Stack {gap = 2} begin
                            @Heading {level = 3, size = :lg} "Components"
                            @Text {size = :sm, color = "text-slate-600 dark:text-slate-400"} "Browse all component examples"
                        end

                        # Navigation links
                        @Stack {gap = 1} begin
                            for (href, label) in [
                                ("layout-components.html", "Layout Components"),
                                ("typography-components.html", "Typography Components"),
                                ("form-components.html", "Form Components"),
                                ("feedback-components.html", "Feedback Components"),
                                ("navigation-components.html", "Navigation Components"),
                                ("table-list-components.html", "Table & List Components"),
                                ("utility-components.html", "Utility Components"),
                                ("complete-app.html", "Complete Application"),
                            ]
                                is_current = href == current_page
                                link_class = if is_current
                                    "block px-3 py-2 rounded-lg bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300 font-medium"
                                else
                                    "block px-3 py-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300 transition-colors"
                                end

                                @a {
                                    href = href,
                                    class = link_class,
                                    "aria-current" = is_current ? "page" : nothing,
                                } $label
                            end
                        end

                        @Divider {}

                        # Back to docs link
                        @a {
                            href = "../library-components",
                            class = "inline-flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 transition-colors",
                        } begin
                            @text "← Back to documentation"
                        end
                    end
                end
            end

            # Main content area
            @div {class = "flex-1 overflow-y-auto p-8"} begin
                @__slot__()
            end
        end
    end
end
@deftag macro HTMLDocument end

# Ensure build directory exists
build_dir = joinpath(@__DIR__, "src", "examples")
mkpath(build_dir)

println("Generating component examples...")

# 1. Layout Components Example
@component function LayoutExample()
    @div begin
        @Section {spacing = :lg} begin
            @Container begin
                @Stack {gap = 8} begin
                    @Heading {level = 1, class = "text-center mb-8"} "Layout Components Demo"

                    # Container example
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Container Component"
                            @Text "Containers provide responsive max-widths and padding."

                            @Container {
                                size = :sm,
                                padding = true,
                                centered = true,
                                class = "bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg",
                            } begin
                                @Text {size = :sm} "Small container (max-width: 640px)"
                            end

                            @Container {
                                size = :md,
                                padding = true,
                                centered = true,
                                class = "bg-green-50 dark:bg-green-900/20 p-4 rounded-lg mt-4",
                            } begin
                                @Text {size = :sm} "Medium container (max-width: 768px)"
                            end
                        end
                    end

                    # Stack example
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Stack Component"
                            @Text "Stack components arrange children with consistent spacing."

                            @Stack {
                                direction = :horizontal,
                                gap = 4,
                                align = :center,
                                class = "bg-slate-100 dark:bg-slate-800 p-4 rounded",
                            } begin
                                @Badge {variant = :primary} "Item 1"
                                @Badge {variant = :success} "Item 2"
                                @Badge {variant = :warning} "Item 3"
                            end

                            @Stack {
                                direction = :vertical,
                                gap = 2,
                                class = "bg-slate-100 dark:bg-slate-800 p-4 rounded mt-4",
                            } begin
                                @Text {weight = :semibold} "Vertical Stack:"
                                @Text {size = :sm} "First item"
                                @Text {size = :sm} "Second item"
                                @Text {size = :sm} "Third item"
                            end
                        end
                    end

                    # Grid example
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Grid Component"
                            @Text "Responsive grid layout that adapts to screen size."

                            @Grid {cols = 1, sm = 2, md = 3, lg = 4, gap = 4} begin
                                for i = 1:8
                                    @Card {padding = :sm, shadow = :sm} begin
                                        @Text {align = :center, weight = :semibold} "Grid Item $i"
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
@deftag macro LayoutExample end

layout_html = @render @HTMLDocument {
    title = "Layout Components - HypertextTemplates",
    current_page = "layout-components.html",
} begin
    @LayoutExample {}
end

write(joinpath(build_dir, "layout-components.html"), layout_html)

# 2. Typography Components Example
@component function TypographyExample()
    @div begin
        @Section {spacing = :lg} begin
            @Container begin
                @Stack {gap = 8} begin
                    @Heading {level = 1, class = "text-center mb-8"} "Typography Components Demo"

                    # Headings
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Heading Component"
                            @Text "Multiple heading levels with customizable styles."

                            @Stack {gap = 3} begin
                                @Heading {level = 1} "H1: Main Page Title"
                                @Heading {level = 2} "H2: Section Heading"
                                @Heading {level = 3} "H3: Subsection Heading"
                                @Heading {
                                    level = 4,
                                    color = "text-blue-600 dark:text-blue-400",
                                } "H4: Colored Heading"
                                @Heading {level = 5, weight = :normal} "H5: Normal Weight Heading"
                                @Heading {level = 6, size = :lg} "H6: Custom Size Heading"
                            end
                        end
                    end

                    # Text variants
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Text Component"
                            @Text "Different text styles for various use cases."

                            @Stack {gap = 3} begin
                                @Text {variant = :lead, align = :center} "Lead text is perfect for introductions and important paragraphs that need to stand out."
                                @Text {variant = :body} "Body text is the default style for regular paragraph content. It provides good readability for longer passages."
                                @Text {
                                    variant = :small,
                                    color = "text-slate-600 dark:text-slate-400",
                                } "Small text is useful for captions, help text, and secondary information."
                                @Text {weight = :semibold} "Semibold text for emphasis"
                                @Text {
                                    weight = :bold,
                                    color = "text-red-600 dark:text-red-400",
                                } "Bold colored text for warnings"
                            end
                        end
                    end

                    # Links
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Link Component"
                            @Text "Styled links with hover effects."

                            @Stack {gap = 2} begin
                                @Text begin
                                    @text "Visit our "
                                    @Link {href = "#"} "documentation"
                                    @text " for more information."
                                end
                                @Text begin
                                    @Link {href = "#", variant = :underline} "Always underlined link"
                                    @text " | "
                                    @Link {href = "#", variant = :hover_underline} "Underline on hover"
                                end
                                @Text begin
                                    @Link {href = "https://github.com", external = true} "External link to GitHub"
                                    @text " (opens in new tab)"
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
@deftag macro TypographyExample end

typography_html = @render @HTMLDocument {
    title = "Typography Components - HypertextTemplates",
    current_page = "typography-components.html",
} begin
    @TypographyExample {}
end

write(joinpath(build_dir, "typography-components.html"), typography_html)

# 3. Form Components Example
@component function FormExample()
    @div begin
        @Section {spacing = :lg} begin
            @Container begin
                @Stack {gap = 8} begin
                    @Heading {level = 1, class = "text-center mb-8"} "Form Components Demo"

                    # Complete form example
                    @Card {padding = :lg} begin
                        @form {method = "post", action = "#"} begin
                            @Stack {gap = 6} begin
                                @Heading {level = 2} "User Registration Form"

                                # Text inputs
                                @Grid {cols = 1, md = 2, gap = 4} begin
                                    @FormGroup {label = "First Name", required = true} begin
                                        @Input {
                                            name = "first_name",
                                            placeholder = "John",
                                            required = true,
                                        }
                                    end

                                    @FormGroup {label = "Last Name", required = true} begin
                                        @Input {
                                            name = "last_name",
                                            placeholder = "Doe",
                                            required = true,
                                        }
                                    end
                                end

                                @FormGroup {
                                    label = "Email Address",
                                    help = "We'll never share your email",
                                    required = true,
                                } begin
                                    @Input {
                                        type = "email",
                                        name = "email",
                                        placeholder = "john@example.com",
                                        required = true,
                                    }
                                end

                                @FormGroup {
                                    label = "Password",
                                    help = "Must be at least 8 characters",
                                } begin
                                    @Input {
                                        type = "password",
                                        name = "password",
                                        placeholder = "••••••••",
                                    }
                                end

                                # Select
                                @FormGroup {label = "Country"} begin
                                    @Select {
                                        name = "country",
                                        options = [
                                            ("", "Select a country"),
                                            ("us", "United States"),
                                            ("uk", "United Kingdom"),
                                            ("ca", "Canada"),
                                            ("au", "Australia"),
                                            ("de", "Germany"),
                                            ("fr", "France"),
                                        ],
                                    }
                                end

                                # Textarea
                                @FormGroup {label = "Bio", help = "Tell us about yourself"} begin
                                    @Textarea {
                                        name = "bio",
                                        rows = 4,
                                        placeholder = "I'm a developer who loves...",
                                    }
                                end

                                # Radio buttons
                                @FormGroup {label = "Account Type"} begin
                                    @Radio {
                                        name = "account_type",
                                        options = [
                                            ("personal", "Personal Account"),
                                            ("business", "Business Account"),
                                            ("developer", "Developer Account"),
                                        ],
                                        value = "personal",
                                    }
                                end

                                # Checkboxes
                                @FormGroup {label = "Preferences"} begin
                                    @Stack {gap = 2} begin
                                        @Checkbox {
                                            name = "newsletter",
                                            label = "Subscribe to newsletter",
                                            checked = true,
                                        }
                                        @Checkbox {
                                            name = "updates",
                                            label = "Receive product updates",
                                        }
                                        @Checkbox {
                                            name = "marketing",
                                            label = "Marketing communications",
                                        }
                                    end
                                end

                                @Divider {}

                                # Submit button (styled)
                                @button {
                                    type = "submit",
                                    class = "px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg transition-colors",
                                } "Create Account"
                            end
                        end
                    end

                    # Form states demo
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Form States"

                            @Grid {cols = 1, md = 3, gap = 4} begin
                                @FormGroup {label = "Default State"} begin
                                    @Input {placeholder = "Normal input"}
                                end

                                @FormGroup {label = "Success State", help = "Valid input"} begin
                                    @Input {
                                        state = :success,
                                        value = "Valid data",
                                        placeholder = "Success",
                                    }
                                end

                                @FormGroup {
                                    label = "Error State",
                                    error = "This field is required",
                                } begin
                                    @Input {state = :error, placeholder = "Error state"}
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
@deftag macro FormExample end

form_html = @render @HTMLDocument {
    title = "Form Components - HypertextTemplates",
    current_page = "form-components.html",
} begin
    @FormExample {}
end

write(joinpath(build_dir, "form-components.html"), form_html)

# 4. Feedback Components Example
@component function FeedbackExample()
    @div begin
        @Section {spacing = :lg} begin
            @Container begin
                @Stack {gap = 8} begin
                    @Heading {level = 1, class = "text-center mb-8"} "Feedback Components Demo"

                    # Alerts
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Alert Component"
                            @Text "Display important messages to users."

                            @Stack {gap = 3} begin
                                @Alert {variant = :info} begin
                                    @strong "Information:"
                                    @text " This is an informational alert with important details."
                                end

                                @Alert {variant = :success, dismissible = true} begin
                                    @strong "Success!"
                                    @text " Your changes have been saved successfully."
                                end

                                @Alert {variant = :warning} begin
                                    @strong "Warning:"
                                    @text " Please review your input before proceeding."
                                end

                                @Alert {variant = :error} begin
                                    @strong "Error:"
                                    @text " There was a problem processing your request."
                                end
                            end
                        end
                    end

                    # Progress bars
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Progress Component"
                            @Text "Show task completion and loading states."

                            @Stack {gap = 4} begin
                                @Progress {value = 25, label = "Basic Progress"}
                                @Progress {
                                    value = 50,
                                    color = :primary,
                                    label = "Primary Color",
                                }
                                @Progress {
                                    value = 75,
                                    color = :success,
                                    striped = true,
                                    label = "Striped Progress",
                                }
                                @Progress {
                                    value = 90,
                                    size = :lg,
                                    label = "Large Progress Bar",
                                }

                                @Stack {gap = 2} begin
                                    @Text {size = :sm, weight = :semibold} "File Upload Progress"
                                    @Progress {value = 63, max = 100, striped = true}
                                    @Text {
                                        size = :sm,
                                        color = "text-slate-600 dark:text-slate-400",
                                    } "63% complete (63MB of 100MB)"
                                end
                            end
                        end
                    end

                    # Spinners
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Spinner Component"
                            @Text "Loading indicators for async operations."

                            @Stack {direction = :horizontal, gap = 6, align = :center} begin
                                @Stack {gap = 2, align = :center} begin
                                    @Spinner {size = :sm}
                                    @Text {size = :sm} "Small"
                                end

                                @Stack {gap = 2, align = :center} begin
                                    @Spinner {size = :md}
                                    @Text {size = :sm} "Medium"
                                end

                                @Stack {gap = 2, align = :center} begin
                                    @Spinner {size = :lg, color = :primary}
                                    @Text {size = :sm} "Large"
                                end

                                @Stack {
                                    gap = 2,
                                    align = :center,
                                    class = "bg-blue-600 p-4 rounded",
                                } begin
                                    @Spinner {size = :md, color = :white}
                                    @Text {size = :sm, color = "text-white"} "White"
                                end
                            end

                            @Card {padding = :md, class = "bg-slate-100 dark:bg-slate-800"} begin
                                @Stack {direction = :horizontal, gap = 3, align = :center} begin
                                    @Spinner {size = :sm}
                                    @Text "Loading user data..."
                                end
                            end
                        end
                    end

                    # Badges
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Badge Component"
                            @Text "Small labels for status and categories."

                            @Stack {gap = 4} begin
                                @Stack {direction = :horizontal, gap = 2, align = :center} begin
                                    @Badge {} "Default"
                                    @Badge {variant = :primary} "Primary"
                                    @Badge {variant = :success} "Success"
                                    @Badge {variant = :warning} "Warning"
                                    @Badge {variant = :danger} "Danger"
                                end

                                @Stack {direction = :horizontal, gap = 3, align = :center} begin
                                    @Text "Sizes:"
                                    @Badge {size = :sm} "Small"
                                    @Badge {size = :md} "Medium"
                                    @Badge {size = :lg} "Large"
                                end

                                @Card {padding = :md, shadow = :sm} begin
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 4,
                                        align = :center,
                                        justify = :between,
                                    } begin
                                        @Stack {gap = 1} begin
                                            @Text {weight = :semibold} "Premium Plan"
                                            @Text {
                                                size = :sm,
                                                color = "text-slate-600 dark:text-slate-400",
                                            } "Full access to all features"
                                        end
                                        @Badge {variant = :success} "Active"
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
@deftag macro FeedbackExample end

feedback_html = @render @HTMLDocument {
    title = "Feedback Components - HypertextTemplates",
    current_page = "feedback-components.html",
} begin
    @FeedbackExample {}
end

write(joinpath(build_dir, "feedback-components.html"), feedback_html)

# 5. Navigation Components Example
@component function NavigationExample()
    @div begin
        @Section {spacing = :lg} begin
            @Container begin
                @Stack {gap = 8} begin
                    @Heading {level = 1, class = "text-center mb-8"} "Navigation Components Demo"

                    # Breadcrumbs
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Breadcrumb Component"
                            @Text "Show user location in site hierarchy."

                            @Stack {gap = 4} begin
                                @Breadcrumb {
                                    items = [
                                        ("/", "Home"),
                                        ("/products", "Products"),
                                        ("/products/electronics", "Electronics"),
                                        ("/products/electronics/phones", "Phones"),
                                    ],
                                }

                                @Breadcrumb {
                                    separator = " > ",
                                    items = [
                                        ("/admin", "Admin"),
                                        ("/admin/users", "Users"),
                                        ("/admin/users/edit", "Edit User"),
                                    ],
                                }
                            end
                        end
                    end

                    # Tabs
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Tabs Component"
                            @Text "Tab navigation interface (visual only)."

                            @Tabs {
                                items = [
                                    ("overview", "Overview"),
                                    ("features", "Features"),
                                    ("pricing", "Pricing"),
                                    ("reviews", "Reviews"),
                                    ("support", "Support"),
                                ],
                                active = "features",
                            }

                            @Card {padding = :md, class = "mt-4"} begin
                                @Text "Tab content would appear here. The Features tab is currently active."
                            end
                        end
                    end

                    # Pagination
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Pagination Component"
                            @Text "Navigate through multiple pages of content."

                            @Stack {gap = 4} begin
                                @Text {size = :sm, weight = :semibold} "Basic Pagination"
                                @Pagination {current = 5, total = 10}

                                @Divider {}

                                @Text {size = :sm, weight = :semibold} "Extended Pagination"
                                @Pagination {current = 7, total = 20, siblings = 2}

                                @Divider {}

                                @Text {size = :sm, weight = :semibold} "First Page"
                                @Pagination {current = 1, total = 5}
                            end
                        end
                    end
                end
            end
        end
    end
end
@deftag macro NavigationExample end

navigation_html = @render @HTMLDocument {
    title = "Navigation Components - HypertextTemplates",
    current_page = "navigation-components.html",
} begin
    @NavigationExample {}
end

write(joinpath(build_dir, "navigation-components.html"), navigation_html)

# 6. Complete Application Example
@component function AppExample()
    @div begin
        @Section {spacing = :lg} begin
            @Container {size = "2xl"} begin
                @Stack {gap = 8} begin
                    # Header
                    @Card {padding = :lg, shadow = :lg} begin
                        @Stack {gap = 6} begin
                            @Stack {
                                direction = :horizontal,
                                justify = :between,
                                align = :center,
                            } begin
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
                            }
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
                                    @Icon {
                                        name = "check",
                                        size = :sm,
                                        color = "text-blue-600",
                                    }
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
                                    @Icon {
                                        name = "plus",
                                        size = :sm,
                                        color = "text-slate-600",
                                    }
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
                                @Text {
                                    size = :sm,
                                    color = "text-green-600 dark:text-green-400",
                                } "+12% from last month"
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
                                                    @Stack {
                                                        direction = :horizontal,
                                                        gap = 1,
                                                    } begin
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
                                                    @Stack {
                                                        direction = :horizontal,
                                                        gap = 1,
                                                    } begin
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
                                                    @Stack {
                                                        direction = :horizontal,
                                                        gap = 1,
                                                    } begin
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
    end
end
@deftag macro AppExample end

app_html = @render @HTMLDocument {
    title = "Complete Application - HypertextTemplates",
    current_page = "complete-app.html",
} begin
    @AppExample {}
end

write(joinpath(build_dir, "complete-app.html"), app_html)

# 7. Table and List Components Example
@component function TableListExample()
    @div begin
        @Section {spacing = :lg} begin
            @Container begin
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
                                                @Avatar {fallback = "<89>MB", size = :sm}
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
    end
end
@deftag macro TableListExample end

table_list_html = @render @HTMLDocument {
    title = "Table & List Components - HypertextTemplates",
    current_page = "table-list-components.html",
} begin
    @TableListExample {}
end

write(joinpath(build_dir, "table-list-components.html"), table_list_html)

# 8. Utility Components Example
@component function UtilityExample()
    @div begin
        @Section {spacing = :lg} begin
            @Container begin
                @Stack {gap = 8} begin
                    @Heading {level = 1, class = "text-center mb-8"} "Utility Components Demo"

                    # Dividers
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Divider Component"
                            @Text "Separate content sections with dividers."

                            @Stack {gap = 4} begin
                                @Text "Default horizontal divider:"
                                @Divider {}

                                @Text "Colored divider:"
                                @Divider {color = "border-blue-500"}

                                @Stack {direction = :horizontal, gap = 4, align = :center} begin
                                    @Text "Vertical"
                                    @Divider {orientation = :vertical, class = "h-16"}
                                    @Text "Divider"
                                    @Divider {orientation = :vertical, class = "h-16"}
                                    @Text "Example"
                                end
                            end
                        end
                    end

                    # Avatars
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Avatar Component"
                            @Text "User profile images with fallbacks."

                            @Stack {gap = 6} begin
                                @Stack {gap = 3} begin
                                    @Text {weight = :semibold} "Sizes"
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 3,
                                        align = :center,
                                    } begin
                                        @Avatar {size = :xs, fallback = "XS"}
                                        @Avatar {size = :sm, fallback = "SM"}
                                        @Avatar {size = :md, fallback = "MD"}
                                        @Avatar {size = :lg, fallback = "LG"}
                                        @Avatar {size = :xl, fallback = "XL"}
                                    end
                                end

                                @Stack {gap = 3} begin
                                    @Text {weight = :semibold} "Shapes"
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 3,
                                        align = :center,
                                    } begin
                                        @Avatar {shape = :circle, fallback = "C"}
                                        @Avatar {shape = :square, fallback = "S"}
                                    end
                                end

                                @Stack {gap = 3} begin
                                    @Text {weight = :semibold} "With Images"
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 3,
                                        align = :center,
                                    } begin
                                        @Avatar {
                                            src = "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop",
                                            alt = "User 1",
                                        }
                                        @Avatar {
                                            src = "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop",
                                            alt = "User 2",
                                        }
                                        @Avatar {
                                            src = "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop",
                                            alt = "User 3",
                                        }
                                    end
                                end

                                @Stack {gap = 3} begin
                                    @Text {weight = :semibold} "User Cards"
                                    @Grid {cols = 1, sm = 2, gap = 4} begin
                                        @Card {padding = :md} begin
                                            @Stack {
                                                direction = :horizontal,
                                                gap = 3,
                                                align = :center,
                                            } begin
                                                @Avatar {size = :lg, fallback = "JD"}
                                                @Stack {gap = 1} begin
                                                    @Text {weight = :semibold} "Jane Doe"
                                                    @Text {
                                                        size = :sm,
                                                        color = "text-slate-600 dark:text-slate-400",
                                                    } "jane@example.com"
                                                    @Badge {variant = :success, size = :sm} "Online"
                                                end
                                            end
                                        end

                                        @Card {padding = :md} begin
                                            @Stack {
                                                direction = :horizontal,
                                                gap = 3,
                                                align = :center,
                                            } begin
                                                @Avatar {size = :lg, fallback = "👤"}
                                                @Stack {gap = 1} begin
                                                    @Text {weight = :semibold} "Guest User"
                                                    @Text {
                                                        size = :sm,
                                                        color = "text-slate-600 dark:text-slate-400",
                                                    } "Not logged in"
                                                    @Badge {size = :sm} "Guest"
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    # Icons
                    @Card {padding = :lg} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 2} "Icon Component"
                            @Text "Consistent icon sizing and styling."

                            @Stack {gap = 6} begin
                                @Stack {gap = 3} begin
                                    @Text {weight = :semibold} "Built-in Icons"
                                    @Grid {cols = 5, sm = 10, gap = 4} begin
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "check", size = :lg}
                                            @Text {size = :xs} "check"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "x", size = :lg}
                                            @Text {size = :xs} "x"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "arrow-right", size = :lg}
                                            @Text {size = :xs} "arrow-right"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "arrow-left", size = :lg}
                                            @Text {size = :xs} "arrow-left"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "chevron-down", size = :lg}
                                            @Text {size = :xs} "chevron-down"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "chevron-up", size = :lg}
                                            @Text {size = :xs} "chevron-up"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "menu", size = :lg}
                                            @Text {size = :xs} "menu"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "search", size = :lg}
                                            @Text {size = :xs} "search"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "plus", size = :lg}
                                            @Text {size = :xs} "plus"
                                        end
                                        @Stack {gap = 2, align = :center} begin
                                            @Icon {name = "minus", size = :lg}
                                            @Text {size = :xs} "minus"
                                        end
                                    end
                                end

                                @Stack {gap = 3} begin
                                    @Text {weight = :semibold} "Icon Sizes"
                                    @Stack {
                                        direction = :horizontal,
                                        gap = 4,
                                        align = :center,
                                    } begin
                                        @Icon {name = "check", size = :xs}
                                        @Icon {name = "check", size = :sm}
                                        @Icon {name = "check", size = :md}
                                        @Icon {name = "check", size = :lg}
                                        @Icon {name = "check", size = :xl}
                                    end
                                end

                                @Stack {gap = 3} begin
                                    @Text {weight = :semibold} "Icon Colors"
                                    @Stack {direction = :horizontal, gap = 4} begin
                                        @Icon {
                                            name = "check",
                                            size = :lg,
                                            color = "text-slate-600",
                                        }
                                        @Icon {
                                            name = "check",
                                            size = :lg,
                                            color = "text-blue-600",
                                        }
                                        @Icon {
                                            name = "check",
                                            size = :lg,
                                            color = "text-green-600",
                                        }
                                        @Icon {
                                            name = "check",
                                            size = :lg,
                                            color = "text-yellow-600",
                                        }
                                        @Icon {
                                            name = "check",
                                            size = :lg,
                                            color = "text-red-600",
                                        }
                                    end
                                end

                                @Stack {gap = 3} begin
                                    @Text {weight = :semibold} "Icon Usage Examples"
                                    @Stack {gap = 3} begin
                                        @Alert {variant = :success} begin
                                            @Stack {
                                                direction = :horizontal,
                                                gap = 2,
                                                align = :center,
                                            } begin
                                                @Icon {name = "check", size = :sm}
                                                @text "Operation completed successfully"
                                            end
                                        end

                                        @button {
                                            class = "inline-flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors",
                                        } begin
                                            @Icon {name = "plus", size = :sm}
                                            @text "Add New Item"
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
@deftag macro UtilityExample end

utility_html = @render @HTMLDocument {
    title = "Utility Components - HypertextTemplates",
    current_page = "utility-components.html",
} begin
    @UtilityExample {}
end

write(joinpath(build_dir, "utility-components.html"), utility_html)

println("\nComponent examples generated successfully!")
println("Files created in: $(build_dir)")
println("\nGenerated files:")
for file in readdir(build_dir)
    if endswith(file, ".html")
        println("  - $(file)")
    end
end
