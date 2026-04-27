@When[arch == "aarch64"]
var arch = "aarch64"

@When[arch == "x86_64"]
var arch = "x86_64"

main() {
    println(arch)
}