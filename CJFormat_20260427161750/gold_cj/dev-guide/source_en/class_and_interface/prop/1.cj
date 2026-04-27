class Foo {
    private var a = 0

    public mut prop b: Int64 {
        get() {
            println("get")
            a
        }
        set(value) {
            println("set")
            a = value
        }
    }
}

main() {
    var x = Foo()
    let y = x.b + 1 // get
    x.b = y // set
}
