import std.ast.*

let tks = Tokens([
    Token(TokenKind.INTEGER_LITERAL, "1"),
    Token(TokenKind.ADD),
    Token(TokenKind.INTEGER_LITERAL, "2")
])
main() {
    println(tks)
    tks.dump()
}