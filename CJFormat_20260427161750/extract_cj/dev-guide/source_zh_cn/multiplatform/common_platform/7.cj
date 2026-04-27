// specific file
package cmp

specific class A {
    specific var a: Int64 = 2
    specific init() {}
    specific func foo(): Unit {}
    specific prop p: Int64 {
        get() { a }
    }
}