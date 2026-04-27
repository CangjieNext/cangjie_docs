enum Expr {
    | Num(Int64)
    | Add(Expr, Expr)
    | Sub(Expr, Expr)
}