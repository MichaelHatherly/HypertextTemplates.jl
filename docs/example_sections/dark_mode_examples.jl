# Dark Mode Examples
# Showcases components optimized for dark mode

@component function DarkModeExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Dark Mode Optimized Components"

            @Alert {variant = :info, dismissible = true} begin
                @Text "Toggle dark mode using the button in the sidebar to see how components adapt! (You can dismiss this message)"
            end

            # Color Contrast Demo
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Optimized Color Contrast"

                    @Grid {cols = 1, md = 2, gap = 4} begin
                        # Light mode optimized card
                        @div {class = "light"} begin
                            @Card {padding = :base} begin
                                @Stack {gap = 3} begin
                                    @Heading {level = 4} "Light Mode"
                                    @Text "High contrast text on light backgrounds"
                                    @Stack {gap = 2} begin
                                        @Badge {variant = :primary} "Primary"
                                        @Badge {variant = :secondary} "Secondary"
                                        @Badge {variant = :success} "Success"
                                    end
                                end
                            end
                        end

                        # Dark mode optimized card
                        @div {class = "dark"} begin
                            @Card {padding = :base} begin
                                @Stack {gap = 3} begin
                                    @Heading {level = 4} "Dark Mode"
                                    @Text "Adjusted colors for dark backgrounds"
                                    @Stack {gap = 2} begin
                                        @Badge {variant = :primary} "Primary"
                                        @Badge {variant = :secondary} "Secondary"
                                        @Badge {variant = :success} "Success"
                                    end
                                end
                            end
                        end
                    end
                end
            end

            # Glass Effects in Dark Mode
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Glassmorphism in Dark Mode"

                    @div {
                        class = "relative p-8 rounded-xl bg-gradient-to-br from-blue-600 to-purple-700",
                    } begin
                        @Grid {cols = 1, md = 2, gap = 4} begin
                            @Card {variant = :glass, padding = :base} begin
                                @Stack {gap = 3} begin
                                    @Heading {level = 4} "Glass Effect"
                                    @Text "Beautiful transparency with backdrop blur"
                                    @Button {variant = :primary} "Learn More"
                                end
                            end

                            @Card {variant = :blur, padding = :base} begin
                                @Stack {gap = 3} begin
                                    @Heading {level = 4} "Blur Variant"
                                    @Text "Stronger blur for overlay effects"
                                    @Button {variant = :outline} "Explore"
                                end
                            end
                        end
                    end
                end
            end

            # Form Elements in Dark Mode
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Dark Mode Form Styling"

                    @Grid {cols = 1, md = 2, gap = 6} begin
                        @Stack {gap = 4} begin
                            @FormGroup {label = "Dark-Optimized Input"} begin
                                @Input {placeholder = "Subtle borders and backgrounds"}
                            end

                            @FormGroup {label = "Select Menu"} begin
                                @Select {
                                    options = [
                                        ("", "Dark mode friendly"),
                                        ("opt1", "Option 1"),
                                        ("opt2", "Option 2"),
                                    ],
                                }
                            end

                            @FormGroup {label = "Textarea"} begin
                                @Textarea {
                                    rows = 3,
                                    placeholder = "Comfortable contrast ratios...",
                                }
                            end
                        end

                        @Stack {gap = 4} begin
                            @Heading {level = 4} "Button Contrast"

                            @Stack {gap = 3} begin
                                @Button {variant = :primary} "Primary Button"
                                @Button {variant = :secondary} "Secondary Button"
                                @Button {variant = :ghost} "Ghost Button"
                                @Button {variant = :outline} "Outline Button"

                                @Card {padding = :sm, variant = :gradient} begin
                                    @Stack {direction = :horizontal, gap = 2} begin
                                        @Button {size = :sm, variant = :success} "Success"
                                        @Button {size = :sm, variant = :warning} "Warning"
                                        @Button {size = :sm, variant = :danger} "Danger"
                                    end
                                end
                            end
                        end
                    end
                end
            end

            # Data Visualization in Dark Mode
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Data Display in Dark Mode"

                    # Progress bars with proper contrast
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Progress Indicators"

                        @Stack {gap = 3} begin
                            @Progress {
                                value = 25,
                                color = :primary,
                                label = "Primary Progress",
                                animated_fill = true,
                            }
                            @Progress {
                                value = 50,
                                color = :gradient,
                                label = "Gradient Progress",
                                animated_fill = true,
                            }
                            @Progress {
                                value = 75,
                                color = :success,
                                striped = true,
                                label = "Striped Progress",
                            }
                            @Progress {
                                value = 90,
                                color = :warning,
                                striped = true,
                                animated = true,
                                label = "Animated Progress",
                            }
                        end
                    end

                    @Divider {}

                    # Table with dark mode
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Dark Mode Table"

                        @Table {striped = true, hover = true} begin
                            @thead begin
                                @tr begin
                                    @th "Feature"
                                    @th "Light Mode"
                                    @th "Dark Mode"
                                end
                            end
                            @tbody begin
                                @tr begin
                                    @td "Background"
                                    @td begin
                                        @Badge {} "White"
                                    end
                                    @td begin
                                        @Badge {variant = :neutral} "Gray-900"
                                    end
                                end
                                @tr begin
                                    @td "Text Color"
                                    @td begin
                                        @Badge {} "Gray-900"
                                    end
                                    @td begin
                                        @Badge {variant = :neutral} "Gray-100"
                                    end
                                end
                                @tr begin
                                    @td "Borders"
                                    @td begin
                                        @Badge {} "Gray-200"
                                    end
                                    @td begin
                                        @Badge {variant = :neutral} "Gray-700"
                                    end
                                end
                            end
                        end
                    end
                end
            end

            # Alert Variations
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Dark Mode Alert Styles"
                    @Text "All alerts feature Alpine.js-powered dismiss functionality when the dismissible prop is set."

                    @Stack {gap = 3} begin
                        @Alert {variant = :info, dismissible = true} begin
                            @Text "Info alert with adjusted colors for dark backgrounds - click X to dismiss"
                        end

                        @Alert {variant = :success, dismissible = true} begin
                            @Text "Success alert maintains readability in both modes - dismissible with smooth transitions"
                        end

                        @Alert {variant = :warning, dismissible = true} begin
                            @Text "Warning alert with optimized contrast - try dismissing me!"
                        end

                        @Alert {variant = :error, dismissible = true} begin
                            @Text "Error alert stands out appropriately - interactive dismiss button included"
                        end
                    end
                end
            end

            # Navigation in Dark Mode
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Dark Mode Navigation"

                    @Stack {gap = 4} begin
                        @Breadcrumb {
                            items = [
                                ("/", "Home"),
                                ("/dark", "Dark Mode"),
                                ("/dark/examples", "Examples"),
                            ],
                        }

                        @Tabs {
                            items = [
                                ("overview", "Overview"),
                                ("implementation", "Implementation"),
                                ("best-practices", "Best Practices"),
                            ],
                            active = "overview",
                        } begin
                            @TabPanel {id = "overview"} begin
                                @Card {padding = :sm} begin
                                    @Text {size = :sm} "Dark mode provides a comfortable viewing experience in low-light environments while reducing eye strain."
                                end
                            end

                            @TabPanel {id = "implementation"} begin
                                @Card {padding = :sm} begin
                                    @Text {size = :sm} "Implementation uses Tailwind's dark mode classes with proper color contrast ratios."
                                end
                            end

                            @TabPanel {id = "best-practices"} begin
                                @Card {padding = :sm} begin
                                    @Text {size = :sm} "Always test color contrast, avoid pure black backgrounds, and ensure consistent theming."
                                end
                            end
                        end

                        @Pagination {current = 3, total = 5}
                    end
                end
            end
        end
    end
end
@deftag macro DarkModeExample end
