macro package A

import std.ast.*

public macro M1(input: Tokens): Tokens {
    return input
}
