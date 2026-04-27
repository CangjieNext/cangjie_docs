class A {
    private var v1 = 0
    protected var v2 = 0
}

extend A {
    func f() {
        print(v1) // Error
        print(v2) // OK
    }
}