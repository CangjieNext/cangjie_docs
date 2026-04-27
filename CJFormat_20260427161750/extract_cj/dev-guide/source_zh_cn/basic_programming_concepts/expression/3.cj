import std.random.Random

main() {
    let speed = Random().nextFloat64() * 20.0
    println("${speed} km/s")
    if (speed > 16.7) {
        println("第三宇宙速度，鹊桥相会")
    } else if (speed > 11.2) {
        println("第二宇宙速度，嫦娥奔月")
    } else if (speed > 7.9) {
        println("第一宇宙速度，腾云驾雾")
    } else {
        println("脚踏实地，仰望星空")
    }
}