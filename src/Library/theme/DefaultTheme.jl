"""
    default_theme()

Returns the default theme for HypertextTemplates Library components.
This function returns a fresh theme object each time it's called,
which is important for Revise.jl compatibility during development.

The theme structure contains styling information for all Library components,
organized by component name with nested properties for variants, sizes,
states, and other styling attributes.
"""
function default_theme()
    (
        # Button component theme
        button = (
            base = "inline-flex items-center justify-center font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-opacity-50 dark:focus:ring-offset-gray-900 transition-all duration-300 ease-out transform active:scale-[0.98] disabled:active:scale-100",
            variants = (
                primary = "bg-blue-500 text-white hover:bg-blue-600 focus:ring-blue-400 shadow-sm hover:shadow-md",
                secondary = "bg-purple-500 text-white hover:bg-purple-600 focus:ring-purple-400 shadow-sm hover:shadow-md",
                neutral = "bg-gray-100 text-gray-900 hover:bg-gray-200 focus:ring-gray-300 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700 shadow-sm hover:shadow-md",
                success = "bg-emerald-500 text-white hover:bg-emerald-600 focus:ring-emerald-400 shadow-sm hover:shadow-md",
                warning = "bg-amber-500 text-white hover:bg-amber-600 focus:ring-amber-400 shadow-sm hover:shadow-md",
                danger = "bg-rose-500 text-white hover:bg-rose-600 focus:ring-rose-400 shadow-sm hover:shadow-md",
                gradient = "bg-gradient-to-r from-blue-500 to-purple-600 text-white hover:from-blue-600 hover:to-purple-700 focus:ring-blue-400 shadow-md hover:shadow-lg",
                ghost = "bg-transparent text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800 focus:ring-gray-300",
                outline = "bg-transparent border-2 border-gray-300 text-gray-700 hover:bg-gray-50 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-800 focus:ring-gray-300",
            ),
            sizes = (
                xs = (padding = "px-2.5 py-1.5", text = "text-xs", gap = "gap-1"),
                sm = (padding = "px-3 py-2", text = "text-sm", gap = "gap-1.5"),
                base = (padding = "px-4 py-2.5", text = "text-base", gap = "gap-2"),
                lg = (padding = "px-5 py-3", text = "text-lg", gap = "gap-2.5"),
                xl = (padding = "px-6 py-3.5", text = "text-xl", gap = "gap-3"),
            ),
            rounded = (
                base = "rounded-lg",
                lg = "rounded-xl",
                xl = "rounded-2xl",
                full = "rounded-full",
            ),
            states = (
                disabled = "opacity-60 cursor-not-allowed",
                loading = "opacity-60 cursor-not-allowed",
                full_width = "w-full",
            ),
        ),

        # Badge component theme
        badge = (
            base = "inline-flex items-center font-medium rounded-full",
            variants = (
                default = "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300",
                primary = "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300",
                secondary = "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300",
                success = "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300",
                warning = "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
                danger = "bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-300",
                gradient = "bg-gradient-to-r from-blue-500 to-purple-600 text-white",
            ),
            outline_variants = (
                default = "bg-transparent border border-gray-300 text-gray-700 dark:border-gray-600 dark:text-gray-300",
                primary = "bg-transparent border border-blue-300 text-blue-700 dark:border-blue-600 dark:text-blue-300",
                secondary = "bg-transparent border border-purple-300 text-purple-700 dark:border-purple-600 dark:text-purple-300",
                success = "bg-transparent border border-emerald-300 text-emerald-700 dark:border-emerald-600 dark:text-emerald-300",
                warning = "bg-transparent border border-amber-300 text-amber-700 dark:border-amber-600 dark:text-amber-300",
                danger = "bg-transparent border border-rose-300 text-rose-700 dark:border-rose-600 dark:text-rose-300",
                gradient = "bg-transparent border-2 border-transparent bg-gradient-to-r from-blue-500 to-purple-600 bg-clip-text text-transparent",
            ),
            sizes = (
                xs = "px-2 py-0.5 text-xs",
                sm = "px-2.5 py-0.5 text-xs",
                base = "px-3 py-1 text-sm",
                md = "px-3 py-1 text-sm",  # For backward compatibility
                lg = "px-3.5 py-1.5 text-base",
                xl = "px-4 py-2 text-lg",
            ),
            states = (
                animated = "animate-pulse",
                transition = "transition-all duration-200",
            ),
        ),

        # Modal component theme
        modal = (
            dialog = "p-0 bg-transparent backdrop:bg-black/50 backdrop:backdrop-blur-sm",
            content = "relative p-0 bg-white dark:bg-gray-800 rounded-lg shadow-xl border border-gray-200 dark:border-gray-700 max-h-[90vh] overflow-hidden",
            close_button = "absolute top-4 right-4 z-10 p-2 text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300 transition-colors duration-200",
            sizes = (
                sm = "max-w-sm",
                md = "max-w-md",
                lg = "max-w-lg",
                xl = "max-w-xl",
                fullscreen = "max-w-none w-full h-full m-0",
            ),

            # CSS variables for animations and effects
            css_vars = (
                var"--modal-backdrop-color" = "rgba(0, 0, 0, 0.5)",
                var"--modal-backdrop-blur" = "4px",
                var"--modal-animation-duration" = "0.3s",
                var"--modal-close-duration" = "0.2s",
            ),
        ),

        # ModalContent component theme
        modal_content = (
            base = "p-6",
            scrollable = "overflow-y-auto",
            fixed = "overflow-hidden",
        ),

        # ModalFooter component theme
        modal_footer = (
            base = "px-6 py-4 border-t border-gray-200 dark:border-gray-700 flex items-center gap-3",
            justify = (
                start = "justify-start",
                center = "justify-center",
                var"end" = "justify-end",
                between = "justify-between",
            ),
        ),

        # ModalHeader component theme
        modal_header = (
            base = "px-6 py-4 border-b border-gray-200 dark:border-gray-700",
            title = "text-xl font-semibold text-gray-900 dark:text-gray-100",
            subtitle = "mt-1 text-gray-600 dark:text-gray-400",
        ),

        # DrawerModal component theme
        drawer_modal = (
            dialog = "p-0 bg-transparent backdrop:bg-black/50 backdrop:backdrop-blur-sm",
            content = "bg-white dark:bg-gray-800 shadow-xl h-full overflow-auto",
            close_button = "absolute top-4 z-10 p-2 text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300 transition-colors duration-200",
            sizes = (
                sm = "w-64",
                md = "w-80",
                lg = "w-96",
                xl = "w-[28rem]",
                fullscreen = "w-full",
            ),
            positions = (
                left = (close_position = "right-4"),
                right = (close_position = "left-4"),
                top = (close_position = "right-4"),
                bottom = (close_position = "right-4"),
            ),

            # CSS variables for animations and effects
            css_vars = (
                var"--drawer-backdrop-color" = "rgba(0, 0, 0, 0.5)",
                var"--drawer-backdrop-blur" = "4px",
                var"--drawer-animation-duration" = "0.3s",
                var"--drawer-close-duration" = "0.2s",
            ),
        ),

        # Input component theme
        input = (
            base = "w-full rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 placeholder:text-gray-500 dark:placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600",
            sizes = (
                xs = "px-2.5 py-1.5 text-xs",
                sm = "px-3 py-2 text-sm",
                base = "px-4 py-2.5 text-base",
                md = "px-4 py-2.5 text-base",  # For backward compatibility
                lg = "px-5 py-3 text-lg",
                xl = "px-6 py-3.5 text-xl",
            ),
            states = (
                default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
                error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
                success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
            ),
            disabled = "opacity-60 cursor-not-allowed",
            icon_wrapper = "relative",
            icon_container = "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3 text-gray-500 dark:text-gray-400",
            icon_input_padding = "pl-10",
        ),

        # Card component theme
        card = (
            padding = (
                none = "",
                sm = "p-3 md:p-4",
                base = "p-5 md:p-6",
                md = "p-5 md:p-6",  # For backward compatibility
                lg = "p-6 md:p-8",
                xl = "p-8 md:p-10",
            ),
            shadow = (
                none = "",
                sm = "shadow-sm",
                base = "shadow",
                md = "shadow",  # For backward compatibility
                lg = "shadow-lg",
                colored = "shadow-lg shadow-blue-500/10 dark:shadow-blue-400/10",
            ),
            rounded = (
                none = "",
                sm = "rounded",
                base = "rounded-lg",
                md = "rounded-lg",  # For backward compatibility
                lg = "rounded-xl",
                xl = "rounded-2xl",
            ),
            border = (
                none = "",
                default = "border border-slate-200 dark:border-slate-800",
                gradient = "border border-transparent bg-gradient-to-r from-blue-500 to-indigo-500 p-[1px]",
            ),
            variants = (
                default = "bg-white dark:bg-slate-900",
                glass = "backdrop-blur-sm bg-white/80 dark:bg-slate-900/80 border-white/20 dark:border-slate-700/50",
                gradient = "bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-800 dark:to-slate-900",
            ),
            states = (
                hoverable = "transition-all duration-200 hover:shadow-xl hover:-translate-y-0.5 motion-safe:hover:-translate-y-0.5"
            ),
        ),

        # Alert component theme
        alert = (
            base = "rounded-xl border-l-4 border-t border-r border-b p-4 shadow-sm",
            variants = (
                info = "bg-blue-50 border-blue-300 text-blue-800 dark:bg-blue-950/30 dark:border-blue-700 dark:text-blue-300",
                success = "bg-emerald-50 border-emerald-300 text-emerald-800 dark:bg-emerald-950/30 dark:border-emerald-700 dark:text-emerald-300",
                warning = "bg-amber-50 border-amber-300 text-amber-800 dark:bg-amber-950/30 dark:border-amber-700 dark:text-amber-300",
                error = "bg-rose-50 border-rose-300 text-rose-800 dark:bg-rose-950/30 dark:border-rose-700 dark:text-rose-300",
            ),
            states = (
                animated = "animate-[fadeIn_0.3s_ease-in-out]",
                transition = "transition-all duration-300",
            ),
            icon_wrapper = "flex-shrink-0",
            content_wrapper = "flex-1",
            content_with_icon = "ml-3 flex-1",
            dismiss_button = "ml-3 inline-flex flex-shrink-0 rounded-lg p-1.5 hover:bg-black/10 dark:hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-transparent focus:ring-current transition-all duration-200",

            # Icon SVGs for each variant
            icons = (
                info = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" /></svg>""",
                success = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" /></svg>""",
                warning = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" /></svg>""",
                error = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" /></svg>""",
            ),
            dismiss_icon = """<svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" /></svg>""",
        ),

        # Select component theme
        select = (
            base = "w-full appearance-none rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600 bg-[url('data:image/svg+xml;charset=UTF-8,%3csvg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"%3e%3cpolyline points=\"6 9 12 15 18 9\"%3e%3c/polyline%3e%3c/svg%3e')] bg-[length:1.5em_1.5em] bg-[right_0.5rem_center] bg-no-repeat",
            sizes = (
                xs = "px-2.5 py-1.5 pr-8 text-xs",
                sm = "px-3 py-2 pr-9 text-sm",
                base = "px-4 py-2.5 pr-10 text-base",
                md = "px-4 py-2.5 pr-10 text-base",  # For backward compatibility
                lg = "px-5 py-3 pr-11 text-lg",
                xl = "px-6 py-3.5 pr-12 text-xl",
            ),
            states = (
                default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
                error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
                success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
            ),
            disabled = "opacity-60 cursor-not-allowed",
        ),

        # List component theme
        list = (
            base = "text-gray-600 dark:text-gray-400",
            variants = (
                bullet = "list-disc list-inside",
                number = "list-decimal list-inside",
                check = "[&>li]:relative [&>li]:pl-6 [&>li:before]:content-['✓'] [&>li:before]:absolute [&>li:before]:left-0 [&>li:before]:text-green-600 dark:[&>li:before]:text-green-400 [&>li:before]:font-bold",
                none = "list-none",
            ),
            spacing = (tight = "space-y-1", normal = "space-y-2", loose = "space-y-4"),
        ),

        # Table component theme
        table = (
            wrapper = (
                base = "w-full relative",
                sticky = "overflow-auto max-h-[600px]",
                overflow = "overflow-x-auto",
            ),
            container = (
                base = "w-full",
                bordered = "rounded-lg border border-gray-200 dark:border-gray-700",
                overflow = "overflow-hidden",
            ),
            table = (
                base = "w-full text-sm border-separate border-spacing-0",

                # Header styles
                header_base = "[&>thead>tr>th]:bg-white dark:[&>thead>tr>th]:bg-gray-900 [&>thead>tr>th]:text-left [&>thead>tr>th]:text-xs [&>thead>tr>th]:font-semibold [&>thead>tr>th]:text-gray-600 dark:[&>thead>tr>th]:text-gray-400 [&>thead>tr>th]:uppercase [&>thead>tr>th]:tracking-wider [&>thead>tr>th]:border-b [&>thead>tr>th]:border-gray-200 dark:[&>thead>tr>th]:border-gray-700",
                header_padding = (
                    normal = "[&>thead>tr>th]:px-6 [&>thead>tr>th]:py-4",
                    compact = "[&>thead>tr>th]:px-4 [&>thead>tr>th]:py-2",
                ),

                # Cell styles
                cell_base = "[&>tbody>tr>td]:bg-white dark:[&>tbody>tr>td]:bg-gray-900 [&>tbody>tr>td]:text-gray-700 dark:[&>tbody>tr>td]:text-gray-300 [&>tbody>tr>td]:border-b [&>tbody>tr>td]:border-gray-100 dark:[&>tbody>tr>td]:border-gray-800 [&>tbody>tr:last-child>td]:border-b-0",
                cell_padding = (
                    normal = "[&>tbody>tr>td]:px-6 [&>tbody>tr>td]:py-4",
                    compact = "[&>tbody>tr>td]:px-4 [&>tbody>tr>td]:py-2",
                ),

                # Striped rows
                striped = "[&>tbody>tr:nth-child(even)>td]:bg-gray-50/50 dark:[&>tbody>tr:nth-child(even)>td]:bg-gray-800/50",

                # Hover effect
                hover = "[&>tbody>tr]:transition-all [&>tbody>tr]:duration-200 [&>tbody>tr:hover>td]:bg-gray-50 dark:[&>tbody>tr:hover>td]:bg-gray-800/70",

                # Sticky header
                sticky_header = "[&>thead]:sticky [&>thead]:top-0 [&>thead]:z-20 [&>thead]:shadow-sm",

                # Sortable columns
                sortable = "[&>thead>tr>th]:cursor-pointer [&>thead>tr>th]:select-none [&>thead>tr>th]:transition-colors [&>thead>tr>th]:duration-150 [&>thead>tr>th:hover]:bg-gray-50 dark:[&>thead>tr>th:hover]:bg-gray-800",
            ),
            caption = "mb-2 text-sm text-gray-600 dark:text-gray-400 italic",
        ),

        # Progress component theme
        progress = (
            container = "w-full bg-gray-200 dark:bg-gray-800 rounded-full overflow-hidden shadow-inner",
            bar = "transition-all duration-500 ease-out rounded-full shadow-sm",
            sizes = (sm = "h-2", md = "h-3", lg = "h-5"),
            colors = (
                primary = "bg-blue-500 dark:bg-blue-400",
                success = "bg-emerald-500 dark:bg-emerald-400",
                warning = "bg-amber-500 dark:bg-amber-400",
                danger = "bg-rose-500 dark:bg-rose-400",
                gradient = "bg-gradient-to-r from-blue-500 to-purple-600",
            ),
            striped = "bg-[length:1rem_1rem] bg-gradient-to-r from-transparent via-white/20 to-transparent",
            animated_stripe = "animate-[stripes_1s_linear_infinite]",
            label = "mb-2 flex justify-between text-sm font-medium text-gray-700 dark:text-gray-300",
            label_value = "font-semibold",
        ),

        # Spinner component theme
        spinner = (
            container = "inline-flex items-center",
            svg_base = "animate-spin",
            sizes = (sm = "h-4 w-4", md = "h-6 w-6", lg = "h-8 w-8"),
            colors = (
                slate = "text-slate-600 dark:text-slate-400",
                primary = "text-slate-900 dark:text-slate-100",
                white = "text-white",
            ),
            svg = """<svg class=":classes" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" aria-hidden="true">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
</svg>""",
        ),

        # Checkbox component theme
        checkbox = (
            base = "rounded-md border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-200 hover:border-gray-400 dark:hover:border-gray-600",
            sizes = (sm = "h-3.5 w-3.5", md = "h-4 w-4", lg = "h-5 w-5"),
            colors = (
                slate = "text-gray-600 focus:ring-gray-500",
                primary = "text-blue-600 focus:ring-blue-500 dark:text-blue-500 dark:focus:ring-blue-400",
                success = "text-emerald-600 focus:ring-emerald-500 dark:text-emerald-500 dark:focus:ring-emerald-400",
            ),
            disabled = "opacity-60 cursor-not-allowed",
            label_wrapper = "inline-flex items-center gap-2",
            label = "text-sm text-gray-700 dark:text-gray-300 select-none",
        ),

        # FormGroup component theme
        form_group = (
            wrapper = "space-y-1",
            label = "block text-sm font-medium text-gray-700 dark:text-gray-300",
            required_indicator = "text-red-500 ml-1",
            error_text = "text-sm text-rose-600 dark:text-rose-400 animate-[fadeIn_0.3s_ease-in-out]",
            help_text = "text-sm text-gray-500 dark:text-gray-400",
        ),

        # Radio component theme
        radio = (
            wrapper = "space-y-2",
            base = "shrink-0 border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-colors hover:border-gray-400 dark:hover:border-gray-600",
            sizes = (sm = "h-3.5 w-3.5", md = "h-4 w-4", lg = "h-5 w-5"),
            colors = (
                slate = "text-gray-600 focus:ring-gray-500",
                primary = "text-blue-600 focus:ring-blue-500 dark:text-blue-500 dark:focus:ring-blue-400",
                success = "text-emerald-600 focus:ring-emerald-500 dark:text-emerald-500 dark:focus:ring-emerald-400",
            ),
            disabled = "opacity-60 cursor-not-allowed",
            label_wrapper = "flex items-center gap-2 cursor-pointer",
            label = "text-sm text-gray-700 dark:text-gray-300 select-none",
        ),

        # SelectDropdown component theme
        select_dropdown = (
            container = "relative",
            button = "w-full flex items-center justify-between rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600",
            sizes = (
                xs = "px-2.5 py-1.5 text-xs",
                sm = "px-3 py-2 text-sm",
                base = "px-4 py-2.5 text-base",
                lg = "px-5 py-3 text-lg",
                xl = "px-6 py-3.5 text-xl",
            ),
            states = (
                default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
                error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
                success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
            ),
            disabled = "opacity-60 cursor-not-allowed",
            enabled = "cursor-pointer",
            placeholder_color = "text-gray-500 dark:text-gray-400",
            dropdown_arrow = "absolute right-3 h-5 w-5 text-gray-400 transition-transform duration-200 pointer-events-none",
            clear_button = "absolute right-10 top-1/2 -translate-y-1/2 p-1 rounded-md hover:bg-gray-100 dark:hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50",
            clear_icon = "h-4 w-4 text-gray-500 dark:text-gray-400",
            dropdown_panel = "absolute z-50 w-full rounded-xl bg-white dark:bg-gray-950 shadow-lg ring-1 ring-gray-200 dark:ring-gray-800 overflow-hidden",
            search_wrapper = "p-2 border-b border-gray-200 dark:border-gray-800",
            search_input = "w-full px-3 py-2 text-sm rounded-lg border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 placeholder:text-gray-500 dark:placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50",
            options_list = "overflow-y-auto",
            option_button = "w-full px-4 py-2.5 text-left text-sm hover:bg-gray-50 dark:hover:bg-gray-900 focus:outline-none focus:bg-gray-50 dark:focus:bg-gray-900 transition-colors duration-150",
            option_highlighted = "bg-blue-50 dark:bg-blue-900/20",
            option_selected = "bg-blue-100 dark:bg-blue-900/40",
            option_wrapper = "flex items-center",
            option_text = "text-gray-900 dark:text-gray-100",
            checkbox_wrapper = "mr-3",
            checkbox = "h-4 w-4 rounded border-2 transition-all duration-200",
            checkbox_unchecked = "border-gray-300 dark:border-gray-600",
            checkbox_checked = "border-blue-500 bg-blue-500",
            checkbox_icon = "h-3 w-3 text-white",
            no_results = "px-4 py-8 text-center text-sm text-gray-500 dark:text-gray-400",
            selected_label_padding = (with_clear = "pr-12", without_clear = "pr-8"),
        ),

        # Textarea component theme
        textarea = (
            base = "w-full px-4 py-2.5 text-base rounded-xl border bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100 placeholder:text-gray-500 dark:placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-opacity-50 transition-all duration-300 ease-out hover:border-gray-400 dark:hover:border-gray-600",
            resize = (
                none = "resize-none",
                vertical = "resize-y",
                horizontal = "resize-x",
                both = "resize",
            ),
            states = (
                default = "border-gray-300 focus:border-blue-500 focus:ring-blue-500 dark:border-gray-700 dark:focus:border-blue-400",
                error = "border-rose-300 focus:border-rose-500 focus:ring-rose-500 dark:border-rose-700 dark:focus:border-rose-400",
                success = "border-emerald-300 focus:border-emerald-500 focus:ring-emerald-500 dark:border-emerald-700 dark:focus:border-emerald-400",
            ),
            disabled = "opacity-60 cursor-not-allowed",
        ),

        # Container component theme
        container = (
            base = "transition-all duration-300",
            sizes = (
                sm = "max-w-screen-sm",
                md = "max-w-screen-md",
                lg = "max-w-screen-lg",
                xl = "max-w-screen-xl",
                var"2xl" = "max-w-screen-2xl",
                full = "max-w-full",
            ),
            padding = "px-4 sm:px-6 lg:px-8",
            centered = "mx-auto",
            glass = "backdrop-blur-sm bg-white/80 dark:bg-gray-900/80 rounded-2xl shadow-xl ring-1 ring-black/5 dark:ring-white/5 p-6",
        ),

        # Grid component theme
        grid = (
            base = "grid",

            # Column generation function (to handle dynamic values)
            cols_prefix = "grid-cols-",
            sm_prefix = "sm:grid-cols-",
            md_prefix = "md:grid-cols-",
            lg_prefix = "lg:grid-cols-",
            xl_prefix = "xl:grid-cols-",
            gap_prefix = "gap-",
        ),

        # Section component theme
        section = (
            spacing = (
                sm = "py-8 sm:py-12",
                md = "py-12 sm:py-16 md:py-20",
                lg = "py-16 sm:py-20 md:py-24 lg:py-32",
            )
        ),

        # Stack component theme
        stack = (
            base = "flex",
            direction = (horizontal = "flex-row", vertical = "flex-col"),
            gap = (xs = "gap-1", sm = "gap-2", base = "gap-4", lg = "gap-6", xl = "gap-8"),
            align = (
                start = "items-start",
                center = "items-center",
                var"end" = "items-end",
                stretch = "items-stretch",
            ),
            justify = (
                start = "justify-start",
                center = "justify-center",
                var"end" = "justify-end",
                between = "justify-between",
                around = "justify-around",
                evenly = "justify-evenly",
            ),
            wrap = "flex-wrap",
            gap_prefix = "gap-",
        ),

        # Breadcrumb component theme
        breadcrumb = (
            list = "flex items-center space-x-2 text-sm",
            item = "flex items-center",
            current = "text-gray-700 dark:text-gray-300 font-medium",
            link = "text-gray-600 hover:text-blue-600 dark:text-gray-400 dark:hover:text-blue-400 transition-colors duration-200 hover:underline underline-offset-2",
            separator = "mx-2 text-gray-400 dark:text-gray-600",
        ),

        # Pagination component theme
        pagination = (
            wrapper = "flex items-center justify-center",
            list = "flex items-center gap-1",

            # Button/link styles
            button = "relative inline-flex items-center px-3 py-2 text-sm font-medium text-gray-600 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 dark:bg-gray-900 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-800 transition-all duration-200 shadow-sm hover:shadow",
            button_disabled = "relative inline-flex items-center px-3 py-2 text-sm font-medium text-gray-400 bg-gray-50 border border-gray-200 rounded-xl cursor-not-allowed dark:bg-gray-900 dark:border-gray-700 opacity-50",

            # Page number styles
            page = "relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-600 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 dark:bg-gray-900 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-800 transition-all duration-200 shadow-sm hover:shadow",
            page_current = "relative inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-500 border border-blue-500 rounded-xl shadow-sm dark:bg-blue-600 dark:border-blue-600",
            ellipsis = "relative inline-flex items-center px-4 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-200 rounded-lg dark:bg-gray-900 dark:border-gray-700 dark:text-gray-500",

            # Icons
            icon_size = "w-5 h-5",
            prev_icon = """<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" /></svg>""",
            next_icon = """<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" /></svg>""",
        ),

        # TabPanel component theme
        tab_panel = (
            base = "",  # Base class for tab panel (Alpine handles visibility)
            # Alpine.js transition classes are applied directly in the component
        ),

        # Tabs component theme
        tabs = (
            container = "",  # Container wrapper
            nav = (
                base = "flex gap-2 border-b-2 border-gray-200 dark:border-gray-700",
                aria_label_default = "Tabs",
            ),
            button = (
                base = "px-4 py-2.5 text-sm font-medium border-b-2 -mb-[2px] transition-all duration-200 rounded-t-lg",
                active = "text-blue-600 dark:text-blue-400 border-blue-500 dark:border-blue-400 bg-blue-50 dark:bg-blue-950/30",
                inactive = "text-gray-600 dark:text-gray-400 border-transparent hover:text-gray-900 hover:bg-gray-50 dark:hover:text-gray-100 dark:hover:bg-gray-800",
            ),
            panels_container = "mt-4",
        ),

        # DropdownContent component theme
        dropdown_content = (
            base = "absolute z-[9999] min-w-[12rem] rounded-lg border border-gray-200 bg-white shadow-lg dark:border-gray-700 dark:bg-gray-800 py-1",
            # Alpine.js transition classes are applied directly in the component
        ),

        # DropdownDivider component theme
        dropdown_divider = (base = "my-1 h-px bg-gray-200 dark:bg-gray-700",),

        # DropdownItem component theme
        dropdown_item = (
            base = "block w-full text-left px-4 py-2 text-sm transition-colors duration-150",
            variants = (
                default = "text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700",
                danger = "text-red-600 hover:bg-red-50 hover:text-red-700 dark:text-red-400 dark:hover:bg-red-950/20 dark:hover:text-red-300",
                success = "text-green-600 hover:bg-green-50 hover:text-green-700 dark:text-green-400 dark:hover:bg-green-950/20 dark:hover:text-green-300",
            ),
            disabled = "text-gray-400 cursor-not-allowed dark:text-gray-500",
            icon_wrapper = "inline-flex items-center gap-2",
        ),

        # DropdownMenu component theme
        dropdown_menu = (
            base = "inline-block text-left",
            # Alpine.js data and event handlers are applied directly in the component
        ),

        # DropdownSubmenu component theme
        dropdown_submenu = (
            container = "relative",
            trigger = (
                base = "block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700 transition-colors duration-150 flex items-center justify-between",
                icon_wrapper = "flex items-center gap-2",
                chevron_icon = """<svg class="w-4 h-4 ml-auto" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" /></svg>""",
            ),
            content = "absolute z-[10000] min-w-[12rem] rounded-lg border border-gray-200 bg-white shadow-lg dark:border-gray-700 dark:bg-gray-800 py-1",
        ),

        # DropdownTrigger component theme
        dropdown_trigger = (base = "inline-block",),

        # Timeline component theme
        timeline = (
            vertical = "relative list-none",
            horizontal = "flex flex-row items-start gap-4 overflow-x-auto",
        ),

        # TimelineContent component theme
        timeline_content = (
            card_wrapper = "bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm ring-1 ring-gray-200 dark:ring-gray-700",
            plain_wrapper = "",
            content_spacing = "space-y-1",
            title = "font-semibold text-gray-900 dark:text-gray-100",
            subtitle = "text-sm text-gray-500 dark:text-gray-400 mt-1",
        ),

        # TimelineItem component theme
        timeline_item = (
            container = "relative list-none",
            connector_line = "absolute left-4 top-8 bottom-0 w-0.5 bg-gray-200 dark:bg-gray-700",
            content_wrapper = "flex items-start gap-3",
            icon_wrapper = "relative z-10 flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center text-white font-medium",
            icon_wrapper_bg_prefix = "", # User provides full bg class like "bg-blue-500"
            default_icon_bg = "bg-blue-500",
            empty_icon = "w-2 h-2 bg-white rounded-full",
            content_container = "flex-1 pb-8",
        ),

        # Tooltip component theme
        tooltip = (
            container = "relative inline-block",
            trigger_wrapper = "inline-block",
            content = (
                base = "absolute z-[9999] rounded-lg shadow-lg",
                padding = "px-3 py-2",
            ),
            variants = (
                dark = "bg-gray-900 text-white",
                light = "bg-white text-gray-900 border border-gray-200",
            ),
            sizes = (sm = "text-sm", base = "text-base"),
        ),

        # TooltipContent component theme
        tooltip_content = (
            base = "absolute z-[9999] rounded-lg shadow-lg",
            padding = "px-4 py-3",
            variants = (
                dark = "bg-gray-900 text-white",
                light = "bg-white text-gray-900 border border-gray-200",
            ),
            arrow_variants = (dark = "bg-gray-900", light = "bg-white border-gray-200"),
        ),

        # TooltipTrigger component theme
        tooltip_trigger = (base = "inline-block",),

        # TooltipWrapper component theme
        tooltip_wrapper = (base = "relative inline-block",),

        # Heading component theme
        heading = (
            # Default sizes for each heading level (1-6)
            default_sizes = (
                "text-4xl sm:text-5xl",  # h1
                "text-3xl sm:text-4xl",  # h2
                "text-2xl sm:text-3xl",  # h3
                "text-xl sm:text-2xl",   # h4
                "text-lg sm:text-xl",    # h5
                "text-base sm:text-lg",  # h6
            ),

            # Size overrides
            sizes = (
                xs = "text-xs",
                sm = "text-sm",
                base = "text-base",
                lg = "text-lg",
                xl = "text-xl",
                var"2xl" = "text-2xl",
                var"3xl" = "text-3xl",
                var"4xl" = "text-4xl",
                var"5xl" = "text-5xl",
            ),

            # Font weights
            weights = (
                light = "font-light",
                normal = "font-normal",
                medium = "font-medium",
                semibold = "font-semibold",
                bold = "font-bold",
                extrabold = "font-extrabold",
            ),

            # Letter spacing
            tracking = (
                tight = "tracking-tight",
                normal = "tracking-normal",
                wide = "tracking-wide",
            ),

            # Colors
            default_color = "text-gray-900 dark:text-gray-100",
            gradient_color = "bg-gradient-to-r from-blue-500 to-purple-600 bg-clip-text text-transparent",
        ),

        # Link component theme
        link = (
            variants = (
                default = "transition-colors",
                underline = "underline transition-colors",
                hover_underline = "hover:underline transition-all",
            ),
            default_color = "text-slate-900 hover:text-slate-700 dark:text-slate-100 dark:hover:text-slate-300",
        ),

        # Text component theme
        text = (
            variants = (
                body = "text-base leading-relaxed",
                lead = "text-lg sm:text-xl leading-relaxed",
                small = "text-sm leading-normal",
            ),
            sizes = (
                xs = "text-xs",
                sm = "text-sm",
                base = "text-base",
                lg = "text-lg",
                xl = "text-xl",
            ),
            weights = (
                normal = "font-normal",
                medium = "font-medium",
                semibold = "font-semibold",
                bold = "font-bold",
            ),
            align = (
                left = "text-left",
                center = "text-center",
                right = "text-right",
                justify = "text-justify",
            ),
            default_color = "text-slate-600 dark:text-slate-400",
        ),

        # Avatar component theme
        avatar = (
            base = "relative inline-flex overflow-hidden",
            sizes = (
                xs = "h-6 w-6 text-xs",
                sm = "h-8 w-8 text-sm",
                md = "h-10 w-10 text-base",
                lg = "h-12 w-12 text-lg",
                xl = "h-16 w-16 text-xl",
            ),
            shapes = (circle = "rounded-full", square = "rounded-lg"),
            backgrounds = (
                with_image = "bg-slate-100 dark:bg-slate-800",
                fallback = "bg-blue-500 dark:bg-blue-600",
            ),
            image = "h-full w-full object-cover",
            fallback_container = "flex h-full w-full items-center justify-center font-medium text-white",
            default_icon = """<svg class="h-1/2 w-1/2" fill="currentColor" viewBox="0 0 24 24"><path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" /></svg>""",
        ),

        # Divider component theme
        divider = (
            horizontal = (base = "border-t", default_spacing = "my-4"),
            vertical = (
                base = "inline-block min-h-[1em] w-0.5 self-stretch",
                default_spacing = "mx-4",
                default_bg = "bg-slate-200 dark:bg-slate-800",
            ),
            default_color = "border-slate-200 dark:border-slate-800",
        ),

        # Icon component theme
        icon = (
            base = "inline-flex items-center justify-center",
            sizes = (
                xs = "h-3 w-3",
                sm = "h-4 w-4",
                md = "h-5 w-5",
                lg = "h-6 w-6",
                xl = "h-8 w-8",
            ),
            default_color = "text-current",
        ),

        # ThemeToggle component theme
        theme_toggle = (
            base = "inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-slate-400 dark:focus:ring-slate-600",
            variants = (
                default = "bg-slate-100 dark:bg-slate-700 hover:bg-slate-200 dark:hover:bg-slate-600 text-slate-700 dark:text-slate-300",
                ghost = "hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300",
                outline = "border border-slate-300 dark:border-slate-700 hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300",
            ),
            sizes = (
                sm = "px-2.5 py-1.5 text-sm rounded",
                md = "px-3 py-2 text-sm rounded-lg",
                lg = "px-4 py-2.5 text-base rounded-lg",
            ),
            screen_reader_text = "sr-only",
            default_text = "💻 System",
            default_icon = "💻",
        ),

        # Toggle component theme
        toggle = (
            # Switch variant
            switch = (
                wrapper = "inline-flex items-center gap-3",
                label = "text-sm text-gray-700 dark:text-gray-300 select-none",
                disabled = "opacity-60 cursor-not-allowed",
                cursor = "cursor-pointer",
                sizes = (
                    xs = "h-4 w-8",
                    sm = "h-5 w-10",
                    base = "h-6 w-12",
                    lg = "h-7 w-14",
                    xl = "h-8 w-16",
                ),
                colors = (
                    primary = "checked:bg-gradient-to-b checked:from-blue-400 checked:to-blue-600 dark:checked:from-blue-500 dark:checked:to-blue-700",
                    success = "checked:bg-gradient-to-b checked:from-emerald-400 checked:to-emerald-600 dark:checked:from-emerald-500 dark:checked:to-emerald-700",
                    danger = "checked:bg-gradient-to-b checked:from-rose-400 checked:to-rose-600 dark:checked:from-rose-500 dark:checked:to-rose-700",
                ),

                # Size-specific styles with skeuomorphic effects
                styles = (
                    xs = """appearance-none relative inline-block flex-shrink-0 rounded-full
bg-gradient-to-b from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800
shadow-inner transition-all duration-200 ease-in-out
focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 focus:ring-opacity-50 dark:focus:ring-offset-gray-900
before:content-[''] before:inline-block before:rounded-full 
before:bg-gradient-to-b before:from-white before:to-gray-100 dark:before:from-gray-200 dark:before:to-gray-300
before:shadow-[0_2px_8px_rgba(0,0,0,0.3),0_1px_2px_rgba(0,0,0,0.2),inset_0_1px_0_rgba(255,255,255,0.5),inset_0_-1px_0_rgba(0,0,0,0.1)]
before:border before:border-gray-200 dark:before:border-gray-400
before:transition-all before:duration-200 before:ease-in-out
before:h-3 before:w-3 before:absolute before:left-0.5 before:top-0.5
checked:before:translate-x-4 checked:shadow-inner""",
                    sm = """appearance-none relative inline-block flex-shrink-0 rounded-full
bg-gradient-to-b from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800
shadow-inner transition-all duration-200 ease-in-out
focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 focus:ring-opacity-50 dark:focus:ring-offset-gray-900
before:content-[''] before:inline-block before:rounded-full 
before:bg-gradient-to-b before:from-white before:to-gray-100 dark:before:from-gray-200 dark:before:to-gray-300
before:shadow-[0_2px_8px_rgba(0,0,0,0.3),0_1px_2px_rgba(0,0,0,0.2),inset_0_1px_0_rgba(255,255,255,0.5),inset_0_-1px_0_rgba(0,0,0,0.1)]
before:border before:border-gray-200 dark:before:border-gray-400
before:transition-all before:duration-200 before:ease-in-out
before:h-4 before:w-4 before:absolute before:left-0.5 before:top-0.5
checked:before:translate-x-5 checked:shadow-inner""",
                    base = """appearance-none relative inline-block flex-shrink-0 rounded-full
bg-gradient-to-b from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800
shadow-inner transition-all duration-200 ease-in-out
focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 focus:ring-opacity-50 dark:focus:ring-offset-gray-900
before:content-[''] before:inline-block before:rounded-full 
before:bg-gradient-to-b before:from-white before:to-gray-100 dark:before:from-gray-200 dark:before:to-gray-300
before:shadow-[0_2px_8px_rgba(0,0,0,0.3),0_1px_2px_rgba(0,0,0,0.2),inset_0_1px_0_rgba(255,255,255,0.5),inset_0_-1px_0_rgba(0,0,0,0.1)]
before:border before:border-gray-200 dark:before:border-gray-400
before:transition-all before:duration-200 before:ease-in-out
before:h-5 before:w-5 before:absolute before:left-0.5 before:top-0.5
checked:before:translate-x-6 checked:shadow-inner""",
                    lg = """appearance-none relative inline-block flex-shrink-0 rounded-full
bg-gradient-to-b from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800
shadow-inner transition-all duration-200 ease-in-out
focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 focus:ring-opacity-50 dark:focus:ring-offset-gray-900
before:content-[''] before:inline-block before:rounded-full 
before:bg-gradient-to-b before:from-white before:to-gray-100 dark:before:from-gray-200 dark:before:to-gray-300
before:shadow-[0_2px_8px_rgba(0,0,0,0.3),0_1px_2px_rgba(0,0,0,0.2),inset_0_1px_0_rgba(255,255,255,0.5),inset_0_-1px_0_rgba(0,0,0,0.1)]
before:border before:border-gray-200 dark:before:border-gray-400
before:transition-all before:duration-200 before:ease-in-out
before:h-6 before:w-6 before:absolute before:left-0.5 before:top-0.5
checked:before:translate-x-7 checked:shadow-inner""",
                    xl = """appearance-none relative inline-block flex-shrink-0 rounded-full
bg-gradient-to-b from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-800
shadow-inner transition-all duration-200 ease-in-out
focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 focus:ring-opacity-50 dark:focus:ring-offset-gray-900
before:content-[''] before:inline-block before:rounded-full 
before:bg-gradient-to-b before:from-white before:to-gray-100 dark:before:from-gray-200 dark:before:to-gray-300
before:shadow-[0_2px_8px_rgba(0,0,0,0.3),0_1px_2px_rgba(0,0,0,0.2),inset_0_1px_0_rgba(255,255,255,0.5),inset_0_-1px_0_rgba(0,0,0,0.1)]
before:border before:border-gray-200 dark:before:border-gray-400
before:transition-all before:duration-200 before:ease-in-out
before:h-7 before:w-7 before:absolute before:left-0.5 before:top-0.5
checked:before:translate-x-8 checked:shadow-inner""",
                ),
                icon_container = "absolute inset-0 flex items-center justify-between px-1 pointer-events-none",
                icon_off = "text-gray-500 dark:text-gray-400 transition-opacity duration-200",
                icon_on = "text-white transition-opacity duration-200",
                icon_size = "w-3 h-3",
            ),

            # Button variant
            button = (
                wrapper = "inline-block relative",
                input = "sr-only peer",
                base = """inline-flex items-center justify-center font-medium border rounded-lg cursor-pointer
bg-white dark:bg-gray-950 text-gray-700 dark:text-gray-300
border-gray-300 dark:border-gray-700
hover:bg-gray-50 dark:hover:bg-gray-900
peer-checked:bg-gradient-to-r
peer-focus:ring-2 peer-focus:ring-offset-2 peer-focus:ring-blue-500 peer-focus:ring-opacity-50 dark:peer-focus:ring-offset-gray-900
transition-all duration-200""",
                sizes = (
                    xs = (padding = "px-2.5 py-1.5", text = "text-xs", gap = "gap-1"),
                    sm = (padding = "px-3 py-2", text = "text-sm", gap = "gap-1.5"),
                    base = (padding = "px-4 py-2.5", text = "text-base", gap = "gap-2"),
                    lg = (padding = "px-5 py-3", text = "text-lg", gap = "gap-2.5"),
                    xl = (padding = "px-6 py-3.5", text = "text-xl", gap = "gap-3"),
                ),
                colors = (
                    primary = "peer-checked:from-blue-500 peer-checked:to-blue-600 dark:peer-checked:from-blue-600 dark:peer-checked:to-blue-700 peer-checked:text-white peer-checked:border-blue-600 dark:peer-checked:border-blue-700",
                    success = "peer-checked:from-emerald-500 peer-checked:to-emerald-600 dark:peer-checked:from-emerald-600 dark:peer-checked:to-emerald-700 peer-checked:text-white peer-checked:border-emerald-600 dark:peer-checked:border-emerald-700",
                    danger = "peer-checked:from-rose-500 peer-checked:to-rose-600 dark:peer-checked:from-rose-600 dark:peer-checked:to-rose-700 peer-checked:text-white peer-checked:border-rose-600 dark:peer-checked:border-rose-700",
                ),
                disabled = "opacity-60 cursor-not-allowed",
            ),
        ),

        # Global design tokens
        colors = (
            primary = "blue-500",
            secondary = "purple-500",
            neutral = "gray-500",
            success = "emerald-500",
            warning = "amber-500",
            danger = "rose-500",
        ),

        # Shared transition patterns
        transitions = (
            default = "transition-all duration-300 ease-out",
            fast = "transition-all duration-150 ease-out",
            slow = "transition-all duration-500 ease-out",
        ),

        # Focus ring styles
        focus = (
            ring = "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-opacity-50",
            ring_dark = "dark:focus:ring-offset-gray-900",
        ),
    )
end

"""
    get_theme_value(theme, keys::Symbol...; default=nothing)

Helper function for safe nested access to theme values.
Returns the value at the specified path or the default if not found.

# Arguments
- `theme`: The theme NamedTuple
- `keys`: Variable number of Symbol keys representing the path
- `default`: Default value to return if path not found

# Example
```julia
theme = default_theme()
button_base = get_theme_value(theme, :button, :base)
primary_color = get_theme_value(theme, :colors, :primary; default="blue-500")
```
"""
function get_theme_value(theme, keys::Symbol...; default = nothing)
    current = theme
    for key in keys
        if isa(current, NamedTuple) && haskey(current, key)
            current = current[key]
        else
            return default
        end
    end
    return current
end

export default_theme, get_theme_value
