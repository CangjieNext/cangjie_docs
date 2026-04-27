func global_func_02<K, G>() { 0 }
public struct Pair<T, U> {
    let x: T
    let y: U
    public init(a: T, b: U) {
        x = a
        y = b
    }
}
main() {
    var a: Pair<String, Int64> = Pair<String, Int64>("hello", 0)
    global_func_02<Int64, String>()
    0
}

========================================
(cjdb) b 1
Breakpoint 1: where = main`default::global_func_02<T0,T1>() + 9 at test.cj:1:33, address = 0x0000000000019989
(cjdb) b 6
Breakpoint 2: where = main`default::Pair<T0,T1>::init(T0, T1) + 150 at test.cj:6:9, address = 0x000000000001982a