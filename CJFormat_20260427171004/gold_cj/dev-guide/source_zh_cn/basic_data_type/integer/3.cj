main(): Unit {
    var a = b'x' // a is 120 with type UInt8
    var b = b'\n' // b is 10 with type UInt8
    var c = b'\u{78}' // c is 120 with type UInt8
    c = b'\u{90}' - b'\u{66}' + c // c is 162 with type UInt8
}
