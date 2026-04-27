// common file
package cmp

common struct A {
    common func foo1(a: Int64): Unit
    common func foo2(): Unit {}
    common func foo3(): Unit {}
    func foo4() {}
}

// specific file
package cmp

specific struct A {
    specific func foo1(a: Int64): Unit { println(a) }
    specific func foo3(): Unit { println("platform") }
    func foo5(): Int64 { 1 }

    init() {}
}