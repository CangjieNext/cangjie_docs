open class Base {}
class Sub <: Base {}

interface I {
    func f(): Base
}

class C <: I {
    public func f(): Sub {
        Sub()
    }
}