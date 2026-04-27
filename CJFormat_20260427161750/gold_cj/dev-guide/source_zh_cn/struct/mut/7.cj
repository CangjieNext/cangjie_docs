interface I {
    mut func f(): Unit
}

struct Foo <: I {
    public var i = 0
    public mut func f(): Unit {
        i += 1
    }
}

main() {
    let a = Foo()
    a.f() // Error, 'a' is of type struct and is declared with 'let', the 'mut' function cannot be accessed via 'a'
    var b = Foo()
    b.f() // OK
    let c: I = Foo()
    c.f() // OK, 变量 c 为接口 I 类型，非 struct 类型，此处允许访问。
}
