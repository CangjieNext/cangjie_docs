main() {
    try {
        throw NegativeArraySizeException("I am an Exception!")
    } catch (e: NegativeArraySizeException) {
        println(e)
        println("NegativeArraySizeException is caught!")
    }
    println("This will also be printed!")
}