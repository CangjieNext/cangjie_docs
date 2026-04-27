@When[cjc_version == "0.18.6"]
func foo() {
    println("cjc_version equals 0.18.6")
}
@When[cjc_version != "0.18.6"]
func foo() {
    println("cjc_version is NOT equal to 0.18.6")
}
@When[cjc_version > "0.18.6"]
func fnn() {
    println("cjc_version is greater than 0.18.6")
}
@When[cjc_version <= "0.18.6"]
func fnn() {
    println("cjc_version is less than or equal to 0.18.6")
}
@When[cjc_version < "0.18.6"]
func fee() {
    println("cjc_version is less than 0.18.6")
}
@When[cjc_version >= "0.18.6"]
func fee() {
    println("cjc_version is greater than or equal to 0.18.6")
}
main() {
    foo()
    fnn()
    fee()
}