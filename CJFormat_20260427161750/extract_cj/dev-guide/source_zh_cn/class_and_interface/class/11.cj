func foo(x: Int64): Int64 {
    println("I'm foo, got ${x}")
    x
}

open class A {
    init() {
        println("I'm A")
    }
}

class B <: A {
    var x = foo(0)
    init() {
        x = foo(1)
        println("init B finished")
    }
}

main() {
    B()
    0
}