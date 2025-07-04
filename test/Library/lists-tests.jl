using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "List Components" begin
    @testset "Timeline" begin
        render_test("references/library/timeline-default.txt") do io
            @render io @Timeline begin
                @TimelineItem begin
                    @TimelineContent begin
                        @h3 "Started project"
                        @p "Initial commit and project setup"
                        @span "2 hours ago"
                    end
                end
                @TimelineItem begin
                    @TimelineContent begin
                        @h3 "Added features"
                        @p "Implemented core functionality"
                        @span "1 hour ago"
                    end
                end
            end
        end

        render_test("references/library/timeline-with-markers.txt") do io
            @render io @Timeline {variant = :numbered} begin
                @TimelineItem {marker = "1", status = :completed} begin
                    @TimelineContent begin
                        @h3 "Step 1: Planning"
                        @p "Define project requirements"
                    end
                end
                @TimelineItem {marker = "2", status = :current} begin
                    @TimelineContent begin
                        @h3 "Step 2: Development"
                        @p "Build the application"
                    end
                end
                @TimelineItem {marker = "3", status = :pending} begin
                    @TimelineContent begin
                        @h3 "Step 3: Testing"
                        @p "Test and deploy"
                    end
                end
            end
        end

        render_test("references/library/timeline-custom.txt") do io
            @render io @Timeline {color = "border-blue-500", spacing = "space-y-12"} begin
                @TimelineItem {marker_color = "bg-green-500"} begin
                    @TimelineContent {padding = "p-6", background = "bg-green-50"} begin
                        @h3 "Success Event"
                        @p "Everything went well"
                    end
                end
                @TimelineItem {marker_color = "bg-red-500"} begin
                    @TimelineContent {padding = "p-6", background = "bg-red-50"} begin
                        @h3 "Error Event"
                        @p "Something went wrong"
                    end
                end
            end
        end
    end
end
