interface I1 {
    func foo() {}
}

interface I2 {
    func foo() {}
}

class A {}

extend A <: I1 {} // Error, multiple default implementations, need to re-implement 'foo' in 'A'

extend A <: I2 {} // Error, multiple default implementations, need to re-implement 'foo' in 'A'
