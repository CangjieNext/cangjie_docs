import stdx.effect.Command

// Define a Command named GetNumber
class GetNumber <: Command<Int64> {}

main() {
    try {
        println("About to perform")

        // Perform the GetNumber effect
        let a = perform GetNumber()

        // Execution resumes here after handler
        println("It is resumed, a = ${a}")
    } handle(e: GetNumber) {
        // Handle the GetNumber effect
        println("It is performed")

        // Resume execution, injecting value 9
        resume with 9
    }
    0
}