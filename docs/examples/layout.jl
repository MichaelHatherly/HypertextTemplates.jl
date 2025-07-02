using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@component function LayoutExample()
    @Container {class = "py-8"} begin
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
@deftag macro LayoutExample end
