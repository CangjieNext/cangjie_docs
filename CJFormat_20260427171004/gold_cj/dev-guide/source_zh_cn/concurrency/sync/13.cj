public class Mutex <: UniqueLock {
    // ...
    // Generate a Condition instance for the mutex.
    public func condition(): Condition
}

public interface Condition {
    // Wait for a signal, blocking the current thread.
    func wait(): Unit
    func wait(timeout!: Duration): Bool

    // Wait for a signal and predicate, blocking the current thread.
    func waitUntil(predicate: () -> Bool): Unit
    func waitUntil(predicate: () -> Bool, timeout!: Duration): Bool

    // Wake up one thread of those waiting on the monitor, if any.
    func notify(): Unit

    // Wake up all threads waiting on the monitor, if any.
    func notifyAll(): Unit
}
