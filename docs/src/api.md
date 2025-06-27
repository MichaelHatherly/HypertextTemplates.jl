# API Reference

## Public

The public API consists of all exported functions, macros, and types that are intended for end users. These APIs are stable and follow semantic versioning - breaking changes will only occur in major version updates. The public API includes the core `@render` macro, component definition utilities like `@component` and `@deftag`, security features like `SafeString`, and all the HTML element macros available through `HypertextTemplates.Elements`. These are the building blocks you'll use to create templates and components in your applications.

```@autodocs
Modules = [HypertextTemplates, HypertextTemplates.Elements]
Private = false
```

## Internal

The internal API includes implementation details, helper functions, and low-level utilities that power HypertextTemplates but are not intended for direct use. These APIs may change between minor versions without notice as we optimize performance or refactor internals. While these functions are documented for contributors and those needing to understand the implementation, you should avoid depending on them in production code. If you find yourself needing internal functionality, please open an issue - it might indicate a gap in the public API that we should address.

```@autodocs
Modules = [HypertextTemplates]
Public = false
```
