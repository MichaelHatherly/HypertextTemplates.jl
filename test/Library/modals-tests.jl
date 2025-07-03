using Test
using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@testset "Modal Components" begin
    @testset "Basic Modal" begin
        render_test("references/library/modal-default.txt") do io
            @render io @Modal {id = "test-modal"} begin
                @ModalContent "Test content"
            end
        end

        render_test("references/library/modal-sizes.txt") do io
            @render io begin
                @Modal {id = "sm", size = :sm} begin
                    @ModalContent "Small modal"
                end
                @Modal {id = "lg", size = :lg} begin
                    @ModalContent "Large modal"
                end
                @Modal {id = "fullscreen", size = :fullscreen} begin
                    @ModalContent "Fullscreen modal"
                end
            end
        end

        render_test("references/library/modal-persistent.txt") do io
            @render io @Modal {
                id = "persistent",
                persistent = true,
            } begin
                @ModalContent "Cannot close by clicking backdrop"
            end
        end

        render_test("references/library/modal-no-close.txt") do io
            @render io @Modal {
                id = "no-close",
                show_close = false,
            } begin
                @ModalContent "No close button"
            end
        end
    end

    @testset "Modal Sub-components" begin
        render_test("references/library/modal-trigger.txt") do io
            @render io @ModalTrigger {
                target = "my-modal",
            } "Open Modal"
        end

        render_test("references/library/modal-content.txt") do io
            @render io @ModalContent begin
                @Text "Modal body content"
            end
        end

        render_test("references/library/modal-content-no-scroll.txt") do io
            @render io @ModalContent {
                scrollable = false,
            } begin
                @Text "Non-scrollable content"
            end
        end

        render_test("references/library/modal-header.txt") do io
            @render io @ModalHeader "Modal Title"
        end

        render_test("references/library/modal-header-custom.txt") do io
            @render io @ModalHeader begin
                @Heading {level = 2} "Custom Header"
                @Badge "New"
            end
        end

        render_test("references/library/modal-footer.txt") do io
            @render io @ModalFooter begin
                @Button "Cancel"
                @Button {variant = :primary} "Save"
            end
        end

        render_test("references/library/modal-footer-justify.txt") do io
            @render io begin
                @ModalFooter {justify = :start} begin
                    @Button "Left"
                end
                @ModalFooter {justify = :center} begin
                    @Button "Center"
                end
                @ModalFooter {justify = :between} begin
                    @Button "Left"
                    @Button "Right"
                end
            end
        end
    end

    @testset "Modal with Structure" begin
        render_test("references/library/modal-complete.txt") do io
            @render io @Modal {id = "complete"} begin
                @ModalHeader "Complete Modal"
                @ModalContent begin
                    @Text "This modal has all components."
                end
                @ModalFooter begin
                    @Button {var"@click" = "close()"} "Close"
                end
            end
        end
    end

    @testset "Drawer Modals" begin
        render_test("references/library/drawer-modal-right.txt") do io
            @render io @DrawerModal {
                id = "drawer-right",
            } begin
                @ModalContent "Right drawer content"
            end
        end

        render_test("references/library/drawer-modal-left.txt") do io
            @render io @DrawerModal {
                id = "drawer-left",
                position = :left,
            } begin
                @ModalContent "Left drawer content"
            end
        end

        render_test("references/library/drawer-modal-top.txt") do io
            @render io @DrawerModal {
                id = "drawer-top",
                position = :top,
                size = :sm,
            } begin
                @ModalContent "Top drawer content"
            end
        end

        render_test("references/library/drawer-modal-bottom.txt") do io
            @render io @DrawerModal {
                id = "drawer-bottom",
                position = :bottom,
                size = :lg,
                persistent = true,
            } begin
                @ModalContent "Bottom drawer content"
            end
        end
    end
end
