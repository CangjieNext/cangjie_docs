main(): Int64 {
    var a: Int64
    var b: Int64
    (a, b) = (1, 2) // a = 1, b = 2
    (a, b) = (b, a) // Swap: a = 2, b = 1
    (a, _) = (3, 4) // a = 3
    (_, _) = (5, 6) // No assignment
    return 0
}
