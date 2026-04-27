macro package define

import std.ast.*

public macro Outer(input: Tokens): Tokens {
    return input
}

public macro Inner(input: Tokens): Tokens {
    assertParentContext("Outer")
    return input
}
