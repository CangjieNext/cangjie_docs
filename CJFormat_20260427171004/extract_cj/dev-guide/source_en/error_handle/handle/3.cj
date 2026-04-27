main() {
    try {
        throw NegativeArraySizeException("NegativeArraySizeException")
    } catch (e: NegativeArraySizeException) {
        println("Exception info: ${e}.")
    } finally {
        println("The finally block is executed.")
    }
}