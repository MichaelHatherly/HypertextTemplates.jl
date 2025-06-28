# Modern Styling Examples
# Showcases the new design system features added to components

@component function ModernStylingExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Modern Styling Features"

            # Glass morphism Cards
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Glassmorphism & Modern Card Variants"

                    @Grid {cols = 1, md = 2, lg = 3, gap = 4} begin
                        # Default card
                        @Card {padding = :base, shadow = :base} begin
                            @Stack {gap = 2} begin
                                @Heading {level = 4} "Default Card"
                                @Text {size = :sm} "Classic card with base shadow and no border by default"
                            end
                        end

                        # Glass card
                        @Card {variant = :glass, padding = :base} begin
                            @Stack {gap = 2} begin
                                @Heading {level = 4} "Glass Card"
                                @Text {size = :sm} "Glassmorphism effect with backdrop blur"
                            end
                        end

                        # Gradient card
                        @Card {variant = :gradient, padding = :base} begin
                            @Stack {gap = 2} begin
                                @Heading {level = 4} "Gradient Card"
                                @Text {size = :sm} "Subtle gradient background"
                            end
                        end

                        # Mesh gradient card
                        @Card {variant = :mesh, padding = :base} begin
                            @Stack {gap = 2} begin
                                @Heading {level = 4} "Mesh Gradient"
                                @Text {size = :sm} "Modern mesh gradient effect"
                            end
                        end

                        # Blur variant
                        @Card {variant = :blur, padding = :base} begin
                            @Stack {gap = 2} begin
                                @Heading {level = 4} "Blur Card"
                                @Text {size = :sm} "Strong blur effect for overlays"
                            end
                        end

                        # Card with glow
                        @Card {padding = :base, glow = :primary, shadow = :lg} begin
                            @Stack {gap = 2} begin
                                @Heading {level = 4} "Glow Effect"
                                @Text {size = :sm} "Card with colored glow shadow"
                            end
                        end
                    end

                    @Divider {}

                    # Card borders and shadows
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Border & Shadow Options"

                        @Grid {cols = 1, md = 3, gap = 4} begin
                            @Card {border = :gradient, padding = :base} begin
                                @Text {weight = :semibold} "Gradient Border"
                                @Text {size = :sm} "Eye-catching gradient border effect"
                            end

                            @Card {border = :glow, padding = :base, shadow = :glow} begin
                                @Text {weight = :semibold} "Glow Border"
                                @Text {size = :sm} "Subtle glow border with shadow"
                            end

                            @Card {padding = :base, shadow = :float, hoverable = true} begin
                                @Text {weight = :semibold} "Float Shadow"
                                @Text {size = :sm} "Hover me for float effect!"
                            end
                        end
                    end
                end
            end

            # Modern Typography
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Enhanced Typography"

                    # Gradient headings
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Gradient Text Effects"
                        @Heading {level = 1, gradient = true} "Gradient Heading"
                        @Heading {level = 2, gradient = true, tracking = :wide} "Wide Tracking Gradient"
                        @Heading {level = 3, gradient = true, weight = :extrabold} "Extra Bold Gradient"
                    end

                    @Divider {}

                    # Letter spacing variations
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Letter Spacing (Tracking)"
                        @Heading {level = 4, tracking = :tight} "Tight Letter Spacing"
                        @Heading {level = 4, tracking = :normal} "Normal Letter Spacing"
                        @Heading {level = 4, tracking = :wide} "Wide Letter Spacing"
                    end

                    @Divider {}

                    # Font weights
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Font Weight Range"
                        @Text {weight = :light, size = :lg} "Light weight text for elegant headers"
                        @Text {weight = :normal, size = :lg} "Normal weight for body text"
                        @Text {weight = :medium, size = :lg} "Medium weight for slight emphasis"
                        @Text {weight = :semibold, size = :lg} "Semibold for moderate emphasis"
                        @Text {weight = :bold, size = :lg} "Bold for strong emphasis"
                        @Heading {level = 5, weight = :extrabold} "Extra bold for maximum impact"
                    end

                    @Divider {}

                    # Modern link styles
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Enhanced Link Styles"
                        @Stack {gap = 2} begin
                            @Text begin
                                @Link {href = "#", variant = :animated} "Animated underline link"
                                @text " - Watch the underline slide in on hover"
                            end
                            @Text begin
                                @Link {href = "#", variant = :underline} "Always underlined"
                                @text " with offset animation on hover"
                            end
                            @Text begin
                                @Link {href = "#", weight = :semibold} "Semibold link"
                                @text " for important navigation"
                            end
                        end
                    end
                end
            end

            # Modern Form Inputs
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Modern Form Styling"

                    # Input variations
                    @Grid {cols = 1, md = 2, gap = 6} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 3} "Enhanced Inputs"

                            @FormGroup {label = "Modern Input"} begin
                                @Input {placeholder = "Rounded corners, smooth transitions"}
                            end

                            @FormGroup {label = "Success State"} begin
                                @Input {
                                    state = :success,
                                    value = "Looking good!",
                                    icon = """<svg class="w-5 h-5 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>""",
                                }
                            end

                            @FormGroup {
                                label = "Error State",
                                error = "Please check your input",
                            } begin
                                @Input {
                                    state = :error,
                                    placeholder = "Something went wrong",
                                }
                            end
                        end

                        @Stack {gap = 4} begin
                            @Heading {level = 3} "Button Variants"

                            @Stack {gap = 3} begin
                                @Button {variant = :primary, rounded = :xl} "Primary Button"
                                @Button {variant = :gradient, rounded = :xl} "Gradient Button"
                                @Button {variant = :ghost, rounded = :lg} "Ghost Button"
                                @Button {variant = :outline, rounded = :full} "Outline Rounded"

                                @Stack {direction = :horizontal, gap = 2} begin
                                    @Button {size = :xs, variant = :secondary} "XS"
                                    @Button {size = :sm, variant = :secondary} "SM"
                                    @Button {size = :base, variant = :secondary} "Base"
                                    @Button {size = :lg, variant = :secondary} "LG"
                                    @Button {size = :xl, variant = :secondary} "XL"
                                end
                            end
                        end
                    end

                    @Divider {}

                    # Select and Textarea with modern styling
                    @Grid {cols = 1, md = 2, gap = 4} begin
                        @FormGroup {label = "Modern Select"} begin
                            @Select {
                                options = [
                                    ("", "Choose an option"),
                                    ("opt1", "Option One"),
                                    ("opt2", "Option Two"),
                                    ("opt3", "Option Three"),
                                ],
                            }
                        end

                        @FormGroup {label = "Modern Textarea"} begin
                            @Textarea {
                                placeholder = "Smooth hover transitions and rounded corners...",
                                rows = 3,
                            }
                        end
                    end
                end
            end

            # Enhanced Badges
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Modern Badge Styles"

                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Gradient & Animated Badges"

                        @Stack {
                            direction = :horizontal,
                            gap = 3,
                            align = :center,
                            wrap = true,
                        } begin
                            @Badge {variant = :gradient} "Gradient"
                            @Badge {variant = :primary, animated = true} "Animated"
                            @Badge {variant = :success, outline = true} "Outline Success"
                            @Badge {variant = :warning, outline = true} "Outline Warning"
                            @Badge {variant = :danger, outline = true, animated = true} "Animated Outline"
                        end

                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Badge Sizes"
                            @Stack {direction = :horizontal, gap = 2, align = :center} begin
                                @Badge {size = :xs, variant = :primary} "Extra Small"
                                @Badge {size = :sm, variant = :secondary} "Small"
                                @Badge {size = :base, variant = :success} "Base"
                                @Badge {size = :lg, variant = :warning} "Large"
                                @Badge {size = :xl, variant = :danger} "Extra Large"
                            end
                        end
                    end
                end
            end

            # Modern Feedback Components
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Enhanced Feedback Components"

                    # Animated alerts
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Animated Alerts"

                        @Alert {variant = :info, animated = true, icon = false} begin
                            @Text {weight = :semibold} "Minimal alert without icon"
                        end

                        @Alert {variant = :success, animated = true, dismissible = true} begin
                            @Text "Alert with fade-in animation and dismiss button"
                        end

                        @Alert {variant = :warning, animated = true} begin
                            @Text "Border accent on the left for visual hierarchy"
                        end
                    end

                    @Divider {}

                    # Progress variations
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Modern Progress Bars"

                        @Progress {
                            value = 45,
                            color = :gradient,
                            label = "Gradient Progress",
                        }
                        @Progress {
                            value = 70,
                            color = :primary,
                            striped = true,
                            animated = true,
                            label = "Animated Stripes",
                        }
                        @Progress {
                            value = 85,
                            color = :success,
                            size = :lg,
                            label = "Large Success Bar",
                        }

                        @Stack {gap = 2} begin
                            @Text {size = :sm, weight = :semibold} "Compact Progress Set"
                            @Progress {value = 30, size = :sm, color = :warning}
                            @Progress {value = 60, size = :sm, color = :primary}
                            @Progress {value = 90, size = :sm, color = :success}
                        end
                    end
                end
            end

            # Modern Navigation
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Modernized Navigation"

                    # Updated breadcrumb
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Enhanced Breadcrumbs"
                        @Breadcrumb {
                            items = [
                                ("/", "Home"),
                                ("/docs", "Documentation"),
                                ("/docs/components", "Components"),
                                ("/docs/components/modern", "Modern Styling"),
                            ],
                        }
                    end

                    @Divider {}

                    # Modern tabs
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Redesigned Tabs"
                        @Tabs {
                            items = [
                                ("design", "Design System"),
                                ("components", "Components"),
                                ("examples", "Examples"),
                                ("api", "API Reference"),
                            ],
                            active = "components",
                        }
                    end

                    @Divider {}

                    # Updated pagination
                    @Stack {gap = 4} begin
                        @Heading {level = 3} "Modern Pagination"
                        @Pagination {current = 5, total = 10}
                    end
                end
            end

            # Glass Container Demo
            @Card {padding = :lg} begin
                @Stack {gap = 6} begin
                    @Heading {level = 2} "Glass Container Effect"

                    @Container {glass = true, size = :md} begin
                        @Stack {gap = 4} begin
                            @Heading {level = 3} "Glassmorphism Container"
                            @Text "This container has a glassmorphism effect with backdrop blur and subtle transparency."
                            @Stack {direction = :horizontal, gap = 3} begin
                                @Button {variant = :primary} "Action"
                                @Button {variant = :ghost} "Cancel"
                            end
                        end
                    end
                end
            end
        end
    end
end
@deftag macro ModernStylingExample end
