@testset "Tailwind Source Macro" begin
    # Test helper functions directly
    @testset "Library path resolution" begin
        lib_path = HypertextTemplates._library_source_dir()
        @test isdir(lib_path)
        @test isfile(joinpath(lib_path, "Library.jl"))
    end

    @testset "CSS path escaping" begin
        # Forward slashes on all platforms
        @test HypertextTemplates._escape_css_path("C:\\Users\\test") == "C:/Users/test"
        # Quote escaping
        @test HypertextTemplates._escape_css_path("path\"with\"quotes") ==
              "path\\\"with\\\"quotes"
        # Normal path unchanged
        @test HypertextTemplates._escape_css_path("/normal/path") == "/normal/path"
    end

    @testset "Sidecar path computation" begin
        @test HypertextTemplates._sidecar_path("/path/to/app.css") ==
              "/path/to/app.ht-source.css"
        @test HypertextTemplates._sidecar_path("styles.css") == "styles.ht-source.css"
    end

    @testset "Insert after import" begin
        # With @import "tailwindcss"
        content = """@import "tailwindcss";

.custom { color: red; }
"""
        result = HypertextTemplates._insert_after_import(content, "@import \"test\";")
        @test occursin("@import \"tailwindcss\";\n@import \"test\";", result)
        @test occursin(".custom { color: red; }", result)

        # With single quotes
        content_single = """@import 'tailwindcss';
body { margin: 0; }
"""
        result_single =
            HypertextTemplates._insert_after_import(content_single, "@import \"test\";")
        @test occursin("@import 'tailwindcss';\n@import \"test\";", result_single)

        # No import - fallback to prepend
        content_no_import = """.custom { color: red; }
"""
        result_no_import =
            HypertextTemplates._insert_after_import(content_no_import, "@import \"test\";")
        @test startswith(result_no_import, "@import \"test\";")
    end

    # Test the main update function with temp files
    mktempdir() do tmpdir
        @testset "Creates sidecar and inserts @import" begin
            css_path = joinpath(tmpdir, "test1.css")
            sidecar_path = joinpath(tmpdir, "test1.ht-source.css")
            write(
                css_path,
                """@import "tailwindcss";

.custom { color: red; }
""",
            )

            lib_path = HypertextTemplates._library_source_dir()
            result = @test_logs (:info, r"sidecar") (:info, r"CSS file") begin
                HypertextTemplates._update_tailwind_source!(css_path, lib_path)
            end

            @test result == true

            # Sidecar file created with @source directive
            @test isfile(sidecar_path)
            sidecar_content = read(sidecar_path, String)
            @test occursin("@source", sidecar_content)
            # Path is escaped (backslashes → forward slashes on Windows)
            escaped_lib_path = HypertextTemplates._escape_css_path(lib_path)
            @test occursin(escaped_lib_path, sidecar_content)

            # Main CSS has @import with ht:managed marker
            content = read(css_path, String)
            @test occursin("ht:managed", content)
            @test occursin("@import \"./test1.ht-source.css\"", content)
            @test occursin(r"@import.*tailwindcss.*\n@import.*ht-source", content)
        end

        @testset "Update existing managed @import" begin
            css_path = joinpath(tmpdir, "test2.css")
            sidecar_path = joinpath(tmpdir, "test2.ht-source.css")
            write(
                css_path,
                """@import "tailwindcss";
@import "./old-sidecar.css"; /* ht:managed */

.custom { color: red; }
""",
            )

            lib_path = HypertextTemplates._library_source_dir()
            result = @test_logs (:info, r"sidecar") (:info, r"CSS file") begin
                HypertextTemplates._update_tailwind_source!(css_path, lib_path)
            end

            @test result == true
            content = read(css_path, String)
            @test !occursin("old-sidecar", content)
            @test occursin("test2.ht-source.css", content)
            # Should only have one managed line
            @test count("ht:managed", content) == 1

            # Sidecar should exist
            @test isfile(sidecar_path)
        end

        @testset "Idempotent update" begin
            lib_path = HypertextTemplates._library_source_dir()
            escaped_path = HypertextTemplates._escape_css_path(lib_path)
            css_path = joinpath(tmpdir, "test3.css")
            sidecar_path = joinpath(tmpdir, "test3.ht-source.css")

            # Pre-create both files in expected state
            write(sidecar_path, """@source "$escaped_path/**/*.jl";\n""")
            write(
                css_path,
                """@import "tailwindcss";
@import "./test3.ht-source.css"; /* ht:managed */
""",
            )

            result = HypertextTemplates._update_tailwind_source!(css_path, lib_path)
            @test result == false  # No change needed
        end

        @testset "Missing file warning" begin
            nonexistent = joinpath(tmpdir, "nonexistent.css")
            @test_logs (:warn, r"not found") begin
                result =
                    HypertextTemplates._update_tailwind_source!(nonexistent, "/some/path")
                @test result == false
            end
        end

        @testset "Fallback insertion at top" begin
            css_path = joinpath(tmpdir, "test5.css")
            sidecar_path = joinpath(tmpdir, "test5.ht-source.css")
            write(
                css_path,
                """.custom { color: red; }
""",
            )

            lib_path = HypertextTemplates._library_source_dir()
            result = @test_logs (:info, r"sidecar") (:info, r"CSS file") begin
                HypertextTemplates._update_tailwind_source!(css_path, lib_path)
            end

            @test result == true

            # Main CSS has @import at top
            content = read(css_path, String)
            @test startswith(content, "@import")
            @test occursin("ht:managed", content)

            # Sidecar created
            @test isfile(sidecar_path)
        end

        @testset "Atomic write" begin
            css_path = joinpath(tmpdir, "test_atomic.css")
            content = "@import \"tailwindcss\";\n"
            HypertextTemplates._atomic_write(css_path, content)

            @test isfile(css_path)
            @test read(css_path, String) == content
            # No temp files left behind
            @test isempty(filter(f -> startswith(f, ".ht_tailwind_tmp"), readdir(tmpdir)))
        end
    end
end
