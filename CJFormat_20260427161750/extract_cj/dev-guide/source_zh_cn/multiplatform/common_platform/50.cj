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