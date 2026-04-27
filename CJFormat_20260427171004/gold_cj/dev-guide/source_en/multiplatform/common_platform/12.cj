// common file
package cmp

common struct A {
    common init(a: String) {}
    init(a: Bool) {}
}

// specific file
package cmp

specific struct A {
    specific init(a: String) {
        println(a)
    }
    init(a: Int64) {}
}