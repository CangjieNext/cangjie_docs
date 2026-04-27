interface SayHi {
    func say() {
        "hi"
    }
}

class A <: SayHi {}

class B <: SayHi {
    public func say() {
        "hi, B"
    }
}