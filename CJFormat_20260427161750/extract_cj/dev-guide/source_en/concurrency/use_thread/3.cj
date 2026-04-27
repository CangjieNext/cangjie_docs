main(): Int64 {
    let fut: Future<Unit> = spawn { =>
        println("New thread before sleeping")
        sleep(100 * Duration.millisecond) // sleep for 100ms.
        println("New thread after sleeping")
    }

    fut.get() // wait for the thread to finish.

    println("Main thread")
    return 0
}