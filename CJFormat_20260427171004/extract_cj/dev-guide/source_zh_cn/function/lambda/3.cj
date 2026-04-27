// The parameter types are inferred from the type of the variable sum1
var sum1: (Int64, Int64) -> Int64 = { a, b => a + b }

var sum2: (Int64, Int64) -> Int64 = { a: Int64, b => a + b }

func f(a1: (Int64) -> Int64): Int64 {
    a1(1)
}

main(): Int64 {
    // The parameter type of lambda is inferred from the type of function f
    f({ a2 => a2 + 10 })
}