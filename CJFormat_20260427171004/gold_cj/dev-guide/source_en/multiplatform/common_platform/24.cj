// common file
package cmp

class A{}

common extend A {
    common func foo1(a: Int64): Unit
    common func foo2(): Unit { println("common") }
    func foo3(): Unit{}
}

// specific file
package cmp

specific extend A {
    specific func foo1(a: Int64): Unit { println(a) }
    specific func foo2(): Unit { println("platform") }
    func foo4(): Int64 { 1 }
}