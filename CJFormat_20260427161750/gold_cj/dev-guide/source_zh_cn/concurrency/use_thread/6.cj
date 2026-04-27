class Thread {
    // Get the currently running thread
    static prop currentThread: Thread

    // Get the unique identifier (represented as an integer) of the thread object
    prop id: Int64

    // Check whether the thread has any cancellation request
    prop hasPendingCancellation: Bool
}
