interface OutputStream {
    func write(buffer: Array<Byte>): Unit

    func flush(): Unit {
        // Empty implementation
    }
}