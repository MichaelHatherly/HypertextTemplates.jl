# HypertextTemplates.jl changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- Rendering is substantially faster and allocates far less. Opening tags and
  runs of literal attributes are merged into single constants during macro
  expansion, escaping scans eight bytes at a time and writes in blocks,
  integers, floats and interpolated attributes are written without building
  intermediate strings, and `@render` fills a purpose-built append-only buffer
  rather than an `IOBuffer`. The rendering machinery is also precompiled, so
  the first render in a session no longer pays to compile it. Adds a
  `PrecompileTools` dependency.
- Under `Revise`, `@render` call sites and component line offsets are memoised
  across renders rather than resolved per rendered element. Entries are
  invalidated by method redefinition or a source file's modification time, and
  nothing is cached while `Revise` has revisions it has not yet applied.
- The `Revise` source-tracking path is type stable: a resolved call site and
  the root location a render records are concretely typed, so a `@render` no
  longer dispatches dynamically to reach them, and a foreign offset cache in
  the render context degrades gracefully instead of raising a `TypeError`.
  `render` and `StreamingRender` also specialise on the function they are
  handed rather than compiling one widened method.
- An opening tag now merges its leading literal attributes into one constant
  even when dynamic attributes follow, and a component call site no longer
  expands the attribute plan it would discard, so those sites expand faster.
- Using an element or component outside `@render` names the tag correctly in
  the error, a missing named slot reports the component, the slot and the slots
  that were passed, and `TemplateFileLookup` errors when `HTTP` is not loaded
  instead of silently doing nothing.
- `Random` is no longer a dependency.
- `StreamingRender` batches more writes per chunk than before, so the chunk
  boundaries an iterating consumer observes have changed.
- `@element` now requires its element name to be a string or symbol literal
  and raises a descriptive error otherwise.

### Added

- `close(::StreamingRender)` stops a stream the consumer abandons, releasing
  the render task and its flush timer. A stream also closes itself once the
  render finishes.
- A Development Tools page in the manual covers the `data-htloc` and
  `data-htroot` attributes a render writes under Revise, how to switch them off,
  `TemplateFileLookup` and the key presses that open a template from the
  browser, live reloading of components and Markdown files, and rendering a
  `Bonito.App` inside a template. None of that was documented outside a
  docstring.

### Fixed

- `<script>` and `<style>` contents are written as raw text. They were
  entity-escaped, which browsers do not decode inside those elements, so
  `@script "if (a < b) {}"` produced broken JavaScript. What is neutralised is
  whatever would take the parser back out of the element: that element's own
  end tag, `</style` or `</script`, and `<!--` in a `script`, each written with
  a backslash after the `<`. A sequence is caught wherever in the body it
  falls: inside one child, divided between two of them, or divided across a
  slot boundary. An end tag for any other element is left as it stands, since
  the parser reads the name after the `</` and hands the characters back as
  text. Content written directly in the element is its raw text, `@text` and the
  content passed into a slot the element renders included. The innermost
  element decides, so an element nested inside a `script` or a `style` starts
  markup again and its own children are escaped: a `<script type="text/template">`
  block is parsed as HTML by the page later, and a value that reached it from a
  user would otherwise become markup in that parse. Nothing written in these two
  elements is entity-escaped, a `SafeString` included, and the sequences are
  neutralised in a `SafeString` as well: trusted JSON assembled from a user's
  data can carry a `</script`, which ended the `script` and left the rest of the
  value as markup. `<\/` is what JavaScript reads as `</` inside a string and is
  a valid JSON string escape, so the program and the data it parses are
  unchanged. `<\!--` is not a JSON escape, so a value carrying a comment opener
  will not parse back; there is no spelling that both contains the sequence and
  survives, and containment wins.
- A value interpolated into a template is shown the destination the render was
  given, so a `show` method that consults the stream sees the properties the
  caller's `IOContext` carries rather than the defaults. It previously saw the
  defaults everywhere except inside a `script` or a `style`.
- Attribute names taken from a splatted collection are validated and an
  `ArgumentError` names the offender. A name containing `"`, `>`, `=` or
  whitespace was written raw and could inject attributes.
- A `StreamingRender` whose render function throws now rethrows that exception
  to the consumer after the chunks already rendered. It closed cleanly, so the
  consumer received a truncated document and no error.
- The `StreamingRender` docstring describes what `chunk_size` does; it was
  documented as unused.
- Fix `MethodError` when writing a string to the writer that `StreamingRender`
  hands to its render function: `write(io, "text")` and `print(io, "text")`
  were ambiguous against `Base`.
- Fix `@deftag`, `@element` and `@cm_component` in modules that define a
  binding named `esc`, `Expr`, `GlobalRef`, `Symbol`, `Val`, `read`, `String`
  or `joinpath`, and when `HypertextTemplates` is imported under another name.
