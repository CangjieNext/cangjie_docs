// specific file
package cmp

specific class Container<T> where T <: Comparable<T> {
    specific var value: T
    specific init(value: T) {
        this.value = value
    }
    specific func get(): T {
        value
    }
    specific func set(newValue: T): Unit {
        value = newValue
    }
    specific func map<R>(convert: (T) -> R): Container<R> where R <: Comparable<R> {
        return Container<R>(convert(value))
    }
}
