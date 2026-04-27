import std.env.getStdIn

main() {
    let consoleReader = getStdIn()
    let txt = consoleReader.readln()
    println(txt ?? "")
}