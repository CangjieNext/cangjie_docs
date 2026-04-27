// common file
class Container<T> {
    var item: ?T = Option<T>.None
}

common extend<T> Container<T> {
    common func setItem(newItem: T): Unit
    common func getItem(): ?T
}