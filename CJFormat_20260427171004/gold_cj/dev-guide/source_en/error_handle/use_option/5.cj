class A {
    public var b: B = B()
}

class B {
    public var c: Option<C> = C()
    public var c1: Option<C> = Option<C>.None
}

class C {
    public var d: Int64 = 100
}

main() {
    var a = Some(A())
    let a1 = a?.b.c?.d // a1 = Option<Int64>.Some(100)
    let a2 = a?.b.c1?.d // a2 = Option<Int64>.None
    a?.b.c?.d = 200 // a.b.c.d = 200
    a?.b.c1?.d = 200 // no effect
}
