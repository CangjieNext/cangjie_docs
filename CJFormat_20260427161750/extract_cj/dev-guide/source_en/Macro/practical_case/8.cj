import std.collection.*

var memoizeFibMap = HashMap<Int64, Int64>()

func fib(n: Int64): Int64 {
    if (memoizeFibMap.contains(n)) {
        return memoizeFibMap.get(n).getOrThrow()
    }

    let memoizeEvalResult = { =>
        if (n == 0 || n == 1) {
            return n
        }

        return fib(n - 1) + fib(n - 2)
    }()
    memoizeFibMap.add(n, memoizeEvalResult)
    return memoizeEvalResult
}