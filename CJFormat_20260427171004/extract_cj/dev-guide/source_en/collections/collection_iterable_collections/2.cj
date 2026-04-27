interface Iterator<T> <: Iterable<T> {
    mut func next(): Option<T>
    ...
}