package pkg3

import pkg1.*
import pkg2.*
@Foo
struct Data {
    let a = 2
    let b = @addToMul(2+3)

    @Bar
    public func getA() {
        return a
    }

    public func getB() {
        return b
    }
}

main(): Int64 {
    let data = Data()
    var a = data.getA() // a = 2
    var b = data.getB() // b = 6
    println("a: ${a}, b: ${b}")
    return 0
}