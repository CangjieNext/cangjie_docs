open class A {
    public open func f(a!: Int32): Int32 {
        a + 1
    }
}

class B <: A {
    public override func f(a!: Int32): Int32 { // OK
        a + 2
    }
}

class C <: A {
    public override func f(b!: Int32): Int32 { // Error
        b + 3
    }
}

main() {
    B().f(a: 0)
    C().f(b: 0)
}