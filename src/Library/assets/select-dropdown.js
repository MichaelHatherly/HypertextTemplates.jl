/**
 * Alpine.data component for SelectDropdown
 * 
 * This file defines the interactive behavior for the SelectDropdown component.
 * It uses Alpine.js's data component system to provide reusable dropdown select functionality.
 * 
 * Architecture Overview:
 * - Registered as 'selectDropdown' Alpine.data component
 * - Manages dropdown state, search, and selection
 * - Supports single and multiple selection modes
 * - Provides keyboard navigation and search filtering
 * - Handles automatic positioning (drop up/down)
 * 
 * Dependencies:
 * - Alpine.js v3
 * 
 * Usage in templates:
 * x-data="selectDropdown(config)"
 */
document.addEventListener('alpine:init', () => {
    Alpine.data('selectDropdown', (config = {}) => ({
        // State management
        open: false,
        search: '',
        selected: config.value || (config.multiple ? [] : ''),
        highlighted: 0,
        
        // Configuration from component props
        options: config.options || [],
        multiple: config.multiple || false,
        searchable: config.searchable || false,
        clearable: config.clearable || false,
        placeholder: config.placeholder || 'Select...',
        maxHeight: parseInt(config.maxHeight) || 300,
        disabled: config.disabled || false,
        name: config.name || null,
        
        /**
         * Initialize component
         * Sets up initial state and watchers
         */
        init() {
            // Watch for selection changes to update form inputs
            this.$watch('selected', () => {
                this.updateFormInputs();
                // Dispatch custom event for external listeners
                this.$dispatch('select-change', { 
                    value: this.selected,
                    name: this.name 
                });
            });
            
            // Set initial form inputs
            this.updateFormInputs();
        },
        
        /**
         * Get filtered options based on search query
         * @returns {Array} Filtered options array
         */
        get filteredOptions() {
            if (!this.search) return this.options;
            
            const searchLower = this.search.toLowerCase();
            return this.options.filter(([value, label]) => 
                label.toLowerCase().includes(searchLower)
            );
        },
        
        /**
         * Get display label for selected value(s)
         * @returns {string} Label to display in the button
         */
        get selectedLabel() {
            if (this.multiple) {
                const labels = this.selected.map(v => {
                    const opt = this.options.find(([val]) => val === v);
                    return opt ? opt[1] : v;
                });
                return labels.length > 0 ? labels.join(', ') : this.placeholder;
            } else {
                if (!this.selected) return this.placeholder;
                const opt = this.options.find(([val]) => val === this.selected);
                return opt ? opt[1] : this.selected;
            }
        },
        
        /**
         * Check if there's a selection
         * @returns {boolean} True if something is selected
         */
        get hasSelection() {
            return this.multiple ? this.selected.length > 0 : !!this.selected;
        },
        
        
        /**
         * Select or deselect an option
         * @param {string} value - The option value to select
         */
        selectOption(value) {
            if (this.multiple) {
                const idx = this.selected.indexOf(value);
                if (idx > -1) {
                    this.selected.splice(idx, 1);
                } else {
                    this.selected.push(value);
                }
            } else {
                this.selected = value;
                this.open = false;
                this.search = '';
            }
        },
        
        /**
         * Clear all selections
         */
        clearSelection() {
            this.selected = this.multiple ? [] : '';
            this.search = '';
        },
        
        /**
         * Check if a value is selected
         * @param {string} value - The value to check
         * @returns {boolean} True if selected
         */
        isSelected(value) {
            return this.multiple 
                ? this.selected.includes(value) 
                : this.selected === value;
        },
        
        /**
         * Handle keyboard navigation
         * @param {KeyboardEvent} e - The keyboard event
         */
        handleKeydown(e) {
            // Open dropdown on Enter, Space, or ArrowDown when closed
            if (!this.open && ['Enter', ' ', 'ArrowDown'].includes(e.key)) {
                e.preventDefault();
                this.open = true;
                if (this.searchable) {
                    this.$nextTick(() => this.$refs.search?.focus());
                }
                return;
            }
            
            if (!this.open) return;
            
            switch(e.key) {
                case 'Escape':
                    e.preventDefault();
                    this.open = false;
                    this.$refs.button.focus();
                    break;
                    
                case 'ArrowDown':
                    e.preventDefault();
                    this.highlighted = Math.min(
                        this.highlighted + 1, 
                        this.filteredOptions.length - 1
                    );
                    this.scrollToHighlighted();
                    break;
                    
                case 'ArrowUp':
                    e.preventDefault();
                    this.highlighted = Math.max(this.highlighted - 1, 0);
                    this.scrollToHighlighted();
                    break;
                    
                case 'Enter':
                    e.preventDefault();
                    if (this.filteredOptions[this.highlighted]) {
                        this.selectOption(this.filteredOptions[this.highlighted][0]);
                    }
                    break;
                    
                case 'Tab':
                    // Let tab close the dropdown
                    this.open = false;
                    break;
            }
        },
        
        /**
         * Scroll to keep highlighted option in view
         */
        scrollToHighlighted() {
            this.$nextTick(() => {
                const container = this.$refs.optionsList;
                const highlighted = container?.querySelector(`[data-index="${this.highlighted}"]`);
                
                if (highlighted && container) {
                    const containerRect = container.getBoundingClientRect();
                    const highlightedRect = highlighted.getBoundingClientRect();
                    
                    if (highlightedRect.bottom > containerRect.bottom) {
                        container.scrollTop += highlightedRect.bottom - containerRect.bottom;
                    } else if (highlightedRect.top < containerRect.top) {
                        container.scrollTop -= containerRect.top - highlightedRect.top;
                    }
                }
            });
        },
        
        /**
         * Update hidden form inputs for form submission
         */
        updateFormInputs() {
            if (!this.name) return;
            
            // Find or create container for hidden inputs
            let container = this.$el.querySelector('[data-select-inputs]');
            if (!container) {
                container = document.createElement('div');
                container.setAttribute('data-select-inputs', '');
                container.style.display = 'none';
                this.$el.appendChild(container);
            }
            
            // Clear existing inputs
            container.innerHTML = '';
            
            // Create new inputs
            if (this.multiple) {
                this.selected.forEach(value => {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = this.name;
                    input.value = value;
                    container.appendChild(input);
                });
            } else if (this.selected) {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = this.name;
                input.value = this.selected;
                container.appendChild(input);
            }
        },
        
        /**
         * Toggle dropdown open/closed
         */
        toggle() {
            if (this.disabled) return;
            
            this.open = !this.open;
            
            if (this.open && this.searchable) {
                this.$nextTick(() => this.$refs.search?.focus());
            }
        },
        
        /**
         * Handle clicks outside to close dropdown
         */
        handleClickOutside() {
            this.open = false;
            this.search = '';
        }
    }))
});