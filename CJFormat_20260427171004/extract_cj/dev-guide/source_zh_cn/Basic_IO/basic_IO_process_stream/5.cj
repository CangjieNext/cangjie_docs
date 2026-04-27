import std.io.{ByteBuffer, StringReader}

main(): Unit {
    let arr1 = "012\n346789".toArray()
    let byteBuffer = ByteBuffer()
    byteBuffer.write(arr1)
    let stringReader = StringReader(byteBuffer)

    /* 读取一行数据 */
    let line = stringReader.readln()
    println(line ?? "error") // 012
}