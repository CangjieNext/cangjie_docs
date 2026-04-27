open class Base {
    var name: String = "Alice"
}

class Derived <: Base {
    var age: UInt8 = 18
}

main() {
    let a = 1 is Int64
    println("Is the type of 1 'Int64'? ${a}")
    let b = 1 is String
    println("Is the type of 1 'String'? ${b}")

    let b1: Base = Base()
    let b2: Base = Derived()
    var x = b1 is Base
    println("Is the type of b1 'Base'? ${x}")
    x = b1 is Derived
    println("Is the type of b1 'Derived'? ${x}")
    x = b2 is Base
    println("Is the type of b2 'Base'? ${x}")
    x = b2 is Derived
    println("Is the type of b2 'Derived'? ${x}")
}
