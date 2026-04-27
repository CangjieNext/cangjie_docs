public class Mutex <: UniqueLock {
    // Create a Mutex.
    public init()

    // Locks the mutex, blocks if the mutex is not available.
    public func lock(): Unit

    // Unlocks the mutex. If there are other threads blocking on this
    // lock, then wake up one of them.
    public func unlock(): Unit

    // Tries to lock the mutex, returns false if the mutex is not
    // available, otherwise returns true.
    public func tryLock(): Bool

    // Generate a Condition instance for the mutex.
    public func condition(): Condition
}