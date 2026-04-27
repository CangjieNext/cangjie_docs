public class ThreadLocal<T> {
    /* Construct a Cangjie thread-local variable carrying a null value */
    public init()

    /* Get the value of the Cangjie thread-local variable */
    public func get(): Option<T> // Returns Option<T>.None if the value does not exist. Return value Option<T> - the value of the Cangjie thread-local variable.

    /* Set the value of the Cangjie thread-local variable via 'value' */
    public func set(value: Option<T>): Unit // If Option<T>.None is passed, the value of the local variable will be deleted and cannot be retrieved in subsequent thread operations. Parameter value - the value to set for the local variable.
}