macro package C

public import A.* // Correct: Macro packages allow re-exporting within a macro package.
public import B.* // Correct: Non-macro packages are also allowed to be re-exported in a macro package.
import std.ast.*

public macro M2(input: Tokens): Tokens {
    return @M1(input) + Token(TokenKind.NL) + quote(f1(1))
}
