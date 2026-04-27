class A {
    operator func [](arg1: Int64, arg2: String): Int64 {
        return 0
    }
}

func f() {
    let a = A()
    let b: Int64 = a[1, "2"]
    // b == 0
}