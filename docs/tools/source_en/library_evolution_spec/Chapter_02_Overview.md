# Overview

## Objectives and Scope

This specification defines the conditions under which code modifications to a Cangjie module (the smallest release unit of Cangjie) can provide compatibility guarantees to downstream users, specifically divided into:

1. API compatibility: After the modification, downstream code can be recompiled and complete normally.
2. ABI compatibility: On top of API compatibility, further ensures that downstream code can be directly re-linked without recompilation.

Note that, referring to industry standards and practices,

1. Symbol conflicts or function overload resolution failures caused by adding new APIs in the current module (note: including adding global variables, adding global functions, adding custom types, adding extensions, adding parent classes and parent interfaces to existing types, and deleting and relaxing generic constraints in existing extensions) with downstream code are not considered API compatibility breaks.
2. Cangjie supports FFI operations. Linking failures caused by name conflicts between newly added dependencies on foreign functions and foreign functions depended upon by other modules are not considered ABI compatibility breaks.

This specification also serves as the implementation specification document for CJCOMPAT (note: the compatibility check supporting tool provided in the Cangjie toolchain).

Before referring to this specification, you are expected to have the corresponding basic knowledge of the Cangjie language.

In particular,

1. Since macros and conditional compilation features can be used in Cangjie, both of which can cause differences between the code actually participating in compilation and the source code. Therefore, the compatibility rules introduced in this document are all based on the code after macro expansion and conditional compilation processing as the determination basis.
2. Since Cangjie supports automatic type inference, the types involved in this document are all based on the type results after automatic type inference is completed as the determination basis.
