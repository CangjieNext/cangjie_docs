main() {
    var root = 0.0
    var min = 1.0
    var max = 2.0
    var error = 1.0
    let tolerance = 0.1 ** 10

    while (error ** 2 > tolerance) {
        root = (min + max) / 2.0
        error = root ** 2 - 2.0
        if (error > 0.0) {
            max = root
        } else {
            min = root
        }
    }
    println("Square root of 2 ≈ ${root}")
}