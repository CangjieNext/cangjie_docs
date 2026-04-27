func f() {
    var x = 1
    let y = 2

    func g() {
        println(x) // OK, captured a mutable variable.
    }
    let b = g // Error, g cannot be assigned to a variable

    g // Error, g cannot be used as an expression
    g() // OK, g can be invoked

    g // Error, g cannot be used as a return value
}
