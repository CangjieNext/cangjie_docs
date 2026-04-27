import std.env.getStdOut

main() {
    let consoleWriter = getStdOut()
    for (_ in 0..1000) {
        consoleWriter.writeln("hello, world!")
    }
    consoleWriter.flush()
}
