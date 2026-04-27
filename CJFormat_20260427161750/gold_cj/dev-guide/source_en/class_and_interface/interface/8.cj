interface NamedType {
    static func typename(): String {
        "interface NamedType"
    }
}

class A <: NamedType {}

main() {
    println(NamedType.typename())
    println(A.typename())
}
