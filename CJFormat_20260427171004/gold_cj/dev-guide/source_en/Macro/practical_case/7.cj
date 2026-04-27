@Memoize[true]
func fib(n: Int64): Int64 {
    if (n == 0 || n == 1) {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}

main() {
    let start = DateTime.now()
    let f35 = fib(35)
    let end = DateTime.now()
    println("fib(35): ${f35}")
    println("execution time: ${(end - start).toMicroseconds()} us")
}
