# AGENTS.md

Guidance for AI assistants working in this repository. It records intent and working
practice. Anything a tool can answer (available commands, file layout, dependency
versions, exported names) is deliberately left out; read `justfile`, `Project.toml`,
`src/`, and the docstrings for that.

## What this package is

HypertextTemplates.jl renders HTML from Julia macros. Elements are macros, attributes use
a `{}` syntax that mimics a NamedTuple, and loops and conditionals are Julia's own. There
is no separate template language and no template parser at runtime.

## Design goals

Weigh a change against these before writing code, and say so when a change trades one
against another.

1. **The template is Julia.** A user writes control flow, calls functions, and reads
   stack traces the way they would in any other Julia code. Prefer a design that falls
   out of Julia's own semantics over one that invents template-only behaviour.
2. **Work happens at macro expansion, not at render time.** Structure known statically
   (tag names, literal attributes, escaped literal text) becomes constants during
   expansion; rendering writes those constants out. Moving work back to render time needs
   a reason.
3. **Rendering allocates as little as possible.** Output streams directly to an `IO` or
   into the append-only render buffer. No intermediate DOM, no string concatenation, no
   stringifying a value that can be written piecewise.
4. **Escaping is on by default and opting out is explicit.** Interpolated content is
   escaped, and `SafeString` is the single visible way to say "this is already HTML".
   The escaping code is security-critical: changes there need tests covering the bypass
   attempts, not just the happy path.
5. **The core stays small; integrations are extensions.** Third-party integrations live
   in `ext/` behind weak dependencies, never in `[deps]`.

## Working practice

### Tests

Rendered output is checked with ReferenceTests.jl against stored references. Write the
failing test first, read the reference diff it produces, and accept a new reference only
once you can explain the change in the HTML. An unexplained reference update is a
regression that passed.

Test files are split by concern. Put a new test where its concern already lives rather
than starting a file.

Source locations are stripped when rendering under test so references stay stable. New
reference tests go through that same helper.

### Working on macros

The macros transform the AST directly. Read the expansion with `@macroexpand` before and
after a change instead of reasoning from the source. Hygiene is the recurring failure
mode: a binding introduced during expansion must not capture or shadow user code, and the
hygiene tests are where that gets pinned down.

Never remove `var` syntax when you find it. It is load-bearing for hygiene.

`@component` takes a whole function definition. Bare `@component name` is not the API.

### Performance changes

Claims about allocation or speed need a measurement, not an argument: show the before and
after. If a change adds runtime work to make expansion simpler, say so, because it cuts
against goal 2. New rendering paths should be reachable from the precompilation workload
so the first render in a session stays cheap.

### Compatibility

The package follows SemVer and supports the Julia version in the `Project.toml` compat
bound, so no syntax newer than that may appear in `src/`. `CHANGELOG.md` follows Keep a
Changelog: every user-visible change gets an entry under `## Unreleased`, written from
the user's point of view rather than the diff's.

### Documentation

Documentation examples are executed at build time, so a broken example fails the docs
build. A user-facing feature lands with both the prose page that explains it and a
docstring.

### Style

Runic decides formatting; never hand-adjust whitespace. Match the surrounding code
otherwise. Comments explain why an ordering or a workaround exists, not what the code
already says.

CI runs the formatter check and the test suite. Both pass locally before you push.
