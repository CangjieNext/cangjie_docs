import std.io.{ByteBuffer, BufferedInputStream}

main(): Unit {
    let arr1 = "0123456789".toArray()
    let byteBuffer = ByteBuffer()
    byteBuffer.write(arr1)
    let bufferedInputStream = BufferedInputStream(byteBuffer)
    let arr2 = Array<Byte>(20, repeat: 0)

    /* Reads data from the stream and returns the length of the data read */
    let readLen = bufferedInputStream.read(arr2)
    println(String.fromUtf8(arr2[..readLen])) // 0123456789
}
