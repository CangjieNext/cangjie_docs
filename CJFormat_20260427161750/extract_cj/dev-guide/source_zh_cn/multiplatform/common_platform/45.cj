// specific file
package cmp

specific interface A {
    specific func foo(): Unit {}
    specific prop p: Int64 {
        get() { 1 }
    }
}