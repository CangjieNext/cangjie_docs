struct Foo {
    var i = 0

    public mut func g() {
        i += 1 // OK
    }
}
