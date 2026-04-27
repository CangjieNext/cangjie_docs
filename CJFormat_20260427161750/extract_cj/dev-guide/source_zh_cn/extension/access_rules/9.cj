class Foo {}

extend Foo { // OK
    private func f() {}
    func g() {}
}

extend Foo { // OK
    func h() {
        g() // OK
        f() // Error
    }
}