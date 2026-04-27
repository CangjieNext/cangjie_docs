import std.sync.Mutex
import std.collection.ArrayList

var count: Int64 = 0
let mtx = Mutex()

main(): Int64 {
    let list = ArrayList<Future<Unit>>()

    // create 1000 threads.
    for (i in 0..1000) {
        let fut = spawn {
            sleep(Duration.millisecond) // sleep for 1ms.

            // Use synchronized(mtx), instead of mtx.lock() and mtx.unlock().
            synchronized(mtx) {
                count++
            }
        }
        list.add(fut)
    }

    // Wait for all threads finished.
    for (f in list) {
        f.get()
    }

    println("count = ${count}")
    return 0
}
