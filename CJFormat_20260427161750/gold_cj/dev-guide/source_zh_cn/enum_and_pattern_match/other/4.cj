enum RedColor {
    Red(Int64)
}

main() {
    let Red(red) = Red(0)
    println("red = ${red}")
    for (Red(r) in [Red(10), Red(20), Red(30)]) {
        println("r = ${r}")
    }
}
