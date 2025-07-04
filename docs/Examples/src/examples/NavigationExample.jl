using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Navigation Components Example
@component function NavigationExample()
    @Container {class = "py-8"} begin
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
                    @Text "Interactive tab navigation powered by Alpine.js."

                    @Tabs {
                        items = [
                            ("overview", "Overview"),
                            ("features", "Features"),
                            ("pricing", "Pricing"),
                            ("reviews", "Reviews"),
                            ("support", "Support"),
                        ],
                        active = "overview",
                    } begin
                        @TabPanel {id = "overview"} begin
                            @Card {padding = :md} begin
                                @Stack {gap = 2} begin
                                    @Heading {level = 3} "Product Overview"
                                    @Text "Welcome to our comprehensive product overview. This tab provides a high-level view of all features and capabilities."
                                    @Text {
                                        size = :sm,
                                        color = "text-slate-600 dark:text-slate-400",
                                    } "Click on different tabs above to explore more sections."
                                end
                            end
                        end

                        @TabPanel {id = "features"} begin
                            @Card {padding = :md} begin
                                @Stack {gap = 3} begin
                                    @Heading {level = 3} "Key Features"
                                    @List {variant = :bullet} begin
                                        @li "Real-time collaboration"
                                        @li "Advanced analytics dashboard"
                                        @li "Seamless integrations"
                                        @li "Enterprise-grade security"
                                    end
                                end
                            end
                        end

                        @TabPanel {id = "pricing"} begin
                            @Card {padding = :md} begin
                                @Stack {gap = 3} begin
                                    @Heading {level = 3} "Pricing Plans"
                                    @Grid {cols = 1, sm = 3, gap = 4} begin
                                        @Card {padding = :sm, shadow = :sm} begin
                                            @Stack {gap = 2} begin
                                                @Text {weight = :semibold} "Starter"
                                                @Text {size = "2xl", weight = :bold} "\$9/mo"
                                            end
                                        end
                                        @Card {
                                            padding = :sm,
                                            shadow = :sm,
                                            variant = :gradient,
                                        } begin
                                            @Stack {gap = 2} begin
                                                @Text {weight = :semibold} "Pro"
                                                @Text {size = "2xl", weight = :bold} "\$29/mo"
                                            end
                                        end
                                        @Card {padding = :sm, shadow = :sm} begin
                                            @Stack {gap = 2} begin
                                                @Text {weight = :semibold} "Enterprise"
                                                @Text {size = "2xl", weight = :bold} "Custom"
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        @TabPanel {id = "reviews"} begin
                            @Card {padding = :md} begin
                                @Stack {gap = 3} begin
                                    @Heading {level = 3} "Customer Reviews"
                                    @Stack {gap = 2} begin
                                        @Badge {variant = :success} "5.0 ★★★★★"
                                        @Text {italic = true} "\"Amazing product! Completely transformed our workflow.\""
                                        @Text {
                                            size = :sm,
                                            color = "text-slate-600 dark:text-slate-400",
                                        } "- Sarah J., CEO"
                                    end
                                end
                            end
                        end

                        @TabPanel {id = "support"} begin
                            @Card {padding = :md} begin
                                @Stack {gap = 3} begin
                                    @Heading {level = 3} "Support Options"
                                    @Text "Get help when you need it:"
                                    @Stack {gap = 2} begin
                                        @Button {variant = :primary} "Contact Support"
                                        @Button {variant = :outline} "Browse Documentation"
                                    end
                                end
                            end
                        end
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
@deftag macro NavigationExample end

component_title(::typeof(NavigationExample)) = "Navigation Components"
