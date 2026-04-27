main(): Int64 {
    let fut: Future<Unit> = spawn { =>
        println("New thread before sleeping")
        sleep(100 * Duration.millisecond) // sleep for 100ms.
        println("New thread after sleeping")
    }

    println("Main thread")

    fut.get() // wait for the thread to finish.
    return 0
}