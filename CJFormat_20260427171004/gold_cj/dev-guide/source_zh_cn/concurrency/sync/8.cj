import std.sync.Mutex

main(): Int64 {
    let mtx: Mutex = Mutex()
    var future: Future<Unit> = spawn {
        mtx.lock()
        println("get the lock, do something")
        sleep(Duration.millisecond * 10)
        mtx.unlock()
    }
    try {
        future.get(Duration.millisecond * 10)
    } catch (e: TimeoutException) {
        if (mtx.tryLock()) {
            println("tryLock success, do something")
            mtx.unlock()
            return 0
        }
        println("tryLock failed, do nothing")
        return 0
    }
    return 0
}
