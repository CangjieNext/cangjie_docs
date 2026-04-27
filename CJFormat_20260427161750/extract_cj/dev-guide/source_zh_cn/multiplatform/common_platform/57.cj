// specific file
specific extend<T> Container<T> {
    specific func setItem(newItem: T) {
        item = newItem
    }
    specific func getItem(): ?T {
        item
    }
}