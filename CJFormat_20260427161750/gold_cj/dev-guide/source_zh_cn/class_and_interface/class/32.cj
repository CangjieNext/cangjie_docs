open class A {
    public open func f(): Unit {
        println("I am superclass")
    }
}

class B <: A {
    public override func f(): Unit {
        println("I am subclass")
    }
}

main() {
    let a: A = A()
    let b: A = B()
    a.f()
    b.f()
}
