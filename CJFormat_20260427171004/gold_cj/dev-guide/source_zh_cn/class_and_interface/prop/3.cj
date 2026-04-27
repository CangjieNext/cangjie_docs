class Foo {
    private var j = 0
    public mut prop i: Int64 {
        get() {
            j
        }
        set(v) {
            j = v
        }
    }
}
