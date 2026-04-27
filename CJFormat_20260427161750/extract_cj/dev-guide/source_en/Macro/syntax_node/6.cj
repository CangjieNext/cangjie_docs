var incrs = ArrayList<Node>()
for (i in 1..=5) {
    incrs.add(parseExpr(quote(x += $(i))))
}
var foo = quote(
    func foo(n: Int64) {
        let x = n
        $(incrs)
        x
    })
println(foo)