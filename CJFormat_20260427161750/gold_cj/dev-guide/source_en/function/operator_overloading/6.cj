open class A {
    public init() {}
    public init(x: Int64) {
        this() // OK, this() calls the constructor of A
    }

    public operator func ()(): Unit {}

    public func foo() {
        this() // Error, this() calls the constructor of A.
        super() // Error
    }
}

class B <: A {
    public init() {
        super() // OK, super()  calls the constuctor of the super class
    }

    public func goo() {
        super() // Error
    }
}
