open class A {
    let a: Int64 = 10
}

class B <: A {
    let b: Int64 = 20
}

let b: B = A() // Error, superclass objects can not be assigned to subclass variables