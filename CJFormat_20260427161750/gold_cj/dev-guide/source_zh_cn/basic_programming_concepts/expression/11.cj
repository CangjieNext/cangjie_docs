import std.random.Random

main() {
    let random = Random()
    var totalPoints = 0
    var hitPoints = 0

    do {
        // 在 ((0, 0), (1, 1)) 这个正方形中随机取点
        let x = random.nextFloat64()
        let y = random.nextFloat64()
        // 判断是否落在正方形内接圆里
        if ((x - 0.5) ** 2 + (y - 0.5) ** 2 < 0.25) {
            hitPoints++
        }
        totalPoints++
    } while (totalPoints < 1000000)

    let pi = 4.0 * Float64(hitPoints) / Float64(totalPoints)
    println("圆周率近似值为：${pi}")
}
