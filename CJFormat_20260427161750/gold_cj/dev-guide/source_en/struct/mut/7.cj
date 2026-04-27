interface I {
    mut func f(): Unit
}

struct Foo <: I {
    public var i = 0
    public mut func f(): Unit {
        i += 1
    }
}

main() {
    let a = Foo()
    a.f() // Error, 'a' is of type struct and is declared with 'let', the 'mut' function cannot be accessed via 'a'
    var b = Foo()
    b.f() // OK
    let c: I = Foo()
    c.f() // OK, variable 'c' is of interface type I, not struct type, so access is permitted here.
}
