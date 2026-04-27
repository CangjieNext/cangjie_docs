import std.io.{ByteBuffer, StringWriter, readToEnd}

main(): Unit {
    let byteBuffer = ByteBuffer()
    let stringWriter = StringWriter(byteBuffer)

    /* Writes a string */
    stringWriter.write("number")

    /* Writes a string and automatically appends a newline */
    stringWriter.writeln(" is:")

    /* Writes a number */
    stringWriter.write(100.0f32)

    stringWriter.flush()

    println(String.fromUtf8(readToEnd(byteBuffer))) // number is:\n100.000000
}
