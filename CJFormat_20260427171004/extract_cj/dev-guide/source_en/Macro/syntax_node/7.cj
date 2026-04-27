var binExpr1 = BinaryExpr(quote(x + y))
var binExpr2 = BinaryExpr(quote($(binExpr1) * z))       // Incorrect: yields x + y * z
println("binExpr2: ${binExpr2.toTokens()}")
println("binExpr2.leftExpr: ${binExpr2.leftExpr.toTokens()}")
println("binExpr2.rightExpr: ${binExpr2.rightExpr.toTokens()}")
var binExpr3 = BinaryExpr(quote(($(binExpr1)) * z))     // Correct: yields (x + y) * z
println("binExpr3: ${binExpr3.toTokens()}")