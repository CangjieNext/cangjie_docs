func add(a: Int64, b!: Int64 = 2) {
    return a + b
}

main() {
    let x = 1
    let r = add(x, b: 20)
    println("The sum of x and y is ${r}")
}