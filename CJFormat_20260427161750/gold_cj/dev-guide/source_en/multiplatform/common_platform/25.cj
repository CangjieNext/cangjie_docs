// common file
package cmp

class A{}

common extend A {
    common prop a: Int64
    common prop b: Int64 {
        get() { 1 }
    }
    prop c: Int64{
        get() { 1 }
    }
}

// specific file
package cmp

specific extend A {
    specific prop a: Int64 {
        get() { 1 }
    }
    specific prop b: Int64 {
        get() { 2 }
    }
    prop d: Int64 {
        get() { 1 }
    }
}