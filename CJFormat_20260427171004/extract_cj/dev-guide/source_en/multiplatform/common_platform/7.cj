// common file
package cmp

common class A {
    common A()
    common init(a: String) {}
    init(a: Bool) {}
}

// specific file
package cmp

specific class A {
    specific A() {}
    specific init(a: String) {
        println(a)
    }
    init(a: Int64) {}
}