main() {
    try {
        throw NegativeArraySizeException("I am an Exception!")
    } catch (e: NegativeArraySizeException) {
        println(e)
        let e = 0 // Error, redefinition
        println(e)
        println("NegativeArraySizeException is caught!")
    }
    println("This will also be printed!")
}
