import std.sync.Mutex

var sum: Int64 = 0
let mutex = Mutex()

main() {
    let foo = spawn { =>
        mutex.lock()
        sum = sum + 1
    }
    let bar = spawn { =>
        mutex.lock()
        sum = sum + 1
    }
    foo.get()
    println("${sum}")
    bar.get() // Because the thread is not unlocked, other threads waiting to obtain the current mutex will be blocked.
}