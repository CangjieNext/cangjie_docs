interface PrintSizeable {
    func printSize(): Unit
}

extend<T> Array<T> <: PrintSizeable {
    public func printSize() {
        println("The size is ${this.size}")
    }
}
