interface OutputStream {
    func write(buffer: Array<Byte>): Unit

    func flush(): Unit {
        // 空实现
    }
}
