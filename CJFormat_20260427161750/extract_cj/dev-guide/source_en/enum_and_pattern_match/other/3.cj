main() {
    let (x, y) = (100, 200)
    println("x = ${x}")
    println("y = ${y}")
    for ((i, j) in [(1, 2), (3, 4), (5, 6)]) {
        println("Sum = ${i + j}")
    }
}