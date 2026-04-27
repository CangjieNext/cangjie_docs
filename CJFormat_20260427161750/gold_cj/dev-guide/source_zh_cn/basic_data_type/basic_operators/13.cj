func isEven(a: Int64): Bool {
    if ((a % 2) == 0) {
        println("${a} is an even number")
        true
    } else {
        println("${a} is not an even number")
        false
    }
}

main() {
    var a: Bool = isEven(2) && isEven(20)
    var b: Bool = isEven(3) && isEven(30) // isEven(3)返回值是false, b 值为false，无需对isEven(30)求值

    a = isEven(4) || isEven(40) // isEven(4)返回值是true, a 值为true，无需对isEven(40)求值
    b = isEven(5) || isEven(50)
}
