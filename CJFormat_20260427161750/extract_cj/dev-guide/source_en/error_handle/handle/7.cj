interface Resource {
    func isClosed(): Bool // Determines whether the `close` function should be called to release resources when exiting the try-with-resources scope.
    func close(): Unit // Releases resources when `isClosed` returns false.
}