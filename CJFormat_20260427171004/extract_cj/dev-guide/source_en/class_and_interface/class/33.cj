open class C {
    public static func foo(): Unit {
        println("I am class C")
    }
}

class D <: C {
    public redef static func foo(): Unit {
        println("I am class D")
    }
}

main() {
    C.foo()
    D.foo()
}