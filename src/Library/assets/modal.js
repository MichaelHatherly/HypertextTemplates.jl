/**
 * Alpine.data component for Modal
 *
 * This file defines the interactive behavior for Modal components.
 * It uses Alpine.js's data component system to provide reusable modal functionality
 * built on top of the native HTML <dialog> element for accessibility.
 *
 * Architecture Overview:
 * - Registered as 'modal' Alpine.data component
 * - Enhances native <dialog> element with configuration and custom behavior
 * - Provides focus management and keyboard navigation
 * - Supports persistent modals and backdrop click handling
 *
 * Dependencies:
 * - Alpine.js v3
 * - Native <dialog> element support (modern browsers)
 *
 * Usage in templates:
 * x-data="modal(config)"
 */
document.addEventListener('alpine:init', () => {
    Alpine.data('modal', (config = {}) => ({
        // Configuration with defaults
        persistent: config.persistent || false,
        returnFocus: config.returnFocus !== false,

        // State management
        isOpen: false,
        modalId: 'modal-' + Math.random().toString(36).substr(2, 9),

        // Store reference to trigger element for focus return
        triggerElement: null,

        /**
         * Initialize modal component
         * Sets up event listeners and handles initial state
         */
        init() {
            console.log('Modal Alpine component initialized for:', this.$el.id);
            // Store reference to the native dialog element
            this.dialog = this.$refs.dialog;

            // Listen for dialog close events (e.g., Escape key)
            this.dialog.addEventListener('close', () => {
                this.handleClose();
            });

            // Listen for backdrop clicks on the dialog itself
            this.dialog.addEventListener('click', (event) => {
                this.handleBackdropClick(event);
            });

            // Listen for global modal-open events to close other modals
            window.addEventListener('modal-open', (event) => {
                this.handleModalOpen(event);
            });

            // Listen for modal-open events targeting this modal specifically
            window.addEventListener('modal-open', (event) => {
                console.log('Received modal-open event for:', event.detail?.id, 'this modal is:', this.$el.id);
                if (event.detail && event.detail.id === this.$el.id) {
                    console.log('Opening modal:', this.$el.id);
                    this.open();
                }
            });
        },

        /**
         * Open the modal
         * Uses native showModal() for proper modal behavior
         */
        open() {
            if (this.isOpen) return;

            // Store current focused element for return focus
            if (this.returnFocus) {
                this.triggerElement = document.activeElement;
            }

            // Notify other modals to close
            window.dispatchEvent(new CustomEvent('modal-open', {
                detail: { id: this.modalId }
            }));

            // Open the native dialog as modal
            this.dialog.showModal();
            this.isOpen = true;

            // Focus the first focusable element in modal content
            this.$nextTick(() => {
                this.focusFirstElement();
            });
        },

        /**
         * Close the modal
         * Uses native close() method and handles focus return
         */
        close() {
            if (!this.isOpen) return;

            // Add closing class for animation
            this.dialog.classList.add('closing');

            // Wait for animation to complete before closing
            setTimeout(() => {
                this.dialog.close();
                this.dialog.classList.remove('closing');
                this.isOpen = false;

                // Return focus to trigger element
                if (this.returnFocus && this.triggerElement) {
                    this.triggerElement.focus();
                    this.triggerElement = null;
                }
            }, 200); // Match animation duration
        },

        /**
         * Handle dialog close event (triggered by Escape key or programmatic close)
         */
        handleClose() {
            this.isOpen = false;

            // Return focus to trigger element
            if (this.returnFocus && this.triggerElement) {
                this.triggerElement.focus();
                this.triggerElement = null;
            }
        },

        /**
         * Handle backdrop clicks
         * Closes modal unless persistent mode is enabled
         */
        handleBackdropClick(event) {
            // Only close if clicking on the dialog itself (backdrop)
            // not on any content inside it
            if (event.target === this.dialog && !this.persistent) {
                this.close();
            }
        },

        /**
         * Handle global modal-open events
         * Closes this modal if another modal is opened
         */
        handleModalOpen(event) {
            if (event.detail.id !== this.modalId && this.isOpen) {
                this.close();
            }
        },

        /**
         * Focus the first focusable element in the modal
         * Provides good accessibility behavior on modal open
         */
        focusFirstElement() {
            const focusableElements = this.dialog.querySelectorAll(`
                button:not([disabled]),
                [href]:not([disabled]),
                input:not([disabled]),
                select:not([disabled]),
                textarea:not([disabled]),
                [tabindex]:not([tabindex="-1"]):not([disabled])
            `);

            if (focusableElements.length > 0) {
                focusableElements[0].focus();
            } else {
                // If no focusable elements, focus the dialog itself
                this.dialog.focus();
            }
        },

        /**
         * Handle keyboard events in modal
         * Provides additional keyboard support beyond native dialog
         */
        handleKeydown(event) {
            // Additional keyboard handling can be added here if needed
            // Native dialog already handles Escape key
            switch (event.key) {
                case 'Tab':
                    // Tab key handling for focus trapping could be added here
                    // but native dialog already provides focus trapping
                    break;
            }
        }
    }))
});
