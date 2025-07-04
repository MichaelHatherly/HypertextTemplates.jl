using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

# 8. Utility Components Example
@component function UtilityExample()
    @Container {class = "py-8"} begin
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
                            @Stack {direction = :horizontal, gap = 3, align = :center} begin
                                @Avatar {size = :xs, fallback = "XS"}
                                @Avatar {size = :sm, fallback = "SM"}
                                @Avatar {size = :md, fallback = "MD"}
                                @Avatar {size = :lg, fallback = "LG"}
                                @Avatar {size = :xl, fallback = "XL"}
                            end
                        end

                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Shapes"
                            @Stack {direction = :horizontal, gap = 3, align = :center} begin
                                @Avatar {shape = :circle, fallback = "C"}
                                @Avatar {shape = :square, fallback = "S"}
                            end
                        end

                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "With Images"
                            @Stack {direction = :horizontal, gap = 3, align = :center} begin
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
                            @Stack {direction = :horizontal, gap = 4, align = :center} begin
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
                                @Icon {name = "check", size = :lg, color = "text-slate-600"}
                                @Icon {name = "check", size = :lg, color = "text-blue-600"}
                                @Icon {name = "check", size = :lg, color = "text-green-600"}
                                @Icon {
                                    name = "check",
                                    size = :lg,
                                    color = "text-yellow-600",
                                }
                                @Icon {name = "check", size = :lg, color = "text-red-600"}
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
@deftag macro UtilityExample end

component_title(::typeof(UtilityExample)) = "Utility Components"
