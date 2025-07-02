# Internal API

The internal API includes implementation details, helper functions, and low-level utilities that power HypertextTemplates but are not intended for direct use. These APIs may change between minor versions without notice as we optimize performance or refactor internals. While these functions are documented for contributors and those needing to understand the implementation, you should avoid depending on them in production code. If you find yourself needing internal functionality, please open an issue - it might indicate a gap in the public API that we should address.

```@autodocs
Modules = [HypertextTemplates]
Public = false
```