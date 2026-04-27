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

interface I {
    func doo<T>(a: T): Unit where T <: ToString
}

class D <: I {
    public func doo<T>(a: T): Unit where T <: ToString {
        println("${a}")
    }
}

abstract class E {
    public func eoo1<T>(a: T): Unit where T <: ToString
    public open func eoo2<T>(a: T): Unit where T <: ToString
}

class F <: E {
    public func eoo1<T>(a: T): Unit where T <: ToString {
        println("${a}")
    }
    public func eoo2<T>(a: T): Unit where T <: ToString {
        println("${a}")
    }
}

main() {
    var a = A()
    var b = B()
    var c = C.X
    var d = D()
    var f = F()
    a.foo<Int64>(10)
    b.bar<String>("abc")
    c.coo<Bool>(false)
    d.doo<String>("doo")
    f.eoo1<String>("eoo1")
    f.eoo2<String>("eoo2")
    return 0
}
