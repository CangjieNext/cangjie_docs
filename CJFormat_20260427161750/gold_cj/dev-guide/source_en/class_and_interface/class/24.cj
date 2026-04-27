open class A {
    let a: Int64 = 10
}

open class B {
    let b: Int64 = 20
}

class C <: A & B { // Error, 'C' can only inherit one class
    let c: Int64 = 30
}
