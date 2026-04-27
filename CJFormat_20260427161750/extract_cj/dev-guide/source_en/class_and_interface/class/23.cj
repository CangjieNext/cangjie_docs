open class A {
    let a: Int64 = 10
}

class B <: A { // OK: 'B' Inheritance 'A'
    let b: Int64 = 20
}

class C <: B { // Error, 'B' is not inheritable
    let c: Int64 = 30
}