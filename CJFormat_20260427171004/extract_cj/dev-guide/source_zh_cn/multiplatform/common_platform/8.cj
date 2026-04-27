// common file
package cmp

common class Container<T> where T <: Comparable<T> {
    common var value: T
    common init(value: T) { this.value = value }
    common func get(): T
    common func set(newValue: T): Unit
    common func map<R>(convert: (T) -> R): Container<R> where R <: Comparable<R>
}