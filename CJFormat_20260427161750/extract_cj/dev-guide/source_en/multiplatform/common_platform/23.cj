// common file
package cmp

class A{}

common extend A {
    common func foo(): Unit
    common prop p: Int64
}

// specific file
package cmp

specific extend A {
    specific func foo(): Unit {}
    specific prop p: Int64 {
        get() { 1 }
    }
}