interface I1 {
    func foo(): Unit {
        println("I1 foo")
    }
}

interface I2 <: I1 {
    func foo(): Unit {
        println("I2 foo")
    }
}

class A {}

extend A <: I1 {} // first check

extend A <: I2 {} // second check

main() {
    A().foo()
}
