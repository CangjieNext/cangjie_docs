import std.io.InputStream
import std.io.ByteBuffer

main() {
    let input: InputStream = ByteBuffer("Hello World".toArray())
    let buf = Array<Byte>(256, repeat: 0)
    while (input.read(buf) > 0) {
        println(String.fromUtf8(buf))
    }
}