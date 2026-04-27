// common file
package cmp

common interface A {
    common prop a: Int64
    common prop b: Int64
    common prop c: Int64 {
        get() { 1 }
    }
    prop d: Int64
}

// specific file
package cmp

specific interface A {
    specific prop a: Int64 {
        get() { 1 }
    }
    specific prop c: Int64 {
        get() { 2 }
    }
    prop e: Int64 {
        get() { 1 }
    }
}