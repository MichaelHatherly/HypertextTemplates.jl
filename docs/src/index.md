# HypertextTemplates.jl

_Hypertext templating DSL for Julia_

Define HTML-like templates that compile to plain Julia functions. Use looping,
pattern matching, conditions, interpolation, slots, and composition.

## Basic Usage

Valid HTML syntax is valid template syntax in `HypertextTemplates.jl`. If you
know HTML then you're already part-way to knowing how to use this package.
Here's a _really_ simple template function defined in a file called
`template.html`.

```html
<function example>
  <p>A really basic template</p>
</function>
```

We define a template function with a `<function>` tag. The first attribute is
it's name. Note that these names are _case-insensitive_, so `example` is the
same as `Example`.

Any tags and content within the `<function>` tag are what is shown when you
[`render`](@ref) the template.

Template functions are defined in `.html` files which can be are imported into
any Julia code using the exported [`template"<file name>"`](@ref @template_str)
string macro provided by this package. `<file name>` is the path to a valid
`.html` file containing one or more template functions.

So we can import a template into a Julia module with

```julia
module MyTemplates

using HypertextTemplates

template"path/to/template.html"

end
```

And then we can convert it to a `String` with

```julia-repl
julia> text = render(MyTemplates.example)
"<p>A really basic template</p>"
```

### Our Second Template

Let's add a new template function to that `template.html` file:

```html
<function second-template count="1::Integer" value>
  <ul>
    <for iter="1:count" item>
      <li><julia value="item" />: <julia value /></li>
    </for>
  </ul>
</function>
```

There's several concepts to unpack in this template, which we'll cover below.

#### Naming Conventions

We've used "kebab-case" for the naming. You'll need to reference from Julia
with `MyTemplates.var"second-template"` since it's not a valid Julia
identifier. You are free to use "snake-case" instead if you like though. Don't
use "camel-case" though, since the template names are case-insensitive, as
mentioned above.

#### Template Props

There are two properties (or "props", to steal from the JavaScript world). The
first, `count`, is optional and defaults to the value `1`. It is also
restricted to `Integer` types. If you pass a non-`Integer` to this template
function it will throw a `TypeError`. The second prop is called `value` and has
no default value (or type) so it must be given a value (of any type) when
calling the template function.

#### Iteration

In the body of this template we are building up an unordered list of items to
render. We use a `<for>` tag for that. It takes two, or three props. `iter` is
the "iterable" object to loop over. This can, as the name implies, be any Julia
object that supports iteration. `item` declares the name of the iteration
variable that will contain each item iterated over in `iter`. `item` is
equivalent to writing `item=item` or `item="item"` and is just shorthand to
avoid repetition. If you want to use a different name for the iteration
variable then just write `item="whatever-you-want"`.

#### Interpolation

Inside the loop we build the list item, which is the built of two `<julia>`
value interpolations. We pass the `item` iteration variable as the first, and
the `value` prop as the second.

### Using Templates

We've seen one way to get the output of a template function, via the
[`render`](@ref) function. That's useful, but you'll likely want to compose
templates to create more complex hypertext and avoid repetition.

You can use one of your template functions in another template with:

```html
<function third-template number>
  <example />
  <second-template count="number" value='"Hello, world!"' />
  <second-template count="2 * number" value='"Goodbye, world!"' />
</function>
```

So we just use our custom template functions as if they are HTML tags and pass
their props as the attributes. Note that because we can "call" our templates as
if they are HTML tags, we cannot name our templates the same as any valid HTML
(or SVG) tag name. You'll see an error if you try to do so.

We could then [`render`](@ref) `third-template` with

```julia-repl
julia> render(MyTemplates.var"third-template"; number = 2)
```

### Whole-File Templates

So far we've seen how to build "partial" templates, which are templates that
only render part of a complete HTML document. You'll want to be able to render
complete documents though if you want to do anything useful with them.

To do that we can create a `.html` file and start it with a single `<html>` tag
that contains out complete content. The name of the template will be derived
from the file name. For example a file named `path/to/base-template.html` will
be called `<base-template>` in other templates that it is used in, and
`var"base-template"` in Julia code.

```html
<html lang="en">
  <head>
    <title>My Website - <julia value="props.title" /></title>
  </head>
  <body>
    <third-example number="props.number" />
  </body>
</html>
```

Since a whole-file template does not explicitly declare it's props you
reference them via the `props` object that is made available within the
template definition. Currently no optional or typed props are supported here.

### Conditional Rendering

You can conditionally render part of a template with the `<show>` tag. It
has a single prop called `when` which is a Julia expression that evaluates to
`true` or `false`, e.g.

```html
<show when="isodd(number)">
  <p>The number is odd.</p>
</show>
```

A `<fallback>` can be provided for when the `when` claus is `false`.

```html
<show when="isodd(number)">
  <p>The number is odd.</p>
  <fallback>
    <p><em>The number is even!</em></p>
  </fallback>
</show>
```

### Pattern Matching

