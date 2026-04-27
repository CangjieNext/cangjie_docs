main(): Unit {
    let fut = spawn {
        println("Current thread id: ${Thread.currentThread.id}")
    }
    println("New thread id: ${fut.thread.id}")
    fut.get()
}
