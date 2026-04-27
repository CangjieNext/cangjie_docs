interface NamedType {
    static func typename(): String
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

main() {
    println("the type is ${ A.typename() }")
    println("the type is ${ B.typename() }")
}