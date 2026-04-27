main() {
    for (i in 0..5) {
        i = i * 10 // Error: Cannot assign to an initialized `let` constant
        println(i)
    }
}