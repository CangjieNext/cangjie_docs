open class Node<K, V> where K <: Hashable & Equatable<K> {
    var key: Option<K> = Option<K>.None
    var value: Option<V> = Option<V>.None

    init() {}

    init(key: K, value: V) {
        this.key = Option<K>.Some(key)
        this.value = Option<V>.Some(value)
    }
}