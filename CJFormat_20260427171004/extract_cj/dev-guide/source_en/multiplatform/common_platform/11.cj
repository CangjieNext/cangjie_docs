// common file
package cmp

common struct A {
    common var a: Int64 = 1
    common init()
    common func foo(): Unit
    common prop p: Int64
}

// specific file
package cmp

specific struct A {
    specific var a: Int64 = 2
    specific init() {}
    specific func foo(): Unit {}
    specific prop p: Int64 {
        get() { a }
    }
}