- Fix a race between `StreamingRender`'s flush timer and the render task that
  could duplicate or tear bytes in the streamed output, most easily on Julia
  1.12+.
- Fix `StreamingRender(f; chunk_size = n)` hanging its consumer forever when
  passed a negative `chunk_size`.
- Fix a `MethodError` when `@cm_component` is expanded somewhere without a
  source file, such as the REPL.
- Fix a `MethodError` when rendering a `CommonMark.Node` that was parsed
  without source information, or with a non-string `source` in its metadata,
  while `Revise` is loaded.
- Escape the file paths written into `data-htroot` and `data-htloc`
  attributes.
- Manual examples that rendered nothing where the surrounding text said they
  rendered a fragment. Calling a component as a plain function sends its output
  to a buffer of its own, and an element child that is neither a literal nor an
  interpolation is evaluated and discarded; both are written with `@<` and `$`
  now.
- Manual claims that did not match the implementation: rendering was described
  as zero-allocation, typed props as checked at compile time, two working
  parenthesis and newline forms as syntax errors, and `StreamingRender`'s
  batching timeout as configurable. The `TemplateFileLookup` docstring
  described a `Ctrl` click; the handler listens for `Ctrl+1` and `Ctrl+2` over
  the element instead.

## [v2.2.4] - 2026-03-20

### Changed

- Move `CodeTracking` from direct dependency to Revise extension via `Revise.CodeTracking` [#58]

## [v2.2.3] - 2025-06-25

### Fixed

- Add documentation for `@__slot__` and `$` shorthand `@text` syntax [#37]
- Fix broken `@cm_component` macro caused by changes to `Revise` APIs [#37]
- Fix `StreamingRender` iterator on Julia 1.12+ [#37]

## [v2.2.2] - 2025-01-08

### Fixed

- Fix `Revise`-related error due to missing `convert` for `@cm_component` [#35]

## [v2.2.1] - 2025-01-07

### Fixed

- Allow `module`-qualified `@cm_component` definitions [#34]

## [v2.2.0] - 2024-12-09

### Added

- Added `@__once__` macro [#30]

## [v2.1.0] - 2024-12-06

### Added

- Added `StreamingRender` iterator to support streaming template renders [#29]

## [v2.0.1] - 2024-12-04

### Fixed

- Allow embedding live `Bonito.App` objects [#28]

## [v2.0.0] - 2024-11-16

### Changed

- Refactor package [#27]
- Switch HTML parser [#25]

### Fixed

- Fixed SVG element detection and rendering [#22]
- Interpolated HTML attribute escaping improvements [#26]

## [v1.3.1] - 2024-01-05

### Fixed

- Optimise template functions containing static attributes [#21]

## [v1.3.0] - 2023-12-20

### Added

- Added Markdown templates [#18]

## [v1.2.1] - 2023-12-07

### Fixed

- Fixed `<fallback>` bug in `<show>` nodes [#17]

## [v1.2.0] - 2023-11-26

### Added

- Added a Custom Element macro for bypassing default template tag behaviour [#13]
- Added support for `...` props [#14]
- Added support for `...` in element attributes [#16]

### Fixed

- Corrected file and line info in generated code [#15]

## [v1.1.0] - 2023-11-01

### Added

- Ctrl-Shift-hover to navigate from browser to template source [#10]
- Added `$` prefix attribute syntax for string interpolation [#11]
- Added support for exact line numbers in template "goto" feature [#12]

## [v1.0.1] - 2023-10-31

### Fixed

- Fixed `<for>` with `index` prop [#8]

## [v1.0.0] - 2023-10-19

Initial release.


<!-- Links generated by Changelog.jl -->

[v1.0.0]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v1.0.0
[v1.0.1]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v1.0.1
[v1.1.0]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v1.1.0
[v1.2.0]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v1.2.0
[v1.2.1]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v1.2.1
[v1.3.0]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v1.3.0
[v1.3.1]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v1.3.1
[v2.0.0]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v2.0.0
[v2.0.1]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v2.0.1
[v2.1.0]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v2.1.0
[v2.2.0]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v2.2.0
[v2.2.1]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v2.2.1
[v2.2.2]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v2.2.2
[v2.2.3]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v2.2.3
[v2.2.4]: https://github.com/MichaelHatherly/HypertextTemplates.jl/releases/tag/v2.2.4
[#8]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/8
[#10]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/10
[#11]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/11
[#12]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/12
[#13]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/13
[#14]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/14
[#15]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/15
[#16]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/16
[#17]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/17
[#18]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/18
[#21]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/21
[#22]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/22
[#25]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/25
[#26]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/26
[#27]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/27
[#28]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/28
[#29]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/29
[#30]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/30
[#34]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/34
[#35]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/35
[#37]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/37
[#58]: https://github.com/MichaelHatherly/HypertextTemplates.jl/issues/58
