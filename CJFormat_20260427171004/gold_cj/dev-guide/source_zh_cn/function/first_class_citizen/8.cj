func add(a: Int64, b: Int64): Int64 {
    a + b
}

func returnAdd(): (Int64, Int64) -> Int64 {
    add
}

main() {
    var a = returnAdd()
    println(a(1, 2))
}
