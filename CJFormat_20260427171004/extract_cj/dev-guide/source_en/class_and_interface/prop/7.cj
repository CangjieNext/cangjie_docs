interface I {
    prop a: Int64
    mut prop b: Int64
}
class C <: I {
    private var value = 0

    public prop a: Int64 {
        get() { value }
    }

    public mut prop b: Int64 {
        get() { value }
        set(v) {
            value = v
        }
    }
}