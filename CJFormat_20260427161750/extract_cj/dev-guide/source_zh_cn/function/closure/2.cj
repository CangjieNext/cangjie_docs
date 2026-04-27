func f() {
    let x = 99
    func f1() {
        println(x)
    }
    let f2 = { =>
        println(y)  // Error, cannot capture 'y' which is not defined yet
    }
    let y = 88
    f1()            // Print 99
    f2()
}