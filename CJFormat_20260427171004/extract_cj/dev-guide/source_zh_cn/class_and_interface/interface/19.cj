interface SayHi {
    func say() {
        "hi"
    }
}

interface SayHello {
    func say() {
        "hello"
    }
}

class Foo <: SayHi & SayHello {
    public func say() {
        "Foo"
    }
}