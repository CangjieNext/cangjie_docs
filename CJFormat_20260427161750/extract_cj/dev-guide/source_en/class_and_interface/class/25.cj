open class A {
    let a: Int64 = 10
}
class B <: A {
    let b: Int64 = 20
}

let a: A = B() // OK: subclass objects can be assigned to superclass variables