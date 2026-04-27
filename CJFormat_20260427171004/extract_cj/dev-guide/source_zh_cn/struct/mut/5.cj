interface I {
    mut func f1(): Unit
    func f2(): Unit
}

struct A <: I {
    public mut func f1(): Unit {} // OK: as in the interface, the 'mut' modifier is used
    public func f2(): Unit {} // OK: as in the interface, the 'mut' modifier is not used
}

struct B <: I {
    public func f1(): Unit {} // Error, 'f1' is modified with 'mut' in interface, but not in struct
    public mut func f2(): Unit {} // Error, 'f2' is not modified with 'mut' in interface, but did in struct
}

class C <: I {
    public func f1(): Unit {} // OK
    public func f2(): Unit {} // OK
}