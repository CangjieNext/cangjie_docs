@When[debug]
func foo() {
    println("debug")
}

@When[!debug]
func foo() {
    println("NOT debug")
}

main() {
    foo()
}
