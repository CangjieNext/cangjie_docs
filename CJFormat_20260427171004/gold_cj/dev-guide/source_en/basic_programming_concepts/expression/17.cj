main() {
    for (i in 0..8 where i % 2 == 1) { // Loop body executes only when i is odd
        println(i)
    }
}
