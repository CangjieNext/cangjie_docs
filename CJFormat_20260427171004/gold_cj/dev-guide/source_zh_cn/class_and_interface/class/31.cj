open class A {
    let a: Int64
    init() {
        a = 100
    }
}

open class B <: A {
    let b: Int64
    init(b: Int64) {
        // OK, `super()` added by compiler
        this.b = b
    }
}

open class C <: B {
    let c: Int64
    init(c: Int64) { // Error, there is no non-parameter constructor in super class
        this.c = c
    }
}
