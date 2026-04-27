@When[os == "Linux" && arch == "aarch64" && env == "android"]
func foo() {
    "target aarch64-linux-android31 run"
}

main() {
    println(foo())
}