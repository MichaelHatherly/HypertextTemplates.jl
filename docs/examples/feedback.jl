using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# Feedback Components Example
@component function FeedbackExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Feedback Components Demo"

            # Alerts
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Alert Component"
                    @Text "Display important messages to users with interactive dismiss functionality."

                    @Stack {gap = 3} begin
                        @Alert {variant = :info, animated = true} begin
                            @strong "Information:"
                            @text " This is an informational alert with fade-in animation."
                        end

                        @Alert {variant = :success, dismissible = true, animated = true} begin
                            @strong "Success!"
                            @text " Your changes have been saved successfully. Click the X to dismiss this alert."
                        end

                        @Alert {variant = :warning, dismissible = true} begin
                            @strong "Warning:"
                            @text " This alert can be dismissed by clicking the close button."
                        end

                        @Alert {variant = :error, dismissible = true, animated = true} begin
                            @strong "Error:"
                            @text " Something went wrong! This alert features both animation and dismiss functionality."
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
                            color = :gradient,
                            label = "Gradient Progress",
                        }
                        @Progress {
                            value = 75,
                            color = :success,
                            striped = true,
                            animated = true,
                            label = "Animated Striped Progress",
                        }
                        @Progress {
                            value = 90,
                            size = :lg,
                            color = :primary,
                            label = "Large Progress Bar",
                        }

                        @Stack {gap = 2} begin
                            @Text {size = :sm, weight = :semibold} "File Upload Progress"
                            @Progress {value = 63, max = 100, striped = true}
                            @Text {size = :sm, color = "text-slate-600 dark:text-slate-400"} "63% complete (63MB of 100MB)"
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

                        @Stack {gap = 2, align = :center, class = "bg-blue-600 p-4 rounded"} begin
                            @Spinner {size = :md, color = :white}
                            @Text {size = :sm, color = "text-white"} "White"
                        end
                    end

                    @Stack {gap = 3} begin
                        @Text {weight = :semibold} "Loading States"
                        @Stack {gap = 2} begin
                            @Stack {
                                direction = :horizontal,
                                gap = 3,
                                align = :center,
                                class = "p-4 border border-slate-200 dark:border-slate-700 rounded-lg",
                            } begin
                                @Spinner {size = :sm}
                                @Text "Loading user data..."
                            end

                            @Stack {
                                direction = :horizontal,
                                gap = 3,
                                align = :center,
                                class = "p-4 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-lg border border-blue-200 dark:border-blue-800",
                            } begin
                                @Spinner {size = :sm, color = :primary}
                                @Text {color = "text-blue-900 dark:text-blue-100"} "Processing your request..."
                            end

                            @Stack {
                                direction = :horizontal,
                                gap = 3,
                                align = :center,
                                class = "inline-flex p-3 bg-white dark:bg-slate-900 shadow-md rounded-full",
                            } begin
                                @Spinner {size = :sm}
                                @Text {size = :sm, weight = :medium} "Saving..."
                            end
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
                        @Stack {
                            direction = :horizontal,
                            gap = 2,
                            align = :center,
                            wrap = true,
                        } begin
                            @Badge {} "Default"
                            @Badge {variant = :primary} "Primary"
                            @Badge {variant = :success} "Success"
                            @Badge {variant = :warning} "Warning"
                            @Badge {variant = :danger} "Danger"
                            @Badge {variant = :gradient} "Gradient"
                        end

                        @Stack {direction = :horizontal, gap = 3, align = :center} begin
                            @Text "Sizes:"
                            @Badge {size = :xs} "XS"
                            @Badge {size = :sm} "Small"
                            @Badge {size = :base} "Base"
                            @Badge {size = :lg} "Large"
                            @Badge {size = :xl} "XL"
                        end

                        @Stack {gap = 3} begin
                            @Text "Special Effects:"
                            @Stack {direction = :horizontal, gap = 2, wrap = true} begin
                                @Badge {variant = :primary, animated = true} "Animated"
                                @Badge {variant = :success, outline = true} "Outline"
                                @Badge {variant = :gradient, animated = true} "Animated Gradient"
                                @Badge {variant = :danger, outline = true, animated = true} "Outline Animated"
                            end
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
@deftag macro FeedbackExample end
