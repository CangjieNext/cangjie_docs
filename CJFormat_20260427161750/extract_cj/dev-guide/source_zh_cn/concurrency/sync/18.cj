import std.sync.Mutex
import std.collection.ArrayList

var count: Int64 = 0
var mtx: Mutex = Mutex()

main(): Int64 {
    let list = ArrayList<Future<Unit>>()
    for (i in 0..10) {
        let fut = spawn {
            while (true) {
                synchronized(mtx) {
                    count = count + 1
                    break
                    println("in thread")
                }
            }
        }
        list.add(fut)
    }

    // Wait for all threads finished.
    for (f in list) {
        f.get()
    }

    synchronized(mtx) {
        println("in main, count = ${count}")
    }
    return 0
}