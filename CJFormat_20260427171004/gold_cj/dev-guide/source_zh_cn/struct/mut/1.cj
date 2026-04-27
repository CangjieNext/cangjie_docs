struct Foo {
    var i = 0

    public func g() {
        i += 1 // Error, the value of a instance member variable cannot be modified in an instance member function
    }
}
