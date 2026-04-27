@When[backend == "cjnative"]
func foo() {
    print("cjnative backend")
}

@When[backend != "cjnative"]
func foo() {
    print("not cjnative backend")
}

main() {
    foo()
}
