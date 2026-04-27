import std.ast.*

let binExpr = BinaryExpr(quote(a + b))
let funcDecl = FuncDecl(quote(func f1(x: Int64) { return x + 1 }))