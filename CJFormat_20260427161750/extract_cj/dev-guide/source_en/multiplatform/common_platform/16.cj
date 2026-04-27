// common file
package cmp

common enum A {
    | ELEMENT
    common func foo(): Unit
    common prop p: Int64
}

// specific file
package cmp

specific enum A {
    | ELEMENT
    specific func foo(): Unit {}
    specific prop p: Int64 {
        get() { 1 }
    }
}