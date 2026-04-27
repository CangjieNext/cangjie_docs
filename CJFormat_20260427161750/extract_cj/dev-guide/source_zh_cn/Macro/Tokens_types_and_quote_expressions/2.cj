import std.ast.*

let tk1 = Token(TokenKind.ADD)   // '+' 运算符
let tk2 = Token(TokenKind.FUNC)   // func 关键字
let tk3 = Token(TokenKind.IDENTIFIER, "x")   // x 标识符
let tk4 = Token(TokenKind.INTEGER_LITERAL, "3")  // 整数字面量
let tk5 = Token(TokenKind.STRING_LITERAL, "xyz")  // 字符串字面量