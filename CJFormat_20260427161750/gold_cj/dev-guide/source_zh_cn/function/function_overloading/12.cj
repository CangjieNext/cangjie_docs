open class Base {
    public func g(a: Sub) {
        print("1")
    }
}

class Sub <: Base {
    public func g(a: Base) {
        print("2")
    }
}

func outer() {
    let s: Sub = Sub()
    s.g(Sub()) // Output: 1
}
