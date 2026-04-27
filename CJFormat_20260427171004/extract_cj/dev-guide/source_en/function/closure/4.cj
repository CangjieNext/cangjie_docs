class C {
    public var num: Int64 = 0
}

func returnIncrementer(): () -> Unit {
    let c: C = C()

    func incrementer() {
        c.num++
    }

    incrementer
}

main() {
    let f = returnIncrementer()
    f() // c.num increases by 1
}