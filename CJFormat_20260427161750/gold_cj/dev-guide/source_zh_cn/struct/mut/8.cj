interface I {
    mut func f(): Unit
}

struct Foo <: I {
    var i = 0

    public mut func f(): Unit {
        i += 1
    }
}

main() {
    var a = Foo()
    var fn = a.f // Error, mut function 'f' of 'a' cannot be used as a first class citizen.
    var b: I = Foo()
    fn = b.f // OK
}
