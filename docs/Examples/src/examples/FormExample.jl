using HypertextTemplates
using HypertextTemplates.Elements
using HypertextTemplates.Library

@component function FormExample()
    @Container {class = "py-8"} begin
        @Stack {gap = 8} begin
            @Heading {level = 1, class = "text-center mb-8"} "Form Components Demo"

            # Complete form example
            @Card {padding = :lg} begin
                @form {method = "post", action = "#"} begin
                    @Stack {gap = 6} begin
                        @Heading {level = 2} "User Registration Form"

                        # Text inputs
                        @Grid {cols = 1, md = 2, gap = 4} begin
                            @FormGroup {label = "First Name", required = true} begin
                                @Input {
                                    name = "first_name",
                                    placeholder = "John",
                                    required = true,
                                }
                            end

                            @FormGroup {label = "Last Name", required = true} begin
                                @Input {
                                    name = "last_name",
                                    placeholder = "Doe",
                                    required = true,
                                }
                            end
                        end

                        @FormGroup {
                            label = "Email Address",
                            help = "We'll never share your email",
                            required = true,
                        } begin
                            @Input {
                                type = "email",
                                name = "email",
                                placeholder = "john@example.com",
                                required = true,
                            }
                        end

                        @FormGroup {
                            label = "Password",
                            help = "Must be at least 8 characters",
                        } begin
                            @Input {
                                type = "password",
                                name = "password",
                                placeholder = "••••••••",
                            }
                        end

                        # Select
                        @FormGroup {label = "Country"} begin
                            @Select {
                                name = "country",
                                options = [
                                    ("", "Select a country"),
                                    ("us", "United States"),
                                    ("uk", "United Kingdom"),
                                    ("ca", "Canada"),
                                    ("au", "Australia"),
                                    ("de", "Germany"),
                                    ("fr", "France"),
                                ],
                            }
                        end

                        # Enhanced Select Dropdown with Search
                        @FormGroup {label = "Programming Language"} begin
                            @SelectDropdown {
                                name = "language",
                                placeholder = "Choose your favorite language...",
                                searchable = true,
                                options = [
                                    ("julia", "Julia"),
                                    ("python", "Python"),
                                    ("javascript", "JavaScript"),
                                    ("typescript", "TypeScript"),
                                    ("rust", "Rust"),
                                    ("go", "Go"),
                                    ("ruby", "Ruby"),
                                    ("java", "Java"),
                                    ("csharp", "C#"),
                                    ("cpp", "C++"),
                                    ("swift", "Swift"),
                                    ("kotlin", "Kotlin"),
                                ],
                                value = "julia",
                            }
                        end

                        # Multiple Selection Dropdown
                        @FormGroup {label = "Skills", help = "Select all that apply"} begin
                            @SelectDropdown {
                                name = "skills[]",
                                placeholder = "Select your skills...",
                                multiple = true,
                                searchable = true,
                                options = [
                                    ("frontend", "Frontend Development"),
                                    ("backend", "Backend Development"),
                                    ("mobile", "Mobile Development"),
                                    ("devops", "DevOps"),
                                    ("ml", "Machine Learning"),
                                    ("data", "Data Science"),
                                    ("security", "Security"),
                                    ("ui", "UI/UX Design"),
                                    ("pm", "Project Management"),
                                    ("qa", "Quality Assurance"),
                                ],
                                value = ["frontend", "backend"],
                            }
                        end

                        # Clearable Select Dropdown
                        @FormGroup {
                            label = "Timezone",
                            help = "Click the × to clear selection",
                        } begin
                            @SelectDropdown {
                                name = "timezone",
                                placeholder = "Select your timezone...",
                                clearable = true,
                                options = [
                                    ("utc", "UTC (Coordinated Universal Time)"),
                                    ("est", "EST (Eastern Standard Time)"),
                                    ("cst", "CST (Central Standard Time)"),
                                    ("mst", "MST (Mountain Standard Time)"),
                                    ("pst", "PST (Pacific Standard Time)"),
                                    ("gmt", "GMT (Greenwich Mean Time)"),
                                    ("cet", "CET (Central European Time)"),
                                    ("jst", "JST (Japan Standard Time)"),
                                    ("aest", "AEST (Australian Eastern Standard Time)"),
                                ],
                                value = "pst",
                            }
                        end

                        # Textarea
                        @FormGroup {label = "Bio", help = "Tell us about yourself"} begin
                            @Textarea {
                                name = "bio",
                                rows = 4,
                                placeholder = "I'm a developer who loves...",
                            }
                        end

                        # Radio buttons
                        @FormGroup {label = "Account Type"} begin
                            @Radio {
                                name = "account_type",
                                options = [
                                    ("personal", "Personal Account"),
                                    ("business", "Business Account"),
                                    ("developer", "Developer Account"),
                                ],
                                value = "personal",
                            }
                        end

                        # Checkboxes
                        @FormGroup {label = "Preferences"} begin
                            @Stack {gap = 2} begin
                                @Checkbox {
                                    name = "newsletter",
                                    label = "Subscribe to newsletter",
                                    checked = true,
                                }
                                @Checkbox {
                                    name = "updates",
                                    label = "Receive product updates",
                                }
                                @Checkbox {
                                    name = "marketing",
                                    label = "Marketing communications",
                                }
                            end
                        end

                        @Divider {}

                        # Modern button variations
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Action Buttons"
                            @Stack {direction = :horizontal, gap = 3, wrap = true} begin
                                @Button {
                                    variant = :gradient,
                                    rounded = :xl,
                                    icon_left = """<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>""",
                                } "Create Account"
                                @Button {variant = :outline, rounded = :lg} "Save Draft"
                                @Button {variant = :ghost} "Cancel"
                            end
                        end
                    end
                end
            end

            # Form states demo
            @Card {padding = :lg} begin
                @Stack {gap = 4} begin
                    @Heading {level = 2} "Form States"

                    @Grid {cols = 1, md = 3, gap = 4} begin
                        @FormGroup {label = "Default State"} begin
                            @Input {placeholder = "Normal input"}
                        end

                        @FormGroup {label = "Success State", help = "Valid input"} begin
                            @Input {
                                state = :success,
                                value = "Valid data",
                                placeholder = "Success",
                            }
                        end

                        @FormGroup {label = "Error State", error = "This field is required"} begin
                            @Input {state = :error, placeholder = "Error state"}
                        end
                    end

                    @Divider {}

                    @Heading {level = 3} "SelectDropdown States & Sizes"

                    @Grid {cols = 1, md = 2, gap = 4} begin
                        # Different sizes
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Component Sizes"
                            @SelectDropdown {
                                size = :xs,
                                placeholder = "Extra small select",
                                options = [("1", "Option 1"), ("2", "Option 2")],
                            }
                            @SelectDropdown {
                                size = :sm,
                                placeholder = "Small select",
                                options = [("1", "Option 1"), ("2", "Option 2")],
                            }
                            @SelectDropdown {
                                size = :base,
                                placeholder = "Base size select",
                                options = [("1", "Option 1"), ("2", "Option 2")],
                            }
                            @SelectDropdown {
                                size = :lg,
                                placeholder = "Large select",
                                options = [("1", "Option 1"), ("2", "Option 2")],
                            }
                        end

                        # Different states
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Component States"
                            @SelectDropdown {
                                state = :default,
                                placeholder = "Default state",
                                options = [("active", "Active"), ("inactive", "Inactive")],
                            }
                            @SelectDropdown {
                                state = :success,
                                value = "valid",
                                options =
                                    [("valid", "Valid Selection"), ("invalid", "Invalid")],
                            }
                            @SelectDropdown {
                                state = :error,
                                placeholder = "Error state",
                                options = [("1", "Option 1"), ("2", "Option 2")],
                            }
                            @SelectDropdown {
                                disabled = true,
                                placeholder = "Disabled select",
                                options = [("1", "Option 1"), ("2", "Option 2")],
                            }
                        end
                    end

                    @Divider {}

                    @Heading {level = 3} "Clearable SelectDropdown Examples"

                    @Grid {cols = 1, md = 2, gap = 6} begin
                        # Basic clearable
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Basic Clearable Dropdown"
                            @FormGroup {
                                label = "Department",
                                help = "Optional field - can be cleared",
                            } begin
                                @SelectDropdown {
                                    name = "department",
                                    placeholder = "Select department...",
                                    clearable = true,
                                    options = [
                                        ("eng", "Engineering"),
                                        ("sales", "Sales"),
                                        ("marketing", "Marketing"),
                                        ("hr", "Human Resources"),
                                        ("finance", "Finance"),
                                    ],
                                }
                            end
                        end

                        # Clearable with search
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Searchable & Clearable"
                            @FormGroup {
                                label = "Project",
                                help = "Search and clear functionality",
                            } begin
                                @SelectDropdown {
                                    name = "project",
                                    placeholder = "Search projects...",
                                    clearable = true,
                                    searchable = true,
                                    value = "project-beta",
                                    options = [
                                        ("project-alpha", "Project Alpha"),
                                        ("project-beta", "Project Beta"),
                                        ("project-gamma", "Project Gamma"),
                                        ("project-delta", "Project Delta"),
                                        ("project-epsilon", "Project Epsilon"),
                                        ("project-zeta", "Project Zeta"),
                                    ],
                                }
                            end
                        end

                        # Multiple selection with clearable
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Multiple Selection with Clear All"
                            @FormGroup {
                                label = "Tags",
                                help = "Clear all selections at once",
                            } begin
                                @SelectDropdown {
                                    name = "tags[]",
                                    placeholder = "Select tags...",
                                    clearable = true,
                                    multiple = true,
                                    searchable = true,
                                    value = ["urgent", "bug"],
                                    options = [
                                        ("urgent", "Urgent"),
                                        ("bug", "Bug"),
                                        ("feature", "Feature"),
                                        ("enhancement", "Enhancement"),
                                        ("documentation", "Documentation"),
                                        ("testing", "Testing"),
                                        ("refactor", "Refactor"),
                                    ],
                                }
                            end
                        end

                        # Clearable with different states
                        @Stack {gap = 3} begin
                            @Text {weight = :semibold} "Clearable with States"
                            @Stack {gap = 2} begin
                                @SelectDropdown {
                                    clearable = true,
                                    state = :success,
                                    value = "approved",
                                    placeholder = "Status...",
                                    options = [
                                        ("pending", "Pending"),
                                        ("approved", "Approved"),
                                        ("rejected", "Rejected"),
                                    ],
                                }
                                @Text {size = :sm, color = "text-green-600"} "Valid selection (clearable)"
                            end
                            @Stack {gap = 2} begin
                                @SelectDropdown {
                                    clearable = true,
                                    state = :error,
                                    placeholder = "Priority level...",
                                    options = [
                                        ("low", "Low"),
                                        ("medium", "Medium"),
                                        ("high", "High"),
                                        ("critical", "Critical"),
                                    ],
                                }
                                @Text {size = :sm, color = "text-red-600"} "Required field (clearable)"
                            end
                        end
                    end
                end
            end
        end
    end
end
@deftag macro FormExample end

component_title(::typeof(FormExample)) = "Form Components"
