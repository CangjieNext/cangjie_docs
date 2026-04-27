import std.random.Random

main() {
    let speed = Random().nextFloat64() * 20.0
    println("${speed} km/s")
    if (speed > 16.7) {
        println("Third cosmic velocity: Magpie Bridge Rendezvous")
    } else if (speed > 11.2) {
        println("Second cosmic velocity: Chang'e Flies to the Moon")
    } else if (speed > 7.9) {
        println("First cosmic velocity: Soaring Through Clouds")
    } else {
        println("Stay grounded, gaze at the stars")
    }
}