func h() {
    func f() {
        var x = 1
        func g() {
            x
        } // captured a mutable variable

        g()
    }
    return f // OK
}
