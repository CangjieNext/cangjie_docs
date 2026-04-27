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
    var b: Bool = isEven(3) && isEven(30) // isEven(3) returns false, b is false, isEven(30) is not evaluated

    a = isEven(4) || isEven(40) // isEven(4) returns true, a is true, isEven(40) is not evaluated
    b = isEven(5) || isEven(50)
}
