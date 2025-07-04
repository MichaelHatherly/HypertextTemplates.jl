using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@component function TypographyExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Typography Components Demo"

            # Headings
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Heading Component"
                    @Text "Multiple heading levels with customizable styles."

                    @Stack {gap = 3} begin
                        @Heading {level = 1} "H1: Main Page Title"
                        @Heading {level = 2, gradient = true} "H2: Gradient Heading"
                        @Heading {level = 3, tracking = :wide} "H3: Wide Letter Spacing"
                        @Heading {level = 4, color = "text-blue-600 dark:text-blue-400"} "H4: Colored Heading"
                        @Heading {level = 5, weight = :light} "H5: Light Weight Heading"
                        @Heading {level = 6, size = "2xl", weight = :extrabold} "H6: Extra Bold Custom Size"
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
                        @Text {weight = :bold, color = "text-red-600 dark:text-red-400"} "Bold colored text for warnings"
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
                            @Link {href = "#", weight = :medium} "documentation"
                            @text " for more information."
                        end
                        @Text begin
                            @Link {href = "#", variant = :underline} "Always underlined link"
                            @text " | "
                            @Link {href = "#", variant = :hover_underline} "Underline on hover"
                            @text " | "
                            @Link {href = "#", variant = :animated} "Animated underline"
                        end
                        @Text begin
                            @Link {
                                href = "https://github.com",
                                external = true,
                                weight = :semibold,
                            } "External link to GitHub"
                            @text " (opens in new tab)"
                        end
                    end
                end
            end
        end
    end
end
@deftag macro TypographyExample end

component_title(::typeof(TypographyExample)) = "Typography Components"
