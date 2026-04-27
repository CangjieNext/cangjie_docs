// specific file
package cmp

specific extend A {
    specific func foo(): Unit {}
    specific prop p: Int64 {
        get() { 1 }
    }
}