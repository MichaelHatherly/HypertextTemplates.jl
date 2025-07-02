/**
 * Alpine.data component for ThemeToggle
 *
 * This file defines the interactive behavior for the ThemeToggle component.
 * It uses Alpine.js's data component system to provide reusable theme switching functionality.
 *
 * Architecture Overview:
 * - Registered as 'themeToggle' Alpine.data component
 * - Manages theme state (light/dark/system) with localStorage persistence
 * - Automatically detects and responds to system theme changes
 * - Provides reactive properties for UI updates
 *
 * Dependencies:
 * - Alpine.js v3
 *
 * Usage in templates:
 * x-data="themeToggle()"
 */
document.addEventListener('alpine:init', () => {
    Alpine.data('themeToggle', () => ({
        // Current theme state
        theme: 'system',

        // Theme configuration
        themes: ['light', 'dark', 'system'],
        icons: {
            light: '☀️',
            dark: '🌙',
            system: '💻'
        },
        labels: {
            light: 'Light',
            dark: 'Dark',
            system: 'System'
        },

        /**
         * Initialize theme on component mount
         * Loads saved theme from localStorage and sets up system theme listener
         */
        init() {
            // Load saved theme from localStorage
            this.theme = localStorage.getItem('theme') || 'system';

            // Apply initial theme
            this.applyTheme();

            // Listen for system theme changes
            window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
                if (this.theme === 'system') {
                    this.applyTheme();
                }
            });

            // Listen for storage events to sync between tabs/windows
            window.addEventListener('storage', (e) => {
                if (e.key === 'theme' && e.newValue) {
                    this.theme = e.newValue;
                    this.applyTheme();
                }
            });
        },

        /**
         * Cycle through themes: light -> dark -> system
         * Persists selection to localStorage and applies theme
         */
        toggle() {
            const currentIndex = this.themes.indexOf(this.theme);
            const nextIndex = (currentIndex + 1) % this.themes.length;
            this.theme = this.themes[nextIndex];

            // Persist to localStorage
            localStorage.setItem('theme', this.theme);

            // Apply theme changes
            this.applyTheme();

            // Dispatch custom event for other components to listen to
            window.dispatchEvent(new CustomEvent('theme-changed', {
                detail: { theme: this.theme }
            }));
        },

        /**
         * Apply the current theme to the document
         * Handles system theme detection when in system mode
         */
        applyTheme() {
            const effectiveTheme = this.theme === 'system'
                ? this.getSystemTheme()
                : this.theme;

            if (effectiveTheme === 'dark') {
                document.documentElement.classList.add('dark');
            } else {
                document.documentElement.classList.remove('dark');
            }
        },

        /**
         * Get the current system theme preference
         * @returns {string} 'dark' or 'light'
         */
        getSystemTheme() {
            return window.matchMedia('(prefers-color-scheme: dark)').matches
                ? 'dark'
                : 'light';
        },

        /**
         * Computed property for current theme icon
         * Used by x-text binding in the template
         */
        get currentIcon() {
            return this.icons[this.theme];
        },

        /**
         * Computed property for current theme label
         * Used by x-text binding in the template
         */
        get currentLabel() {
            return this.labels[this.theme];
        }
    }))
});

/**
 * Apply initial theme before Alpine initializes to prevent flash
 * This runs immediately when the script loads
 */
(function() {
    const theme = localStorage.getItem('theme') || 'system';
    const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    const effectiveTheme = theme === 'system' ? systemTheme : theme;

    if (effectiveTheme === 'dark') {
        document.documentElement.classList.add('dark');
    }
})();
