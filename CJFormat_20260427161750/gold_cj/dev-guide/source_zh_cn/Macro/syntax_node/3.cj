let binExpr = BinaryExpr(quote(x * y))
binExpr.leftExpr = BinaryExpr(quote(a + b))
println(binExpr.toTokens())

binExpr.op = Token(TokenKind.ADD)
println(binExpr.toTokens())