macro package macro_definition

import std.ast.*

public macro testDef(input: Tokens): Tokens {
    println("I'm in macro body")
    return input
}