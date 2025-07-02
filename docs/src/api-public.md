# Public API

The public API consists of all exported functions, macros, and types that are intended for end users. These APIs are stable and follow semantic versioning - breaking changes will only occur in major version updates. The public API includes the core `@render` macro, component definition utilities like `@component` and `@deftag`, security features like `SafeString`, and all the HTML element macros available through `HypertextTemplates.Elements`. These are the building blocks you'll use to create templates and components in your applications.

```@autodocs
Modules = [HypertextTemplates, HypertextTemplates.Elements]
Private = false
```