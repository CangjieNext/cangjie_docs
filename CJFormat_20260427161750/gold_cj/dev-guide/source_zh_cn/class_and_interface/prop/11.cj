class A {
    private var value: Int64 = 0
    public mut prop i: Int64 {
        get() {
            value
        }
        set(v) {
            value = v
        }
    }
}

main() {
    var x = A()
    println(x.i) // OK
    x.i = 1 // OK
}
