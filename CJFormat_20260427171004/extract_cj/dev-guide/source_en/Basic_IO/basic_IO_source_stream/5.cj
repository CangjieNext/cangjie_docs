import std.fs.exists

main() {
    let exist = exists("./tempFile.txt")
    println("exist: ${exist}")
}