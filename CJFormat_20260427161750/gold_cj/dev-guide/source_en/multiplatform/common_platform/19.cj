// common file
package cmp

common enum A {
    | ELEMENT

    common prop a: Int64
    common prop b: Int64 {
        get() { 1 }
    }
    common prop c: Int64 {
        get() { 1 }
    }
    prop d: Int64 {
        get() { 1 }
    }
}

// specific file
package cmp

specific enum A {
    | ELEMENT

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