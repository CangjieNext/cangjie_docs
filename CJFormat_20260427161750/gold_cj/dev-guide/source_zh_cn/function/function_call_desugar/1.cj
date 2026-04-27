func myIf(a: Bool, fn: () -> Int64) {
    if (a) {
        fn()
    } else {
        0
    }
}

func test() {
    myIf(true, {=> 100}) // General function call

    myIf(true) { // Trailing closure call
        100
    }
}
