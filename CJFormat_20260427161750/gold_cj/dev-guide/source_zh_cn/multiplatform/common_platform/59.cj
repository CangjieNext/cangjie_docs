// specific file
package cmp

specific extend A {
    specific func foo1(a: Int64): Unit {
        println(a)
    }
    specific func foo2(): Unit {
        println("specific")
    }
    func foo4(): Int64 {
        1
    }
}
