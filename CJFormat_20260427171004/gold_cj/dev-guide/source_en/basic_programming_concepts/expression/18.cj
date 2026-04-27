main() {
    let numbers = [12, 18, 25, 36, 49, 55]
    for (number in numbers) {
        if (number % 5 == 0) {
            println(number)
            break
        }
    }
}
