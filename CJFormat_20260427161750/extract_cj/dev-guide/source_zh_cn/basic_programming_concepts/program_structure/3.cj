main() {
    let a: Int64
    var b: Int64 = 14
    const c: Int64 = 13
    b = 12
    a = b // A variable modified by let can only be assigned once, that is, initialized
    println("${a}, ${b}, ${c}")
}