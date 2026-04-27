public abstract class Iterator<T> <: Iterable<T> {
    public func next(): Option<T>
    ...
}