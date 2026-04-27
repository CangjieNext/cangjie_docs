class A {
    func foo<T>(a: T): Unit where T <: ToString {
        println("${a}")
    }
}

struct B {
    func bar<T>(a: T): Unit where T <: ToString {
        println("${a}")
    }
}

enum C {
    | X | Y

    func coo<T>(a: T): Unit where T <: ToString {
        println("${a}")
    }
}

main() {
    var a = A()
    var b = B()
    var c = C.X
    a.foo<Int64>(10)
    b.bar<String>("abc")
    c.coo<Bool>(false)
}
