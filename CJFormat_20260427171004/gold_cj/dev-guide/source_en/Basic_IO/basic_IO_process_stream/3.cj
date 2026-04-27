import std.io.{ByteBuffer, BufferedOutputStream, readToEnd}

main(): Unit {
    let arr1 = "01234".toArray()
    let byteBuffer = ByteBuffer()
    byteBuffer.write(arr1)
    let bufferedOutputStream = BufferedOutputStream(byteBuffer)
    let arr2 = "56789".toArray()

    /* Writes data to the stream; the data remains in the external stream's buffer */
    bufferedOutputStream.write(arr2)

    /* Calls the flush function to finally write the data to the internal stream */
    bufferedOutputStream.flush()
    println(String.fromUtf8(readToEnd(byteBuffer))) // 0123456789
}
