# Tailwind CSS v4 source path integration.

const TAILWIND_MANAGED_MARKER = "/* ht:managed */"

"""
    @tailwind_source "path/to/app.css"

Update a Tailwind CSS file with a `@source` directive pointing to
HypertextTemplates.Library source files.

During precompilation, this macro:
1. Locates the CSS file relative to the calling file
2. Gets the current depot path to HypertextTemplates.Library
3. Creates a sidecar CSS file with the `@source` directive
4. Inserts/updates a managed `@import` in the main CSS

When HypertextTemplates updates, the dependent package recompiles and
the path is automatically updated.

# Example

```julia
module MyApp
using HypertextTemplates
using HypertextTemplates.Library

# Updates assets/app.css with Library source path
@tailwind_source "../assets/app.css"
end
```

Given `app.css`, the macro creates `app.ht-source.css` containing:

```css
@source "/path/to/.julia/packages/HypertextTemplates/.../src/Library/**/*.jl";
```

And inserts this line into `app.css` after `@import "tailwindcss";`:

```css
@import "./app.ht-source.css"; /* ht:managed */
```

# Gitignore

Add `*.ht-source.css` to your `.gitignore` to keep absolute paths out of
version control.

# How it works

Tailwind CSS v4 uses the `@source` directive to specify which files to scan for
class names. Since HypertextTemplates.Library lives in Julia's depot path (which
changes on package updates), this macro automatically keeps the path current.

The `/* ht:managed */` comment marks the import line as auto-managed, allowing
the macro to find and update it on subsequent runs.
"""
macro tailwind_source(css_path)
    # Resolve path relative to calling file (like @cm_component does)
    dir = isnothing(__source__.file) ? pwd() : dirname(String(__source__.file))
    full_css_path = isabspath(css_path) ? css_path : joinpath(dir, css_path)

    # Get Library source path at macro expansion time
    library_path = _library_source_dir()

    return esc(
        quote
            # Track CSS file as dependency (recompile if it changes)
            $(Base).include_dependency($full_css_path)

            # Update CSS during precompilation
            $(HypertextTemplates)._update_tailwind_source!($full_css_path, $library_path)

            nothing
        end,
    )
end

"""
    _library_source_dir() -> String

Get the path to the HypertextTemplates Library source directory.
"""
function _library_source_dir()
    pkg_path = pathof(@__MODULE__)
    if isnothing(pkg_path)
        error("Cannot determine HypertextTemplates package path")
    end
    return joinpath(dirname(pkg_path), "Library")
end

"""
    _sidecar_path(css_path) -> String

Compute the sidecar CSS path for a given main CSS file.
`app.css` → `app.ht-source.css`
"""
function _sidecar_path(css_path::String)
    return replace(css_path, r"\.css$" => ".ht-source.css")
end

"""
    _update_tailwind_source!(css_path, library_path) -> Bool

Update a Tailwind CSS file with a `@source` directive for the Library.
Creates a sidecar file with the `@source` directive and adds an `@import`
to the main CSS file.
Returns `true` if any file was modified, `false` otherwise.
"""
function _update_tailwind_source!(css_path::String, library_path::String)
    # Check file exists
    if !isfile(css_path)
        @warn "Tailwind CSS file not found, skipping @tailwind_source update" path =
            css_path
        return false
    end

    modified = false

    # 1. Write sidecar file with @source directive
    sidecar_path = _sidecar_path(css_path)
    escaped_path = _escape_css_path(library_path)
    sidecar_content = """@source "$escaped_path/**/*.jl";\n"""

    existing_sidecar = isfile(sidecar_path) ? read(sidecar_path, String) : ""
    if sidecar_content != existing_sidecar
        try
            _atomic_write(sidecar_path, sidecar_content)
            @info "Updated Tailwind sidecar file" path = sidecar_path
            modified = true
        catch e
            @warn "Failed to write Tailwind sidecar file" path = sidecar_path exception = e
            return false
        end
    end

    # 2. Update main CSS with @import for sidecar
    content = try
        read(css_path, String)
    catch e
        @warn "Failed to read Tailwind CSS file" path = css_path exception = e
        return false
    end

    sidecar_basename = basename(sidecar_path)
    import_line = """@import "./$sidecar_basename"; $TAILWIND_MANAGED_MARKER"""

    # Replace existing managed @import or insert new
    managed_regex = r"@import\s+\"[^\"]+\"\s*;\s*/\*\s*ht:managed\s*\*/"
    new_content = if occursin(managed_regex, content)
        replace(content, managed_regex => import_line)
    else
        _insert_after_import(content, import_line)
    end

    if new_content != content
        try
            _atomic_write(css_path, new_content)
            @info "Updated Tailwind CSS file" path = css_path
            modified = true
        catch e
            @warn "Failed to update Tailwind CSS file" path = css_path exception = e
            return false
        end
    end

    return modified
end

"""
    _escape_css_path(path) -> String

Escape a file path for use in CSS. Uses forward slashes universally.
"""
function _escape_css_path(path::String)
    # Use forward slashes universally (works in CSS on all platforms)
    path = replace(path, "\\" => "/")
    # Escape quotes
    path = replace(path, "\"" => "\\\"")
    return path
end

"""
    _insert_after_import(content, line) -> String

Insert a line after `@import "tailwindcss";` or at the top if not found.
"""
function _insert_after_import(content::String, line::String)
    # Try to find @import "tailwindcss"; or @import 'tailwindcss';
    import_regex = r"(@import\s+[\"']tailwindcss[\"']\s*;)"
    if occursin(import_regex, content)
        return replace(content, import_regex => SubstitutionString("\\1\n$line"))
    end

    # Fallback: insert at the beginning
    return line * "\n" * content
end

"""
    _atomic_write(path, content)

Write content to a file atomically using a temp file and rename.
"""
function _atomic_write(path::String, content::String)
    dir = dirname(path)
    temp = joinpath(dir, ".ht_tailwind_tmp_$(getpid())_$(rand(UInt32))")
    try
        write(temp, content)
        mv(temp, path; force = true)
    finally
        isfile(temp) && rm(temp; force = true)
    end
end
