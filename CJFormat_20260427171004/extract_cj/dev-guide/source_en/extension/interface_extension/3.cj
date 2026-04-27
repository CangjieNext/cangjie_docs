interface I1 {
    func f1(): Unit
}

interface I2 {
    func f2(): Unit
}

interface I3 {
    func f3(): Unit
}

class Foo {}

extend Foo <: I1 & I2 & I3 {
    public func f1(): Unit {}
    public func f2(): Unit {}
    public func f3(): Unit {}
}