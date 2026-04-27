func test1() {
    var d = Derived()
    var r = match (d) {
        case b: Base => b.a // Matched.
        case _ => 0
    }
    println("r = ${r}")
}
