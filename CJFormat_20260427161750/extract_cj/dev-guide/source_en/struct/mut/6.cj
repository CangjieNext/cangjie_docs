interface I {
    mut func f(): Unit
}
struct Foo <: I {
    public var v = 0
    public mut func f(): Unit {
        v += 1
    }
}
main() {
    var a = Foo()
    var b: I = a  
    b.f()  // Calling 'f' via 'b' cannot modify the value of 'a'
    println(a.v) // 0
}