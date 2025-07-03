using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

function get_example_names()
    root = joinpath(@__DIR__, "..", "examples")
    return Base.map(readdir(root)) do file
        component = getfield(@__MODULE__, Symbol(first(splitext(file))))
        title = component_title(component)
        output_file = replace(file, r"\.jl$" => ".html")
        return (; file, component, title, output_file)
    end
end

@component function HTMLDocument(; title::String, current_page::String = "")
    @html {lang = "en"} begin
        @head begin
            @meta {charset = "UTF-8"}
            @meta {name = "viewport", content = "width=device-width, initial-scale=1.0"}
            @title $title
            @script {src = "https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"}
            @script {
                defer = true,
                src = "https://cdn.jsdelivr.net/npm/@alpinejs/anchor@3.x.x/dist/cdn.min.js",
            }
            @script {
                defer = true,
                src = "https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js",
            }
            @style {type = "text/tailwindcss"} begin
                @text HypertextTemplates.SafeString("""
                /* Enable class-based dark mode for Tailwind CSS v4 */
                @variant dark (&:where(.dark, .dark *));

                /* Keyframes for progress bar stripes animation */
                @keyframes stripes {
                    0% {
                        background-position: 0 0;
                    }
                    100% {
                        background-position: 1rem 0;
                    }
                }

                /* Hide elements with x-cloak until Alpine initializes */
                [x-cloak] { display: none !important; }
                """)
            end
            # # Load dropdown.js globally for dropdown components
            # # This ensures Alpine.data('dropdown', ...) is available for all dropdowns
            # @script begin
            #     @text HypertextTemplates.SafeString(
            #         read(
            #             joinpath(dirname(@__DIR__), "..", "src/Library/assets/dropdown.js"),
            #             String,
            #         ),
            #     )
            # end
        end
        @body {
            class = "bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 min-h-screen flex",
        } begin
            # Navigation sidebar - not fixed, part of flex layout
            @div {
                class = "w-80 bg-white dark:bg-slate-800 border-r border-slate-200 dark:border-slate-700 overflow-y-auto flex-shrink-0",
            } begin
                @div {class = "p-6"} begin
                    @Stack {gap = 6} begin
                        # Header
                        @Stack {gap = 2} begin
                            @Heading {level = 3, size = :lg} "Components"
                            @Text {size = :sm, color = "text-slate-600 dark:text-slate-400"} "Browse all component examples"
                        end

                        # Navigation links
                        @Stack {gap = 1} begin
                            for each in get_example_names()
                                href = each.output_file
                                label = each.title
                                is_current = href == current_page
                                link_class = if is_current
                                    "block px-3 py-2 rounded-lg bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300 font-medium"
                                else
                                    "block px-3 py-2 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-300 transition-colors"
                                end

                                @a {
                                    href = href,
                                    class = link_class,
                                    "aria-current" = is_current ? "page" : nothing,
                                } $label
                            end
                        end

                        @Divider

                        @ThemeToggle

                        # Back to docs link
                        @a {
                            href = "../library-components",
                            class = "inline-flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 transition-colors",
                        } begin
                            @text "← Back to documentation"
                        end
                    end
                end
            end

            # Main content area
            @div {class = "flex-1 overflow-y-auto px-6 py-2"} begin
                @__slot__()
            end
        end
    end
end
@deftag macro HTMLDocument end
