func returnAddNum(): (Int64) -> Int64 {
    let num: Int64 = 10

    func add(a: Int64) {
        return a + num
    }
    add
}

main() {
    let f = returnAddNum()
    println(f(10))
}
