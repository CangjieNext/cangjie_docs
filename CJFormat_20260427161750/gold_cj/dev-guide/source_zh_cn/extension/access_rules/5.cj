class A {
    var v = 0
}

extend A {
    func f() {
        print(this.v) // OK
        print(v) // OK
    }
}
