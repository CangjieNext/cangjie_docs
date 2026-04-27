let tks1 = quote(a + b)
let tks2 = quote(u + v, x + y)
let tks3 = quote(
    func f1(x: Int64) { return x + 1 }
)
let tks4 = quote(
    func f2(x: Int64) { return x + 2 }
    func f3(x: Int64) { return x + 3 }
)

let binExpr1 = parseExpr(tks1)
let (binExpr2, mid) = parseExprFragment(tks2)
let (binExpr3, _) = parseExprFragment(tks2, startFrom: mid + 1) // Skip the comma
println("binExpr1 = ${binExpr1.toTokens()}")
println("binExpr2 = ${binExpr2.toTokens()}, binExpr3 = ${binExpr3.toTokens()}")
let funcDecl1 = parseDecl(tks3)
let (funcDecl2, mid2) = parseDeclFragment(tks4)
let (funcDecl3, _) = parseDeclFragment(tks4, startFrom: mid2)
println("${funcDecl1.toTokens()}")
println("${funcDecl2.toTokens()}")
println("${funcDecl3.toTokens()}")