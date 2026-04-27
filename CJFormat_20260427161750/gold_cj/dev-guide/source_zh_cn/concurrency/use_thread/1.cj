public class Future<T> {
    // Blocking the current thread, waiting for the result of the thread corresponding to the current Future object.
    // If an exception occurs in the corresponding thread, the method will throw the exception.
    public func get(): T

    // Blocking the current thread, waiting for the result of the thread corresponding to the current Future object.
    // If the corresponding thread has not completed execution within Duration, the method will throws TimeoutException.
    // If `timeout` <= Duration.Zero, its behavior is the same as `get()`.
    public func get(timeout: Duration): T

    // Non-blocking method that immediately returns Option<T>.None if thread has not finished execution.
    // Returns the computed result otherwise.
    // If an exception occurs in the corresponding thread, the method will throw the exception.
    public func tryGet(): Option<T>
}
