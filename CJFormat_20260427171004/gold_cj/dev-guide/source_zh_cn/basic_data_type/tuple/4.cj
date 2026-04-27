func getFruitPrice(): (name: String, price: Int64) {
    return ("banana", 10)
}

main() {
    let tmp = getFruitPrice()
    var a = tmp[0]
    var b = tmp[1]
    b++
    println("b = ${b}, tmp[1] = ${tmp[1]}")
}
