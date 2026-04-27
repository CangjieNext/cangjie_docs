import std.collection.ArrayList
import std.runtime.gc

class Test {
    public static var t0: Int32 = 0
    public init() {
        t0++
    }
    ~init() {
        t0--
    }
}

var list: ArrayList<Test> = ArrayList<Test>()

func foo(): Int32 {
    let o1 = Test()
    list.add(o1)
    if (Test.t0 != 1) {
        return 1
    }
    list.remove(at: 0)
    return 0
}

main(): Int64 {
    var i: Int64 = 0
    while (i < 100) {
        if (foo() != 0) {
            print("fail: obj is freed before gc!")
            return 1
        }
        gc(heavy: true) // blocking gc expected

        // wait ~init() to be executed
        while (Test.t0 != 0) { // error, this is undefined behavior
            continue
        }
        i++
    }
    return 0
}
