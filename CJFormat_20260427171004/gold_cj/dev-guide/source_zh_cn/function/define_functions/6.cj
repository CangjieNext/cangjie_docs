func add(a: Int64, b: Int64): Int64 {
    var a_ = a // OK
    var b = b // Error, redefinition of declaration 'b'
    return a
}
