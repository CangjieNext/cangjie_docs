// common file
package cmp

class A {}

common extend A {
    common prop a: Int64
    common prop b: Int64 {
        get() { 1 }
    }
    prop c: Int64 {
        get() { 1 }
    }
}