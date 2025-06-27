# API Reference

## Public

The public API consists of all exported functions, macros, and types that are intended for end users. These APIs are stable and follow semantic versioning - breaking changes will only occur in major version updates. The public API includes the core `@render` macro, component definition utilities like `@component` and `@deftag`, security features like `SafeString`, and all the HTML element macros available through `HypertextTemplates.Elements`. These are the building blocks you'll use to create templates and components in your applications.

```@autodocs
Modules = [HypertextTemplates, HypertextTemplates.Elements]
Private = false
```

## Library Components

The Library module provides a comprehensive set of pre-built UI components styled with Tailwind CSS. These components are designed to be accessible, responsive, and work seamlessly with dark mode. All components follow consistent design patterns and can be customized through props while maintaining sensible defaults.

```@autodocs
Modules = [HypertextTemplates.Library]
Private = false
Order = [:macro, :function]
```

## Internal

The internal API includes implementation details, helper functions, and low-level utilities that power HypertextTemplates but are not intended for direct use. These APIs may change between minor versions without notice as we optimize performance or refactor internals. While these functions are documented for contributors and those needing to understand the implementation, you should avoid depending on them in production code. If you find yourself needing internal functionality, please open an issue - it might indicate a gap in the public API that we should address.

```@autodocs
Modules = [HypertextTemplates]
Public = false
```
