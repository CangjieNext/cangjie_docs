// specific file
package cmp

specific enum A {
    | ELEMENT
    specific func foo(): Unit {}
    specific prop p: Int64 {
        get() { 1 }
    }
}