import std.sync.Mutex

var sum: Int64 = 0
let mutex = Mutex()

main() {
    let foo = spawn {
        =>
            sum = sum + 1
            mutex.unlock() // Error, Unlock without obtaining the lock and throw an exception: IllegalSynchronizationStateException.
    }
    foo.get()
}
