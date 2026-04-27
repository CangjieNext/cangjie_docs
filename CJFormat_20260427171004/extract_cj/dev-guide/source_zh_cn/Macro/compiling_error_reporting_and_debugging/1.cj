// macros/m.cj
// In this file, we define the macro Inner, Outer.
macro package define
import std.ast.*

public macro Inner(input: Tokens) {
    return input
}

public macro Outer(input: Tokens) {
    return input
}
