macro package C

public import A.* // correct: macro package is allowed to re-export in a macro package.
public import B.* // correct: non-macro package is also allowed to re-export in a macro package.
import std.ast.*

public macro M2(input: Tokens): Tokens {
    return @M1(input) + Token(TokenKind.NL) + quote(f1(1))
}
