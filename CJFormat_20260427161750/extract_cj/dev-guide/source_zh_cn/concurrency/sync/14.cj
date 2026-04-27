import std.sync.Mutex

let mtx = Mutex()
let condition = synchronized(mtx) {
    mtx.condition()
}
var flag: Bool = true

main(): Int64 {
    let fut = spawn {
        mtx.lock()
        while (flag) {
            println("New thread: before wait")
            condition.wait()
            println("New thread: after wait")
        }
        mtx.unlock()
    }

    // Sleep for 10ms, to make sure the new thread can be executed.
    sleep(10 * Duration.millisecond)

    mtx.lock()
    println("Main thread: set flag")
    flag = false
    mtx.unlock()

    mtx.lock()
    println("Main thread: notify")
    condition.notifyAll()
    mtx.unlock()

    // wait for the new thread finished.
    fut.get()
    return 0
}