class A {
    operator func [](arg1: Int64, arg2: String, value!: Int64): Unit {
        return
    }
}

func f() {
    let a = A()
    a[1, "2"] = 0
}
