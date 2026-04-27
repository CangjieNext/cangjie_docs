@When[debug]
func foo() {
    println("debug")
}

@When[!debug]
func foo() {
    println("release")
}

main(args: Array<String>): Int64 {
    for (arg in args) {
        println("arg: '${arg}'")
    }
    foo()
    return 0
}
