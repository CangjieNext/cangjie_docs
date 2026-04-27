// Scenario 6
open class Base {
    public func f(a: Int64): Unit {}
}

class Sub <: Base {
    public func f(a: Float64): Unit {}
}
