func test2() {
    var b = Base()
    var r = match (b) {
        case d: Derived => d.a  // Type pattern match failed.
        case _ => 0             // Matched.
    }
    println("r = ${r}")
}