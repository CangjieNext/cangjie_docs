import std.random.Random

main() {
    let random = Random()
    var totalPoints = 0
    var hitPoints = 0

    do {
        // Randomly sample points within the square ((0, 0), (1, 1))
        let x = random.nextFloat64()
        let y = random.nextFloat64()
        // Determine if the point falls within the inscribed circle
        if ((x - 0.5) ** 2 + (y - 0.5) ** 2 < 0.25) {
            hitPoints++
        }
        totalPoints++
    } while (totalPoints < 1000000)

    let pi = 4.0 * Float64(hitPoints) / Float64(totalPoints)
    println("Approximate value of pi: ${pi}")
}
