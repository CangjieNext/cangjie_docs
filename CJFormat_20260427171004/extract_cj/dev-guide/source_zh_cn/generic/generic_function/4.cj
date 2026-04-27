func foo(a: Int64) {
    func id<T>(a: T): T { a }

    func double(a: Int64): Int64 { a + a }

    return (id<Int64> ~> double)(a) == (double ~> id<Int64>)(a)
}

main() {
    println(foo(1))
}