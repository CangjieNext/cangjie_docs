func showFruitPrice(name: String, price: Int64) {
    println("fruit: ${name} price: ${price} yuan")
}

main() {
    let fruitPriceHandler: (name: String, price: Int64) -> Unit
    fruitPriceHandler = showFruitPrice
    fruitPriceHandler("banana", 10)
}