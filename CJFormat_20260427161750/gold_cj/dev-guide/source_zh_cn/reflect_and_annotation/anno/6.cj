// 安全
@OverflowThrowing
func operation(a: Int32, b: Int32): Int32 {
    a + b
}

main(): Int64 {
    try {
        operation(Int32.Max, 1)
    } catch (e: ArithmeticException) {
        println(e.message)
        //Handle error
    }
    0
}
