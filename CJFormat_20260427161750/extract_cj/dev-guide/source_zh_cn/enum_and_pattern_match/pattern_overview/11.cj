open class Base {
    var a: Int64
    public init() {
        a = 10
    }
}

class Derived <: Base {
    public init() {
        a = 20
    }
}