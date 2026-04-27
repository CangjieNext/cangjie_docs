// file define.cj
macro package define         // Compiling define.cjo with macro attribute
import std.ast.*

public func A() {}          // Error: Macro packages disallow externally visible non-macro definitions. This will raise an error.

public macro M(input: Tokens): Tokens { // Macro M is externally visible
    return input
}