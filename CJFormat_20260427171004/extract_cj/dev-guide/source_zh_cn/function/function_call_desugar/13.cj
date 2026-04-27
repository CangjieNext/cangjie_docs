func length(arr!: Array<Int64>) {
    return arr.size
}

main() {
    println(length())        // Error, expected 1 argument, found 0
    println(length(1, 2, 3)) // Error, expected 1 argument, found 3
}