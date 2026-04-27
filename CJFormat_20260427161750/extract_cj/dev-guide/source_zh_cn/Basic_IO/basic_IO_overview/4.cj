import std.io.OutputStream
import std.io.ByteBuffer

main() {
    let output: OutputStream = ByteBuffer()
    let buf = "Hello World".toArray()
    output.write(buf)
    output.flush()
}