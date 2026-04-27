import std.sync.Mutex

let m1 = Mutex()
let c1 = synchronized(m1) {
    m1.condition()
}
let m2 = Mutex()
var flag: Bool = true
var count: Int64 = 0

func foo1() {
    spawn {
        m2.lock()
        while (flag) {
            c1.wait() // Error：The lock used with the condition variable must be the same and in the locked state. Otherwise, the unlock operation in `wait` throws an exception.
        }
        count = count + 1
        m2.unlock()
    }
    m1.lock()
    flag = false
    c1.notifyAll()
    m1.unlock()
}

func foo2() {
    spawn {
        while (flag) {
            c1.wait() // Error：`wait` must be called while holding the lock.
        }
        count = count + 1
    }
    m1.lock()
    flag = false
    c1.notifyAll()
    m1.unlock()
}

main() {
    foo1()
    foo2()
    c1.wait()
}