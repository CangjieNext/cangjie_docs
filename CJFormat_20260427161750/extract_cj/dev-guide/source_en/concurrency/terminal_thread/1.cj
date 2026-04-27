import std.sync.SyncCounter

main(): Unit {
    let syncCounter = SyncCounter(1)
    let fut = spawn {
        syncCounter.waitUntilZero()  // block until the syncCounter becomes zero
        if (Thread.currentThread.hasPendingCancellation) {  // Check cancellation request
            println("cancelled")
            return
        }
        println("hello")
    }
    fut.cancel()    // Send cancellation request
    syncCounter.dec()
    fut.get() // Join thread
}