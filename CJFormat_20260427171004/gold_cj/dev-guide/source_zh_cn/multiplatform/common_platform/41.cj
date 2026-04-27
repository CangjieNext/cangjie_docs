// specific file
package cmp

specific enum A {
    | ELEMENT

    specific func foo1(a: Int64): Unit {
        println(a)
    }
    specific func foo3(): Unit {
        println("specific")
    }
    func foo5(): Int64 {
        1
    }
}
