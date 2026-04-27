main(): Int64 {
    var a: Int64
    var b: Int64
    (a, b) = (1, 2) // a = 1, b = 2
    (a, b) = (b, a) // 交换, a = 2, b = 1
    (a, _) = (3, 4) // a = 3
    (_, _) = (5, 6) // 无赋值
    return 0
}