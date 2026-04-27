package pkg3

import pkg2.*

class A {
    @Prop
    private let a_: Int64 = 1
}

main() {
    let b = A()
    println("${b.a}")
}
