struct Foo {
    var i = 0

    public mut func f(): Unit {
        i += 1
        g() // OK
    }

    public func g(): Unit {
        f() // Error, mut functions cannot be invoked in non-mut functions
    }
}

interface I {
    mut func f(): Unit {
        g() // OK
    }

    func g(): Unit {
        f() // Error, mut functions cannot be invoked in non-mut functions
    }
}
