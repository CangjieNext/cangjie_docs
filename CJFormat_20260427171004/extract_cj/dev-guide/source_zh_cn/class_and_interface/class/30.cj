open class A {
    A(let a: Int64) {}
}

class B <: A {
    let b: Int64
    init(b: Int64) {
        super(30)
        this.b = b
    }

    init() {
        this(20)
    }
}