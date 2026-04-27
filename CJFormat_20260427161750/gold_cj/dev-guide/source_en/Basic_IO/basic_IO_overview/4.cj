import std.io.OutputStream

main() {
    let output: OutputStream = ...
    let buf = Array<Byte>(256, repeat: 111)
    output.write(buf)
    output.flush()
}