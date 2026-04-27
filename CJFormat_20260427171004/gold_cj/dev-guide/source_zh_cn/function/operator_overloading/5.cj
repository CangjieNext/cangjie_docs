open class A {
    public init() {}

    public operator func ()(): Unit {}
}

func test1() {
    let a = A() // OK, A() is call the constructor of A
    a() // OK, a() is to call the operator () overloading function
}