More complex conditional should instead be written using the `<match>` tag
since it scales much better than nesting `<show>` tags. It supports the same
syntax as [the `Match.jl` package](https://github.com/JuliaServices/Match.jl)
since it uses that package internally.

```html
<function matcher-template number>
  <match value="number">
    <case when="1">
      <p>The number is one.</p>
    </case>
    <case when="::AbstractString">
      <strong>The number is actually a string!</strong>
    </case>
    <case when="[element]">
      <p>
        The number is actually a single element vector containing:
        <julia value="element" />
      </p>
    </case>
    <case when="_">
      <p>The number is something else.</p>
    </case>
  </match>
</function>
```

Check out the documentation for the `Match.jl` package. `@match` and `<match>`
have equivalent features.

### Slots

So far all the custom template function we have defined have just taken a
collection of props and performed their rendering based on that. More complex
requirements will likely need you to render templates "around" other content.
For that we use `<slot>` tags.

```html
<function slot-example>
  <div class="...">
    <h1>Header</h1>
    <slot />
    <hr />
    <p>Footer</p>
  </div>
</function>
```

Note the `<slot />`. We can now use this `slot-example` template as follows:

```html
<slot-example>
  <p>Content that will appear between the header and the footer.</p>
</slot-example>
```

We can also have more complex requirements that need multiple different slots
rendered in a single template function. For that we have named slots:

```html
<function named-slots-example>
  <div class="...">
    <h1>Header</h1>
    <slot content />
    <hr />
    <p><slot footer /></p>
  </div>
</function>
```

And then we'll use it with

```html
<named-slots-example>
  <em:footer>Footer content goes here</em:footer>
  <p:content>The body content</p:content>
</named-slots-example>
```

Note that the usage of the slots can be defined in a different order to that in
which they will be rendered if needed. Try to avoid this if possible though for
the sake of clarity.

## Props vs. Attributes

HTML elements have attributes. Template functions have props. The difference is
that attributes are _static_ and will appear in the rendered result exactly as
they are in template definition. E.g.

```html
<function props-vs-attributes foo>
  <p class="foo"></p>
</function>
```

This will render as follows since `class` is static on a `<p>` element.

```julia-repl
julia> render(Templates.var"props-vs-attributes"; foo="my-css-class")
"<p class=\"foo\"></p>"
```

If instead you need the `class` to be dynamic and render whatever `foo` happens to
contain then prefix the attribute with a `.` as follows:

```html
<function props-vs-attributes-dynamic foo>
  <p .class="foo"></p>
</function>
```

This will render as follows since `class` is static on a `<p>` element.

```julia-repl
julia> render(Templates.var"props-vs-attributes-dynamic"; foo="my-css-class")
"<p class=\"my-css-class\"></p>"
```

If you would like to instead just construct a string attribute based on some
interpolated Julia values then prefixing the attribute with a `$` will do that
for you.

```html
<function edit-contact-link id>
  <a $href="/contact/$id/edit">Edit</a>
</function>
```

This will render as follows:

```julia-repl
julia> render(Templates.var"edit-contact-link"; id=123)
"<a href=\"/contact/123/edit\">Edit</a>"
```

## Markdown Template Files

*Experimental Feature*

You can also use Markdown files as templates. This requires the user to have
imported the `CommonMark` package prior to using a markdown file in a template
macro. Internally the markdown syntax is rendered to HTML using
`CommonMark.jl`'s `html` function and then parsed into a template function using
`HypertextTemplates.jl`.

Extensions are enabled by default in the CommonMark parser, such as tables,
admonitions, and footnotes. Since CommonMark supports embedding *some* basic
HTML tags you can also use those in your markdown templates to call other HTML
or markdown templates for composition. Don't expect complete HTML support to
work though, and if you find yourself embedding large amounts of HTML in your
markdown templates then you should probably just use HTML templates instead and
then embed that custom template tag in your markdown template.

TOML frontmatter syntax is used to allow the template name and props to be
declared. When no `name` is provided the template name will be derived from the
file name. When no `props` are provided the template will have no props.
Frontmatter is optional and declared with `+++` fences at the top of the file.

```markdown
+++
name = "my-template"
props = ["foo", "bar"]
+++

<large-custom-template prop="foo" />

# My Template

This is a template that takes two props: `foo` and `bar`. Their values are
<julia value="foo" /> and <julia value="bar" /> respectively.
```


## Development vs. Production Usage

`HypertextTemplates` supports integration with `Revise`-based development
workflows.

During development when you are editing your templates iteratively to test out
different layouts and styling you'll likely want your templates to
automatically update after editing them without having to re-evaluate
templates. If you have `Revise` loaded in your session this will happen
automatically based on whether the template file has been edited since it was
last called. You don't need to do anything special aside from ensuring you are
running `Revise`, which you probably already are.

Note that this does add a small amount of overhead. For production builds of
your code you should ensure that `Revise` is not part of your build. If you do
this then all templates will be run without checking for updated file contents.

## Template Lookup

During development you'll likely need to find the source file and line number of
particular parts of the rendered HTML. This is usually done by searching the
codebase for matching tag or attribute names with an editor's search feature.
This becomes tedious though, so `HypertextTemplates` provides a "template
lookup" feature that allows you to jump to the source file and line number of
any part of the rendered HTML by hovering over it in the browser and pressing
`Ctrl+Shift`.

To set this up you'll need to have `Revise` loaded in your session, as you
should if you're in a development setting. Doing this will automatically
annotate all rendered HTML with special `data-htloc` attributes that contain the
source file and line number of the template that rendered that part of the HTML.
Secondly, you'll need to add the `TemplateFileLookup` middleware to the `HTTP`
server that is serving your rendered HTML.

```julia
using HypertextTemplates
using HTTP

HTTP.serve(router |> TemplateFileLookup, host, port)
```

Now just hover your mouse over any part of your browser and press `Ctrl+Shift`.
This will open your editor at the correct file and line number. You'll need to
have set the `"EDITOR"` environment variable to your editor command in your
`ENV` in your `~/.julia/config/startup.jl` file for this to work. See the Julia
manual for more details on setting environment variables.

## Public Interface

```@autodocs
Modules = [HypertextTemplates]
```
