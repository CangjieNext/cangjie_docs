func foo() {
    func nestAdd(a: Int64, b: Int64) {
        a + b + 3
    }

    println(nestAdd(1, 2))  // 6

    return nestAdd
}

main() {
    let f = foo()
    let x = f(1, 2)
    println("result: ${x}")
}