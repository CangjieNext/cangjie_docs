func f() {
    let x: Int64
    func f1() {
        println(x) // Error, x is not initialized yet
    }
    x = 99
    f1()
}