class A {
    private let value = 0
    public prop i: Int64 {
        get() {
            value
        }
    }
}

main() {
    var x = A()
    println(x.i) // OK
    x.i = 1 // Error
}
