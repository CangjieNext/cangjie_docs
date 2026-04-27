@C
struct Data {
    var a: Int64 = 0
    var b: Float32 = 0.0
}

main() {
    println(sizeOf<Data>())
    println(alignOf<Data>())
}
