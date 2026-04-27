// common file
package cmp

class A {}

common extend A {
    common func foo1(a: Int64): Unit
    common func foo2(): Unit { println("common") }
    func foo3(): Unit {}
}
