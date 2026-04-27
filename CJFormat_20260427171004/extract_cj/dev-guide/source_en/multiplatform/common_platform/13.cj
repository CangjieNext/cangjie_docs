// common file
package cmp

common struct A {
    common let a: Int64 = 1
    common var b: Int64
    common var c: Int64

    init() {
        b = 1
        c = 1
    }
}

// specific file
package cmp

specific struct A {
    specific let a: Int64 = 2
    specific let b: Int64 = 2

    init(input: Int64) { c = input }
}