import std.io.InputStream

main() {
    let input: InputStream = ...
    let buf = Array<Byte>(256, repeat: 0)
    while (input.read(buf) > 0) {
        println(buf)
    }
}