interface NamedType {
    static func typename(): String
}
main() {
    NamedType.typename() // Error
}