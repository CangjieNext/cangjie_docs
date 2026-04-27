func h() {
    var x = 1

    func g() {
        x
    } // captured a mutable variable

    func f() {
        g() // invoked g
    }
    return f // Error
}
