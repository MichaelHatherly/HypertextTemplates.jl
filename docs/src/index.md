# HypertextTemplates.jl

_Hypertext templating DSL for Julia_

This package provides a collection of macros for building and rendering HTML
from Julia code using all the normal control flow syntax of the language, such
as loops and conditional. No intermediate "virtual" DOM is constructed during
rendering process, which reduces memory allocations. Supports streaming renders
of templates via a `StreamingRender` iterator.

When rendered in "development" mode source locations of all elements within the
rendered within the DOM are preserved, which allows for lookup from the browser
to open the file and line that generated a specific DOM element. This source
information is stripped out during production usage to minimise transferred
data and avoid leaking internal server details to clients. `Ctrl+1` will jump
to the `@render` that created the fragment of HTML under the cursor. `Ctrl+2`
will jump to the specific element macro call site that generated the fragment
of HTML under the cursor.

## DSL Basics

```julia
using HypertextTemplates
using HypertextTemplates.Elements

@render @div {class = "bg-blue-400"} begin
    @h1 "Document title"
    @p "Content goes here."
    @ul for num in 1:3
        @li {id = num} @text num
    end
end
```

The DSL (domain specific language) is made up of macro calls that represent
HTML elements that match their official names (with a prefixed `@`). Element
attributes are written with `{}` surrounding key/value pairs defined using `=`.
Nesting of elements within other elements is done using `beign end` blocks, or
for simple cases just as a single expression argument to the macro.

The `@render` macro wraps the elements and converts it to a `String` value. If
you want to render to a predefined `IO` object then pass that object as the
first argument to `@render`, eg. `@render my_buffer @div ...`.

Normal looping and conditional syntax is valid within element macros. So the
`for` syntax above results in a `ul` list with three `li` children with content
`1`, `2`, and `3` respectively. This extends to any third-party packages that
provide their own control flow macros, such as pattern matching.

The `@text` macro is used when the argument to an element macro is not a simple
string literal and marks the expression for rendering into the output.

## Custom Elements

The `HypertextTemplates.Elements` module exports all valid HTML element names and
so should cover most usage. If you want to render a custom element name then use
the `@element` macro to define it.

```julia
@element "my-element" my_element
```

The first argument defines the HTML tag to render. The second is the Julia
identifier to use within code to reference the element definition.

The `my_element` definition can then be used within a DOM definition with the
`@<` macro:

```julia
@render @<my_element {class = "rounded-xl"}
```

If the `@<` macro syntax is too cumbersome for the intended usage of the custom
element then the `@deftag` macro can be used to define a macro equivalent to
`my_element`:

```julia
@deftag macro my_element end

@render @my_element {id = 1} begin
    @p "content"
end
```

## `@component`

Element definitions can be split up into parts for ease of reuse and
maintainability by using the `@component` macro.

```julia
@component function my_component(; prop = "default", n = 1)
    @ul {class = prop} for i in 1:n
        @li {id = i} "content"
    end
end
@deftag macro my_component end

@render @div begin
    @my_component
    @my_component {prop = "custom", n = 2}
end
```

Note how a `@deftag` was also defined for `my_component` such that it could be
invoked with the macro syntax rather than with `@<my_component` syntax.

The keywords defined for the function are the equivalent of "properties" that
you might fine in other component systems within frontend development
technologies. They operate in the exact same way as normal Julia keywords.

## `@<`

The `@<` macro that was previously introduced allows for using components and
elements as first class values; similar to how we can pass `Function` objects
to other functions in Julia.

```julia
@component function my_component(; elem = p, class = "default")
    @div begin
        @<elem {class}
    end
end

@render @div begin
    @my_component
    @my_component {elem = strong, class = "custom"}
end
```

## `@__once__`

When you need to render HTML to a page only once per page, for example a JS
dependency that only needs including once via `<script>`, you can use this
macro to do that. It ensures that during a single `@render` call the contents
of each `@__once__` are only evaluated once even if the rendered components are
called more that once.

Most common use cases are for including `@link`, `@style`, or `@script` tags.

```julia
@component function jquery()
    @__once__ begin
        @script {src = "https://code.jquery.com/jquery-3.6.0.min.js"}
    end
end
@deftag macro jquery end

@component function jq_button()
    @jquery
    @button "Click Me"
end
@deftag macro jq_button end

@component function page()
    @html begin
        @head begin
            @jquery
        end
        @body begin
            @h1 "Hello, World!"
            @jq_button
        end
    end
end
@deftag macro page end
```

## Property Names

Typically property names, which are defined between `{}`s are written as Julia
identifiers. If one of your property names needs to be an invalid word, perhaps
containing a `-` character then you can also use string literals, `""`, to
define the property name. To avoid Julia's linter complaining about string
literals on the left hand side of `=`s you can replace them with `:=`, which is
equivalent.

```julia
@render @div {"x-data" := "{ open: false }"} begin
    @button {"@click" := "open = true"} "Expand"
    @span {"x-show" := "open"} "Content..."
end
```

The `{}` property syntax works very similarly to `NamedTuple` syntax, so if a
property has the same name as a variable you want to use as its value then just
using the variable itself is allow. `...` syntax is also supported to splat a
collection of key/value pairs into `{}`s.

```julia
var = "variable"
props = (; prop = "value", other = true)
@render @div {var, props...}
```

Note that `true` values are rendered just as their property name, while `false`
values are not printed at all. If you need to specifically render
`other="true"` in the DOM then write `@div {other="true"}` instead.

## `@cm_component`

Markdown files can be turned into component definitions that behave the same
way as normal `@component`s. This requires the `CommonMark.jl` package to be
available in your project's dependencies.

```julia
@cm_component markdown_file(; prop) = "file.md"
```

The same set of extensions supported by the `@cm_str` macro in `CommonMark.jl`
are supported in markdown components, expression interpolation included. This
means that any keyword props provided in the component definition, such as
`prop` above can be interpolated into the markdown file and will be rendered
into the final HTML output that the component generates.

## `StreamingRender`

A `StreamingRender` is an iterator that handles asynchronous execution of
`@render` calls. This is useful if your `@component` potentially takes a long
time to render completely and you wish to begin streaming the HTML to the
browser as it becomes available.

```julia
for bytes in StreamingRender(io -> @render io @slow_component {args...})
    write(http_stream, bytes)
end
```

`do`-block syntax is also, naturally, supported by the `StreamingRender`
constructor. All `@component` definitions support streaming out-of-the-box. Be
aware that rendering happens in a `Threads.@spawn`ed task.

## Docstrings

```@autodocs
Modules = [HypertextTemplates]
```

