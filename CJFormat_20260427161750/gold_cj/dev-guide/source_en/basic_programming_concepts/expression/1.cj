import std.random.Random

main() {
    let number: Int8 = Random().nextInt8()
    println(number)
    if (number % 2 == 0) {
        println("Even")
    } else {
        println("Odd")
    }
}
