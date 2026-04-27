public interface Iterable<E> {
    func iterator(): Iterator<E>
}

public interface Iterator<E> <: Iterable<E> {
    func next(): Option<E>
}

public interface Collection<T> <: Iterable<T> {
    prop size: Int64
    func isEmpty(): Bool
}
