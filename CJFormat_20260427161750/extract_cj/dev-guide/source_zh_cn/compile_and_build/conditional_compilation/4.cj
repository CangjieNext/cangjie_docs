@When[os == "Linux"]
func foo() {
    print("Linux, ")
}
@When[os == "Windows"]
func foo() {
    print("Windows, ")
}
@When[os != "Windows"]
func fee() {
    println("NOT Windows")
}
@When[os != "Linux"]
func fee() {
    println("NOT Linux")
}
main() {
    foo()
    fee()
}