interface NamedType {
    static func typename(): String
}

interface I <: NamedType {
    static func typename(): String {
        f()
    }
    static func f(): String
}

class A <: NamedType {
    public static func typename(): String {
        "A"
    }
}

class B <: NamedType {
    public static func typename(): String {
        "B"
    }
}

func printTypeName<T>() where T <: NamedType {
    println("the type is ${T.typename()}")
}

main() {
    printTypeName<A>() // OK
    printTypeName<B>() // OK
    printTypeName<I>() // Error, 'I' must implement all static function. Otherwise, an unimplemented 'f' is called, causing problems.
}
