import std.sync.Mutex

var count: Int64 = 0
let mtx = Mutex()

func foo() {
    mtx.lock()
    count += 10
    bar()
    mtx.unlock()
}

func bar() {
    mtx.lock()
    count += 100
    mtx.unlock()
}

main(): Int64 {
    let fut = spawn {
        sleep(Duration.millisecond) // sleep for 1ms.
        foo()
    }

    foo()

    fut.get()

    println("count = ${count}")
    return 0
}